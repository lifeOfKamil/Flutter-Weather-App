import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_weather_app/models/dailyForecast.dart';

class PrecipitationOverviewScreen extends StatefulWidget {
  final String city;
  final dailyForecast? dailyForecastData;

  const PrecipitationOverviewScreen(
      {Key? key, required this.city, this.dailyForecastData})
      : super(key: key);

  @override
  PrecipitationOverviewScreenState createState() =>
      PrecipitationOverviewScreenState();
}

class PrecipitationOverviewScreenState
    extends State<PrecipitationOverviewScreen> {
  List<FlSpot> temperatureData = [];
  List<FlSpot> chanceOfRainData = [];

  @override
  void initState() {
    super.initState();
    if (widget.dailyForecastData != null) {
      setDataFromDailyForecast(widget.dailyForecastData!);
    }
  }

  void setDataFromDailyForecast(dailyForecast forecast) {
    List<Daily>? dailyList = forecast.daily;

    if (dailyList != null) {
      temperatureData.clear();
      chanceOfRainData.clear();

      for (int i = 0; i < dailyList.length; i++) {
        temperatureData
            .add(FlSpot(i.toDouble(), dailyList[i].temp!.day!.toDouble()));
        chanceOfRainData
            .add(FlSpot(i.toDouble(), dailyList[i].pop!.toDouble() * 100));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 21, 34),
        appBar: AppBar(
          title: const Text(
            'Precipitation Overview',
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
        ),
        body: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                'Upcoming Forecast for ${widget.city}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Raleway',
                  color: Colors.white,
                ),
              ),
            ),
            lineChartWidget()
          ],
        )));
  }

  Widget lineChartWidget() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          backgroundColor: Colors.white.withOpacity(0.07),
          borderData: FlBorderData(show: true),
          gridData: const FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: temperatureData,
              isCurved: true,
              color: Colors.redAccent,
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: chanceOfRainData,
              isCurved: true,
              color: Colors.lightBlueAccent,
              preventCurveOverShooting: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
