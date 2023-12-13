import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/dailyForecast.dart';
import 'package:flutter_weather_app/models/hourlyForecast.dart';
import 'package:flutter_weather_app/screens/favorite_locations.dart';
import 'package:flutter_weather_app/screens/precipitation_forecast.dart';
import 'package:flutter_weather_app/services/weather_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WeatherApp extends StatefulWidget {
  final String city;

  const WeatherApp({super.key, required this.city});

  @override
  // ignore: no_logic_in_create_state
  WeatherAppState createState() => WeatherAppState(city: city);
}

class WeatherAppState extends State<WeatherApp> {
  late String city;

  WeatherAppState({required this.city});

  final apiKey = 'd52d75717fe982b4baa261365cd47eae';

  late WeatherApi weatherApi = WeatherApi(apiKey: apiKey);

  String cityDefault = 'Chicago';
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? hourlyData;
  Map<String, dynamic>? dailyData;
  dailyForecast? dailyForecastData;
  hourlyForecast? hourlyForecastData;
  List<Daily>? forecastList = [];
  List<Hourly>? hourlyForecastList = [];

  @override
  void initState() {
    super.initState();
    weatherApi = WeatherApi(apiKey: apiKey);
    getWeatherData();
    getHourlyForecast();
    getDailyForecast();
    city = widget.city;
    _loadData();
    setState(() {});
  }

  Future<void> _loadData() async {
    try {
      final data = await weatherApi.getWeather(city);
      final dailyForecast = await weatherApi.getDailyForecastData(city);
      final hourlyForecast = await weatherApi.getHourlyForecastData(city);

      setState(() {
        weatherData = data;
        dailyForecastData = dailyForecast;
        forecastList = dailyForecast?.daily ?? [];
        hourlyForecastData = hourlyForecast;
        hourlyForecastList = hourlyForecast?.hourly ?? [];
      });
    } catch (e) {
      print('Error caught: $e');
    }
  }

  Future<void> getWeatherData() async {
    try {
      final data = await weatherApi.getWeather(city);
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print('Error caught: $e');
    }
  }

  Future<void> getHourlyForecast() async {
    try {
      final data = await weatherApi.getHourlyForecast(city);
      setState(() {
        hourlyData = data;
      });
    } catch (e) {
      print('Error caught: $e');
    }
  }

  Future<void> getDailyForecast() async {
    try {
      final data = await weatherApi.getDailyForecast(city);
      setState(() {
        dailyData = data;
      });
      print('daily data success');
    } catch (e) {
      print('Error caught: $e');
    }
  }

  void changeLocation(String newCity) async {
    setState(() {
      city = newCity;
    });

    _loadData();
  }

  void findLocation(String newCity) async {
    setState(() {
      cityDefault = newCity;
    });
    await FavoriteLocations.addFavoriteLocation(city);
    getWeatherData();
    getDailyForecast();
    _loadData();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  // Capitalize first letter of location name
  String capitalize(String input) {
    return input.isNotEmpty
        ? '${input[0].toUpperCase()}${input.substring(1)}'
        : input;
  }

  String capitalizeEveryFirstLetter(String input) {
    List<String> words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }
    return words.join(' ');
  }

