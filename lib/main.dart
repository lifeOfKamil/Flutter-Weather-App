import 'package:flutter/material.dart';
import 'package:flutter_weather_app/screens/weather_app.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      initialRoute: '/',
      routes: {
        '/': (context) => const WeatherApp(
              city: 'Chicago',
            ),
      }));
}
