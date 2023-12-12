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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Locations'),
      ),
      body: ListView.builder(
        itemCount: favoriteLocations.length,
        itemBuilder: (context, index) {
          final location = favoriteLocations[index];
          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(location),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await FavoriteLocations.removeFavoriteLocation(location);
                    _loadFavoriteLocations();
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherApp(city: location),
                ),
              );
            },
          );
        },
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
