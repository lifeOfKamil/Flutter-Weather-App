import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/dailyForecast.dart';
import 'package:flutter_weather_app/screens/weather_app.dart';
import 'package:flutter_weather_app/services/weather_api.dart';

class DailyForecast extends StatefulWidget {
  const DailyForecast({super.key});

  @override
  _DailyForecastState createState() => _DailyForecastState();
}

class _DailyForecastState extends State<DailyForecast> {
  final apiKey = 'd52d75717fe982b4baa261365cd47eae';
  List<Daily>? forecastList = [];
  late WeatherApi weatherApi = WeatherApi(apiKey: apiKey);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dailyForecastData =
          await weatherApi.getDailyForecastData('Chicago');
      setState(() {
        forecastList = dailyForecastData?.daily ?? [];
      });
    } catch (e) {
      print(e);
    }
  }

  String _getDayOfWeek(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  String _getFormattedDate(int? unixTimestamp, [format]) {
    if (unixTimestamp == null) {
      return '';
    }

    // Convert Unix timestamp to DateTime
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
    String formattedDate = '';
    // Format the DateTime as a string with day of the week and month name
    if (format == 1) {
      formattedDate = '${_getDayOfWeek(date.weekday)}';
    } else if (format == 2) {
      formattedDate = '${_getMonthName(date.month)} ${date.day}';
    } else {
      formattedDate =
          '${_getDayOfWeek(date.weekday)}, ${_getMonthName(date.month)} ${date.day}';
    }
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 21, 34),
      appBar: AppBar(
        title: const Text('Daily Forecast'),
      ),
      body: Material(
        color: const Color.fromARGB(255, 15, 21, 34),
        child: Column(
          children: [
            const Text(
              'Daily Forecast',
              style: TextStyle(color: Colors.white),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: forecastList!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: Colors.white.withOpacity(0.05),
                  title: Text(
                    _getFormattedDate(forecastList![index].dt as int?, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    _getFormattedDate(forecastList![index].dt as int?, 2),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.75,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${forecastList![index].temp?.day?.toInt().toString() ?? ''}°F',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.normal),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/w/${forecastList![index].weather![0].icon}.png',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
