import 'package:flutter/material.dart';
import 'package:flutter_weather_app/services/weather_api.dart';

class PrecipitationForecast extends StatefulWidget {
  final String city;

  const PrecipitationForecast({Key? key, required this.city}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PrecipitationForecastState createState() => _PrecipitationForecastState();
}

class _PrecipitationForecastState extends State<PrecipitationForecast> {
  List<Map<String, dynamic>> precipitationForecastList = [];
  final apiKey = 'd52d75717fe982b4baa261365cd47eae';

  @override
  void initState() {
    super.initState();
    _loadPrecipitationForecast();
  }

  Future<void> _loadPrecipitationForecast() async {
    final weatherApi = WeatherApi(apiKey: apiKey);
    try {
      precipitationForecastList =
          await weatherApi.getPrecipitationForecast('Chicago');
      setState(() {
        precipitationForecastList = precipitationForecastList;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
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
          title: const Text('Precipitation Forecast'),
        ),
        body: precipitationForecastList.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: precipitationForecastList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = precipitationForecastList[index];
                  return ListTile(
                    title: Text('Date: ${_getFormattedDate(data['dt'])}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clouds: ${data['clouds']}'),
                        Text('Rain: ${data['rain']}'),
                        Text('Snow: ${data['snow']}'),
                      ],
                    ),
                  );
                },
              ));
  }
}
