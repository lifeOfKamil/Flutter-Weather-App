import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/hourlyForecast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HourlyForecastScreen extends StatefulWidget {
  final List<Hourly> hourlyForecastList;

  const HourlyForecastScreen({Key? key, required this.hourlyForecastList})
      : super(key: key);

  @override
  HourlyForecastScreenState createState() => HourlyForecastScreenState();
}

class HourlyForecastScreenState extends State<HourlyForecastScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 21, 34),
      appBar: AppBar(
        title: const Text(
          '24-Hour Forecast',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 15, 21, 34),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Weather',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Current / Real Feel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Wind',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            _buildHourlyForecastList(),
          ],
        ),
      ),
    );
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
      return formattedTime;
    }
  }

  Widget _buildHourlyForecastList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.hourlyForecastList.length,
      itemBuilder: (context, index) {
        final hourlyData = widget.hourlyForecastList[index];

        // Format the time using your _getFormattedTime method
        final formattedTime = _getFormattedTime(hourlyData.dt as int);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            color: Colors.white.withOpacity(0.05),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Image.network(
                    'https://openweathermap.org/img/wn/${hourlyData.weather?[0].icon}.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${hourlyData.temp?.toInt()}° / ${hourlyData.feelsLike?.toInt()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        ' ${hourlyData.windSpeed?.toInt()}mph',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