  void navigateToPrecipitationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrecipitationForecast(city: ''),
      ),
    );
  }

  String _getFormattedDate(int? unixTimestamp) {
    if (unixTimestamp == null) {
      return '';
    }

    // Convert Unix timestamp to DateTime
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

    // Format the DateTime as a string
    String formattedDate = '${date.month}/${date.day}/${date.year}';

    return formattedDate;
  }

  String _getFormattedTime(int? unixTimestamp) {
    if (unixTimestamp == null) {
      return '';
    }

    // Convert Unix timestamp to DateTime
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

    // Format the DateTime as a string
    String formattedTime = DateFormat('HH:mm').format(date);

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 82,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          foregroundColor: Colors.white70,
          elevation: 0.0,
        ),
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          backgroundColor: const Color.fromARGB(255, 15, 21, 34),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 27, 33, 45)),
                child: Text(
                  'Weather App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const ListTile(
                title: Text('Current Weather',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Raleway',
                        color: Colors.white)),
              ),
              ListTile(
                title: const Text('Change Location',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Raleway',
                        color: Colors.white)),
                onTap: () {
                  // Show a dialog or navigate to a screen for changing location
                  // For simplicity, we'll use a dialog for this example
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String userInputLocation = '';

                      return AlertDialog(
                        title: const Text('Find Location'),
                        content: TextField(
                          onChanged: (newLocation) {
                            // Handle changes in the text field
                            userInputLocation = newLocation;
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Retrieve the new location from the text field
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WeatherApp(city: userInputLocation)));
                            },
                            child: const Text('Search'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text(
                  'Favorite Locations',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Raleway',
                      color: Colors.white),
                ),
                onTap: () {
                  // Show a screen for managing favorite locations
                  // For simplicity, we'll just print a message for this example
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavoriteLocationsScreen()));
                  // Close the drawer after selecting the option
                },
              ),
              ListTile(
                title: const Text(
                  'Precipitation Details',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Raleway',
                      color: Colors.white),
                ),
                onTap: () {
                  navigateToPrecipitationScreen();
                },
              ),
            ],
          ),
        ),
        body: _buildUI());
  }

  Widget _buildUI() {
    if (weatherData == null || dailyForecastData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    forecastList = dailyForecastData!.daily!;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _locationHeader(),
            currentConditions(),
            _currentTemperature(),
            _hiLowTemperature(),
            const SizedBox(height: 36.0),
            _currentWeatherDetailsBanner(),
            _buildHourlyForecast(),
            //_buildForecastList(),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Weekly Forecast Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24.0),
        // Use ListView.builder to display the forecastList
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: forecastList?.length,
              itemBuilder: (context, index) {
                // Access forecastList[index] to display individual forecast details
                return ListTile(
                  title: Text(
                    _getFormattedDate(forecastList?[index].dt as int?),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  subtitle: Text(
                    'Day: ${forecastList?[index].temp?.day}°F, Night: ${forecastList?[index].temp?.night}°F',
                    style: const TextStyle(color: Colors.white),
                  ),
                  leading: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white12),
                      child: Center(
                          child: Image.network(
                        'https://openweathermap.org/img/w/${forecastList?[index].weather?[0].icon}.png',
                        width: 50,
                        height: 50,
                      ))),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 40.0),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Raleway',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        // Use ListView.builder to display the forecastList
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          height: 140,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              // Access forecastList[index] to display individual forecast details
              return SizedBox(
                width: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _getFormattedTime(hourlyForecastList?[index].dt as int?),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Container(
                        child: Center(
                            child: Image.network(
                      'https://openweathermap.org/img/wn/${hourlyForecastList?[index].weather?[0].icon}.png',
                      width: 40,
                      height: 40,
                    ))),
                    Text(
                      '${forecastList?[index].temp?.day?.toInt()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.air_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        Text(
                          '${hourlyForecastList?[index].windSpeed?.toInt()}mph',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _locationHeader() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE, MMM d').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            capitalize(city),
            style: const TextStyle(
              fontSize: 44,
              color: Colors.white,
              height: 0,
              fontWeight: FontWeight.normal,
              letterSpacing: -1,
              fontFamily: 'Raleway',
            ),
          ),
        ),
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 24,
            color: Color.fromARGB(235, 255, 255, 255),
            fontWeight: FontWeight.normal,
            fontFamily: 'Raleway',
            letterSpacing: 2,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget currentConditions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Stack(
        children: <Widget>[
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: 150,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey.shade900.withOpacity(0.03),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              weatherData != null
                  ? capitalizeEveryFirstLetter(
                      '${weatherData!['weather'][0]['description']}')
                  : 'Loading...',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentWeatherDetailsBanner() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.35),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Text(
                    weatherData != null
                        ? '${weatherData!['clouds']['all'].toString()}% '
                        : 'Loading...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  const Icon(
                    Icons.cloud_outlined,
                    color: Colors.white,
                    size: 20,
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    weatherData != null
                        ? '${weatherData!['main']['humidity'].toString()}% '
                        : 'Loading...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  const Icon(
                    Icons.water_outlined,
                    color: Colors.white,
                    size: 20,
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    weatherData != null
                        ? '${weatherData!['wind']['speed'].toInt()} mph '
                        : 'Loading...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                  const Icon(
                    Icons.air_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _currentTemperature() {
    return Padding(
      padding: const EdgeInsets.only(top: 56.0),
      child: Text(
        weatherData != null
            ? '${weatherData!['main']['temp'].toInt()}°'
            : 'Loading...',
        style: const TextStyle(
            fontSize: 128,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: 'Raleway',
            height: 1),
      ),
    );
  }

  Widget _hiLowTemperature() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Container(
        height: 36.0,
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey.shade900.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Text(
                    'H: ',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1,
                        fontWeight: FontWeight.w400),
                  ),
                  Text(
                    weatherData != null
                        ? '${weatherData!['main']['temp_max'].toInt()}°'
                        : 'Loading...',
                    style: const TextStyle(
                        fontSize: 18,
                        height: 1,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const Text(
                    'L: ',
                    style: TextStyle(
                        fontSize: 18,
                        height: 1,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  ),
                  Text(
                    weatherData != null
                        ? '${weatherData!['main']['temp_min'].toInt()}°'
                        : 'Loading...',
                    style: const TextStyle(
                        fontSize: 18,
                        height: 1,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteLocations {
  static const _key = 'favoriteLocations';

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final locations = prefs.getStringList(_key) ?? [];
    return locations;
  }

  static Future<void> addFavoriteLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteLocations = prefs.getStringList(_key) ?? [];
    favoriteLocations.add(location);
    await prefs.setStringList(_key, favoriteLocations);
  }

  static Future<void> removeFavoriteLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteLocations = prefs.getStringList(_key) ?? [];
    favoriteLocations.remove(location);
    await prefs.setStringList(_key, favoriteLocations);
  }
}
