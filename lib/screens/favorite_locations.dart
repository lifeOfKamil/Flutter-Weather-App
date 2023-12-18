import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_weather_app/screens/weather_app.dart';

class FavoriteLocationsScreen extends StatefulWidget {
  @override
  FavoriteLocationsScreenState createState() => FavoriteLocationsScreenState();
}

class FavoriteLocationsScreenState extends State<FavoriteLocationsScreen> {
  List<String> favoriteLocations = [];
  WeatherApp weatherApp = const WeatherApp(city: '');

  @override
  void initState() {
    super.initState();
    _loadFavoriteLocations();
  }

  Future<void> _loadFavoriteLocations() async {
    final locations = await FavoriteLocations.load();
    setState(() {
      favoriteLocations = locations;
    });
  }

  Color _getRandomColor(String cityName) {
    final random = Random(cityName.hashCode);
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
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

  void _removeCard(int index) {
    setState(() {
      favoriteLocations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 21, 34),
      appBar: AppBar(
        title: const Text(
          'Favorite Locations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: favoriteLocations.length,
          itemBuilder: (context, index) {
            String location = favoriteLocations[index];
            location = capitalizeEveryFirstLetter(location);
            return Card(
              color: Colors.white.withOpacity(0.05),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherApp(city: location),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              location,
                              style: TextStyle(
                                  color: _getRandomColor(location),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: InkWell(
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onTap: () async {
                          _removeCard(index);
                          FavoriteLocations.removeFavoriteLocation(location);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final userLocation = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              String userLocation = '';
              return AlertDialog(
                title: const Text('Add Favorite Location'),
                content: TextField(
                  onChanged: (value) {
                    userLocation = value;
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await FavoriteLocations.addFavoriteLocation(userLocation);
                      _loadFavoriteLocations();
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, userLocation);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
