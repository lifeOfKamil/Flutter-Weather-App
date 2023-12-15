import 'package:flutter_weather_app/models/hourlyForecast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_weather_app/models/dailyForecast.dart' hide Weather;

class WeatherApi {
  final String apiKey;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String latitude = '';
  String longitude = '';
  dailyForecast? dailyForecastData;
  List<Daily> forecastList = [];

  WeatherApi({required this.apiKey});

  Future<Map<String, dynamic>> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=imperial'));

    latitude = json.decode(response.body)['coord']['lat'].toString();
    longitude = json.decode(response.body)['coord']['lon'].toString();

    //print('API response: ${response.body}\n');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<dailyForecast?> getDailyForecastData(String cityName) async {
    String lat;
    String lon;
    final geocodeResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey'));

    if (geocodeResponse.statusCode == 200) {
      final Map<String, dynamic> geocodeData =
          json.decode(geocodeResponse.body)[0];
      lat = geocodeData['lat'].toString();
      lon = geocodeData['lon'].toString();
    } else {
      throw Exception('Failed to load geocode data');
    }

    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,current,alerts&units=imperial&appid=$apiKey'));

    if (response.statusCode == 200) {
      //print(response.body);

      final Map<String, dynamic> responseData = json.decode(response.body);

      List<Map<String, dynamic>> dailyData =
          List<Map<String, dynamic>>.from(responseData['daily']);

      List<Daily> dailyForecastList = [];

      for (Map<String, dynamic> day in dailyData) {
        int dt = day['dt'];
        num tempDay = day['temp']['day'];
        num tempNight = day['temp']['night'];
        //String weatherDescription = day['weather'][0]['description'];

        Daily newDay = Daily(
          dt: dt,
          temp: Temp(day: tempDay, night: tempNight),
          //weather: [Weather(description: weatherDescription)],
        );
        dailyForecastList.add(newDay);
      }
      forecastList = dailyForecastList;
      //print('Printing daily forecast ${forecastList[0]}');
      return dailyForecast.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load daily forecast data');
    }
  }

  Future<hourlyForecast?> getHourlyForecastData(String cityName) async {
    String lat;
    String lon;
    final geocodeResponse = await http.get(Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey'));

    if (geocodeResponse.statusCode == 200) {
      final Map<String, dynamic> geocodeData =
          json.decode(geocodeResponse.body)[0];
      lat = geocodeData['lat'].toString();
      lon = geocodeData['lon'].toString();
    } else {
      throw Exception('Failed to load geocode data');
    }

    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,daily,current,alerts&units=imperial&appid=$apiKey'));

    if (response.statusCode == 200) {
      //print(response.body);

      final Map<String, dynamic> responseData = json.decode(response.body);

      List<Map<String, dynamic>> hourlyData =
          List<Map<String, dynamic>>.from(responseData['hourly']);

      List<Hourly> hourlyForecastList = [];

      for (Map<String, dynamic> hour in hourlyData) {
        int dt = hour['dt'];
        String icon = hour['weather'][0]['icon'];
        num temp = hour['temp'];
        num windSpeed = hour['wind_speed'];

        Hourly newHour = Hourly(
          dt: dt,
          temp: temp,
          windSpeed: windSpeed,
          weather: [Weather(icon: icon)],
        );
        hourlyForecastList.add(newHour);
      }

      return hourlyForecast.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load hourly forecast data');
    }
  }

  Future<Map<String, dynamic>> getHourlyForecast(String cityName,
      [hours]) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=52.2298&lon=21.0118&exclude=daily,minutely,current,alerts&units=imperial&appid=$apiKey'));

    //print('Get hourly forecast response: ${response.body}');
    //print('lat: $lat, lon: $lon');
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load hourly forecast data');
    }
  }

  Future<Map<String, dynamic>> getDailyForecast(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=52.2298&lon=21.0118&exclude=minutely,hourly,current,alerts&units=imperial&appid=$apiKey'));

    //print('Get daily forecast response: ${response.body}');
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load daily forecast data');
    }
  }

  Future<List<Map<String, dynamic>>> getPrecipitationForecast(
      String cityName) async {
    String lat;
    String lon;

    try {
      final geocodeResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey'));

      if (geocodeResponse.statusCode == 200) {
        final Map<String, dynamic> geocodeData =
            json.decode(geocodeResponse.body)[0];
        lat = geocodeData['lat'].toString();
        lon = geocodeData['lon'].toString();
      } else {
        throw Exception(
            'Failed to load geocode data: ${geocodeResponse.statusCode}');
      }

      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,current,alerts&units=imperial&appid=$apiKey'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        List<Map<String, dynamic>> specificFieldsList = [];

        for (Map<String, dynamic> day in responseData['daily']) {
          int dt = day['dt'];
          num clouds = day['clouds'];
          num? rain = day['rain'];
          num? snow = day['snow'];

          Map<String, dynamic> specificFields = {
            'dt': dt,
            'clouds': clouds,
            'rain': rain,
            'snow': snow,
          };

          specificFieldsList.add(specificFields);
        }

        return specificFieldsList;
      } else {
        throw Exception(
            'Failed to load daily forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getPrecipitationForecast: $e');
      rethrow;
    }
  }
}
