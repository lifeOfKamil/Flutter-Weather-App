import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/dailyForecast.dart';
import 'package:flutter_weather_app/screens/favorite_locations.dart';
import 'package:flutter_weather_app/screens/precipitation_forecast.dart';
import 'package:flutter_weather_app/services/weather_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Daily>? forecastList = [];

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

      setState(() {
        weatherData = data;
        dailyForecastData = dailyForecast;
        forecastList = dailyForecast?.daily ?? [];
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

  void navigateToPrecipitatiopnScreen() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text('Weather App',
              style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          foregroundColor: Colors.white70,
          elevation: 0.0,
        ),
        backgroundColor: Colors.white10,
        drawer: Drawer(
          backgroundColor: Colors.blueGrey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 118, 165, 189)),
                child: Text(
                  'Weather App Menu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w600),
                ),
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
                  'Precipitation',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Raleway',
                      color: Colors.white),
                ),
                onTap: () {
                  navigateToPrecipitatiopnScreen();
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 72.0),
            _locationHeader(),
            const SizedBox(height: 56.0),
            _currentTemperature(),
            const SizedBox(height: 16.0),
            _hiLowTemperature(),
            const SizedBox(height: 48.0),
            _buildForecastList(),
            const SizedBox(height: 32.0),
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

  Widget _locationHeader() {
    return Text(
      capitalize(city),
      style: const TextStyle(
        fontSize: 32,
        color: Colors.white,
      ),
    );
  }

  Widget _currentTemperature() {
    return Text(
      weatherData != null
          ? '${weatherData!['main']['temp'].toInt()}°F'
          : 'Loading...',
      style: const TextStyle(
          fontSize: 88,
          letterSpacing: -2,
          color: Colors.white,
          fontWeight: FontWeight.w300),
    );
  }

  Widget _hiLowTemperature() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Text(
                'HIGH',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300),
              ),
              Text(
                weatherData != null
                    ? '${weatherData!['main']['temp_max'].toInt()}°'
                    : 'Loading...',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Text(
                'LOW',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300),
              ),
              Text(
                weatherData != null
                    ? '${weatherData!['main']['temp_min'].toInt()}°'
                    : 'Loading...',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
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
