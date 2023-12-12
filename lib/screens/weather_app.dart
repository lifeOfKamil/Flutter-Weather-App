import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/dailyForecast.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
