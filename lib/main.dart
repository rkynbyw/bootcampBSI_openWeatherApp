import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weather = 'Loading...';
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _temperature_c = 0.0;
  String _city = '';
  double _maxtemp = 0.0;
  double _mintemp = 0.0;
  String _weather_icon = '';

  @override
  void initState() {
    super.initState();
    _updateWeather();
  }

  Future<void> _updateWeather() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    final response = await http.get(
        Uri.parse('http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=yourAPIkey'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String weather = data['weather'][0]['description'];
      double temperature_k = data['main']['temp'];
      double temperature_c = temperature_k - 273.15;
      double maxtemp = data['main']['temp_max']-273.15;
      double mintemp = data['main']['temp_min']-273.15;
      String city = data['name'];
      String weather_icon = data['weather'][0]['icon'];

      setState(() {
        _weather = weather;
        _latitude = position.latitude;
        _longitude = position.longitude;
        _city = city;
        _temperature_c = temperature_c;
        _maxtemp = maxtemp;
        _mintemp = mintemp;
        _weather_icon = weather_icon;
      });
    } else {
      setState(() {
        _weather = 'Failed to load weather data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageLocation =
        'https://maps.googleapis.com/maps/api/staticmap?center=$_latitude,$_longitude=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$_latitude,$_longitude&key=yourAPIkey';
    String weatherIconURL =
        'http://openweathermap.org/img/w/$_weather_icon.png';
    return Scaffold(
        appBar: AppBar(
        title: Text(
          '$_city',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
          centerTitle: true,
          leading: Icon(Icons.add),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
      body: Container(
        height: 500,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                weatherIconURL,
                width: 50,

              ),
              Text(
                '$_weather',
                style: TextStyle(fontSize: 25),
              ),
              Text(
                '${_temperature_c.toStringAsFixed(1)}°C',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 65),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Lowest : ${_mintemp.toStringAsFixed(1)}°C'),
                  Text('Highest : ${_maxtemp.toStringAsFixed(1)}°C')
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Current Location : $_city',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 5),
              Image.network(
                imageLocation,
                width: 300,
              )
            ],
          ),
        ),
      )
    );
  }
}