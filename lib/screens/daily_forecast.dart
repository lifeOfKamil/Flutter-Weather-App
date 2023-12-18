import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/dailyForecast.dart';
import 'package:flutter_weather_app/screens/favorite_locations.dart';
import 'package:flutter_weather_app/screens/weather_app.dart';
import 'package:flutter_weather_app/services/weather_api.dart';

class DailyForecast extends StatefulWidget {
  String city;
  DailyForecast({super.key, required this.city});

  @override
  _DailyForecastState createState() => _DailyForecastState();
}

class _DailyForecastState extends State<DailyForecast> {
  final apiKey = 'd52d75717fe982b4baa261365cd47eae';
  late WeatherApi weatherApi = WeatherApi(apiKey: apiKey);

  int _currentIndex = 0;
  List<Daily>? forecastList = [];

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

  void navigateToDailyForecast() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DailyForecast(city: widget.city)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 21, 34),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 21, 34),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.city,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Text(
                'Daily Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: forecastList!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 6.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minVerticalPadding: 24,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(223, 12, 17, 30),
        onItemSelected: (index) {
          setState(() {
            if (index == 0) {
              _currentIndex = index;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WeatherApp(city: widget.city)));
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
}
