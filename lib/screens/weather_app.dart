import 'dart:ui';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_weather_app/models/dailyForecast.dart';
import 'package:flutter_weather_app/models/hourlyForecast.dart';
import 'package:flutter_weather_app/screens/daily_forecast.dart';
import 'package:flutter_weather_app/screens/favorite_locations.dart';
import 'package:flutter_weather_app/screens/full_hourly_forecast.dart';
import 'package:flutter_weather_app/screens/precipitation_forecast.dart';
import 'package:flutter_weather_app/screens/precipitation_overview.dart';
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
  int _currentIndex = 0;
  late String city;

  WeatherAppState({required this.city});

  final apiKey = 'd52d75717fe982b4baa261365cd47eae';

  late WeatherApi weatherApi = WeatherApi(apiKey: apiKey);

  String cityDefault = 'Chicago';
  String currentTime = '';

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

  void navigateToPrecipitationOverview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrecipitationOverviewScreen(
            city: city, dailyForecastData: dailyForecastData),
      ),
    );
  }

  void navigateToHourlyForecast(List<Hourly> hourlyForecastList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HourlyForecastScreen(hourlyForecastList: hourlyForecastList),
      ),
    );
  }

  void navigateToDailyForecast() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DailyForecast(city: city)),
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

  String _getFormattedTime(int? unixTimestamp, [formatType]) {
    if (unixTimestamp == null) {
      return '';
    }

    if (formatType == 1) {
      // Convert Unix timestamp to DateTime for golden hour
      DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
      DateTime goldenHour = date.subtract(const Duration(seconds: 3600));
      String formattedTime = DateFormat('HH:mm').format(goldenHour);
      return formattedTime;
    } else if (formatType == 2) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
      DateTime blueHour = date.add(const Duration(seconds: 600));
      String formattedTime = DateFormat('HH:mm').format(blueHour);
      return formattedTime;
    } else {
      // Convert Unix timestamp to DateTime
      DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
      // Format the DateTime as a string
      String formattedTime = DateFormat('HH:mm').format(date);
      currentTime = formattedTime;
      return formattedTime;
    }
  }

  String _getSunMoonDuration(int? moonrise, int? moonset) {
    if (moonrise == null || moonset == null) {
      return 'N/A';
    }

    DateTime moonriseTime =
        DateTime.fromMillisecondsSinceEpoch(moonrise * 1000);
    DateTime moonsetTime = DateTime.fromMillisecondsSinceEpoch(moonset * 1000);

    Duration duration = moonsetTime.difference(moonriseTime);
    // Format the time as HH:mm
    String formattedDuration =
        '${(duration.inHours).abs().toString()} hrs ${(duration.inMinutes % 60).toString()} mins';
    return formattedDuration;
  }

  String getTemperature(String location) {
    if (weatherData == null) {
      return 'Loading...';
    }

    return '${weatherData!['main']['temp'].toInt()}°';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 21, 34),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 96,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        title: const Text(
          '',
          style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 15, 21, 34),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 27, 33, 45)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(top: 8.0),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: ListTile(
                      title: Text(
                        city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1,
                        ),
                      ),
                      subtitle: Text(
                        currentTime,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                          fontSize: 24,
                          letterSpacing: 1,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        weatherData != null
                            ? capitalizeEveryFirstLetter(
                                '${weatherData!['weather'][0]['description']}')
                            : 'Loading...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          height: 1,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                child: ListTile(
                  title: const Text(
                    'Change Location',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Raleway',
                      color: Colors.white,
                      fontSize: 18.0,
                      letterSpacing: 1,
                    ),
                  ),
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
                                        builder: (context) => WeatherApp(
                                            city: userInputLocation)));
                              },
                              child: const Text('Search'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: const Text(
                  'Favorite Locations',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Raleway',
                    color: Colors.white,
                    fontSize: 18.0,
                    letterSpacing: 1,
                  ),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: const Text(
                  'Precipitation Outlook',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Raleway',
                    color: Colors.white,
                    fontSize: 18.0,
                    letterSpacing: 1,
                  ),
                ),
                onTap: () {
                  navigateToPrecipitationOverview();
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: _buildUI(),
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(223, 12, 17, 30),
        onItemSelected: (index) {
          setState(() {
            if (index == 0) {
              _currentIndex = index;
            }
            if (index == 1) {
              _currentIndex = index;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FavoriteLocationsScreen()));
            }
            if (index == 2) {
              _currentIndex = index;
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
            }
            if (index == 3) {
              _currentIndex = index;
              navigateToHourlyForecast(hourlyForecastList as List<Hourly>);
            }
            if (index == 4) {
              _currentIndex = index;
              navigateToDailyForecast();
            }
            ;
          });
        },
        items: [
          BottomNavyBarItem(
              icon: const Icon(Icons.calendar_today),
              title: const Text('Today'),
              activeColor: Colors.white,
              textAlign: TextAlign.center),
          BottomNavyBarItem(
            icon: const Icon(Icons.favorite_border),
            title: const Text('Favorites'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.search),
            title: const Text('Location'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.access_time_outlined),
            title: const Text('Hourly'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.calendar_view_week_outlined),
            title: const Text('Daily'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    final backgroundImage = _getImageBasedOnTime();

    if (weatherData == null || dailyForecastData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    forecastList = dailyForecastData!.daily!;
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildMainImageOverlay(),
                _buildHourlyForecast(backgroundImage),
                _sunriseToSunset(),
                //_buildForecastList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainImageOverlay() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_getImageBasedOnTime()),
          fit: BoxFit.cover,
        ),
      ),
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
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  String _getImageBasedOnTime() {
    final now = DateTime.now();
    final currentTime = now.hour;

    if (currentTime >= 6 && currentTime < 12) {
      // Morning
      return 'assets/images/morning_sunrise.jpg';
    } else if (currentTime >= 12 && currentTime < 18) {
      // Afternoon
      return 'assets/images/daytime_sunrise.jpg';
    } else if (currentTime >= 18 && currentTime < 24) {
      // Evening
      return 'assets/images/evening_sunset.jpg';
    } else {
      // Night
      return 'assets/images/nighttime.jpg';
    }
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

  Widget _buildHourlyForecast(String backgroundImage) {
    Color gradientStartColor;
    Color gradientEndColor;

    if (backgroundImage.contains('morning_sunrise')) {
      gradientStartColor = const Color.fromARGB(255, 49, 70, 116);
      gradientEndColor = const Color.fromARGB(255, 15, 21, 34);
    } else if (backgroundImage.contains('daytime_sunrise')) {
      gradientStartColor = const Color.fromARGB(255, 18, 64, 80);
      gradientEndColor = const Color.fromARGB(255, 15, 21, 34);
    } else if (backgroundImage.contains('evening_sunset')) {
      gradientStartColor = const Color.fromARGB(255, 34, 47, 94);
      gradientEndColor = const Color.fromARGB(255, 15, 21, 34);
    } else {
      gradientStartColor = const Color.fromARGB(255, 8, 6, 17);
      gradientEndColor = const Color.fromARGB(255, 15, 21, 34);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientStartColor,
          gradientEndColor,
        ],
      )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
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
          const SizedBox(height: 12.0),
          // Use ListView.builder to display the forecastList
          Container(
            margin: const EdgeInsets.only(bottom: 32.0),
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
                        _getFormattedTime(
                            hourlyForecastList?[index].dt as int?),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.75,
                        ),
                      ),
                      Center(
                          child: Image.network(
                        'https://openweathermap.org/img/wn/${hourlyForecastList?[index].weather?[0].icon}.png',
                        width: 40,
                        height: 40,
                      )),
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
                          SvgPicture.asset(
                            'assets/icons/wind-bold-duotone.svg',
                            semanticsLabel: 'Wind Icon',
                            width: 18.0,
                            height: 18.0,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          Text(
                            '${hourlyForecastList?[index].windSpeed?.toInt()}mph',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w300),
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
      ),
    );
  }

  Widget _locationHeader() {
    DateTime now = DateTime.now();
    //String formattedDate = DateFormat('EEE, MMM d').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Text(
            capitalize(city),
            style: const TextStyle(
              fontSize: 44,
              color: Colors.white,
              height: 0,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
              fontFamily: 'Raleway',
            ),
          ),
        ),
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 24,
            color: Color.fromARGB(200, 255, 255, 255),
            fontWeight: FontWeight.w400,
            fontFamily: 'New York',
            fontFeatures: [FontFeature.tabularFigures()],
            height: 1.75,
          ),
        ),
      ],
    );
  }

  Widget currentConditions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Container(
          width: 175,
          height: 30.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.black.withOpacity(0.03),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Center(
                child: Text(
                  weatherData != null
                      ? capitalizeEveryFirstLetter(
                          '${weatherData!['weather'][0]['description']}')
                      : 'Loading...',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Raleway',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _currentWeatherDetailsBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherDetailRow(
                  value: weatherData != null
                      ? '${weatherData!['clouds']['all'].toString()}%'
                      : 'Loading...',
                  icon: Icons.cloud_outlined,
                ),
                _buildWeatherDetailRow(
                  value: weatherData != null
                      ? '${weatherData!['main']['humidity'].toString()}%'
                      : 'Loading...',
                  icon: Icons.water_outlined,
                ),
                _buildWeatherDetailRow(
                  value: weatherData != null
                      ? '${weatherData!['wind']['speed'].toInt()}mph'
                      : 'Loading...',
                  icon: Icons.air_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailRow({
    required String value,
    IconData icon = Icons.update_outlined,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        const SizedBox(width: 6.0),
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ],
    );
  }

  Widget _currentTemperature() {
    return Padding(
      padding: const EdgeInsets.only(top: 56.0, bottom: 24.0),
      child: Text(
        weatherData != null
            ? '${weatherData!['main']['temp'].toInt()}°'
            : 'Loading...',
        style: const TextStyle(
            shadows: <Shadow>[
              Shadow(
                  blurRadius: 2,
                  color: Color.fromARGB(80, 0, 0, 0),
                  offset: Offset(2, 4))
            ],
            fontSize: 128,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: 'Raleway',
            height: 1,
            fontFeatures: [FontFeature.tabularFigures()]),
      ),
    );
  }

  Widget _hiLowTemperature() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Center(
        child: Container(
          width: 130,
          height: 36.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          weatherData != null
                              ? '${weatherData!['main']['temp_max'].toInt()}°'
                              : 'Loading...',
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
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
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          weatherData != null
                              ? '${weatherData!['main']['temp_min'].toInt()}°'
                              : 'Loading...',
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sunriseToSunset() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 15, 21, 34).withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.47,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        color: Color.fromARGB(255, 251, 191, 36),
                        size: 36,
                      ),
                      Text(
                        dailyForecastData != null
                            ? _getSunMoonDuration(
                                dailyForecastData?.daily?[0].sunrise as int?,
                                dailyForecastData?.daily?[0].sunset as int?)
                            : 'Loading...',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Rise',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(
                            'Set',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            'Golden Hour',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            _getFormattedTime(
                                dailyForecastData?.daily?[0].sunrise as int?),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getFormattedTime(
                                dailyForecastData?.daily?[0].sunset as int?),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            _getFormattedTime(
                                dailyForecastData?.daily?[0].sunset as int?, 1),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.47,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.nightlight_outlined,
                        color: Colors.white70,
                        size: 36,
                      ),
                      Text(
                        weatherData != null
                            ? _getSunMoonDuration(
                                dailyForecastData?.daily?[0].moonrise as int?,
                                dailyForecastData?.daily?[0].moonset as int?)
                            : 'Loading...',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Rise',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(
                            'Set',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            'Blue Hour',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            _getFormattedTime(
                                dailyForecastData?.daily?[0].moonrise as int?),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getFormattedTime(
                                dailyForecastData?.daily?[0].moonset as int?),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            _getFormattedTime(
                                dailyForecastData?.daily?[0].moonset as int?,
                                2),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
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
