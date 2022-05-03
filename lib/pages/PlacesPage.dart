import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class PlacesPage extends StatefulWidget {
  const PlacesPage({Key? key}) : super(key: key);

  @override
  _PlacesPageState createState() => _PlacesPageState();
}

bool isLoading = false;
late LocationData _locationData;
late var weatherData;
late var oneCall;
late var icon;
late var icon2;

Future<bool> findLocation() async {
  isLoading = true;
  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      // return true;
    }
  }

  _locationData = await location.getLocation();
  print(_locationData);

  var lat = _locationData.latitude;
  var long = _locationData.longitude;

  // https://api.openweathermap.org/data/2.5/weather?lat=13.3468223&lon=74.7966688&appid=e06b232367a3cf853b063117eeff93b3&units=metric
  // https://api.openweathermap.org/data/2.5/weather?lat=13.3468206&lon=74.7966463&appid=e06b232367a3cf853b063117eeff93b3

  final response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${long}&appid=e06b232367a3cf853b063117eeff93b3&units=metric'));
  final response2 = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${long}&exclude=hourly,daily&appid=e06b232367a3cf853b063117eeff93b3'));
  isLoading = false;
  weatherData = json.decode(response.body);
  oneCall = json.decode(response2.body);

  icon = weatherData["weather"][0]["icon"];

  var main = weatherData["weather"][0]["main"].toString();
  if(main == "Clouds")
    icon2 = Icons.cloud_queue_rounded;
  else if(main == "Thunderstorm")
    icon2 = FontAwesomeIcons.thunderstorm;
  else if(main == "Drizzle")
    icon2 = FontAwesomeIcons.cloudRain;
  else if(main == 'Rain')
    icon2 = FontAwesomeIcons.cloudShowersHeavy;
  else if(main == "Snow")
    icon2 = FontAwesomeIcons.snowflake;
  else if(main == "Atmosphere")
    icon2 = FontAwesomeIcons.cloudSun;
  else
    icon2 = FontAwesomeIcons.sun;

  // print(await http.read(Uri.parse('https://example.com/foobar.txt')));

  return true;
}

class _PlacesPageState extends State<PlacesPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: findLocation(),
        builder: (context, snap) {
          if(snap.hasData == null)
          {
            return Container(
              color: Colors.red,
            );
          }
          else
          {
            return isLoading == true ?
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Loading weather data..."),
                  ],
                )
            )
                : SafeArea(
              bottom: false,
              child: buildPage(),
            );
          }
        }
    );
  }

  Widget buildPage()
  {
    return Scaffold(
      body: Center(
        child: Container(
          // color: Colors.white,
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 25,
                  ),
                  Text(
                    weatherData["name"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                DateFormat.yMMMEd().format(DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 50),
              Neumorphic(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                style: NeumorphicStyle(
                    depth: 5,
                    intensity: 0.5,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(18)),
                    color: Color(0xFFF5F5F5)
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  height: 130,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${weatherData["main"]["temp"].round()}°",
                            style: TextStyle(
                              fontSize: 70,
                            ),
                          ),
                          Text(
                            "Real Feel: ${weatherData["main"]["feels_like"].round()}°",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.cloud_queue,
                            size: 60,
                          ),
                          Text(
                            weatherData["weather"][0]["main"],
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 250,
                padding: EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Humidity"),
                        Text("UV Index"),
                        Text("Wind speed"),
                        Text("Rain probability"),
                        Text("Pressure"),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${weatherData["main"]["humidity"]}%"),
                        Text("${oneCall["current"]["uvi"]}"),
                        Text("${weatherData["wind"]["speed"]} m/s"),
                        Text("${oneCall["minutely"][0]["precipitation"]}%"),
                        Text("${weatherData["main"]["pressure"]} hPa"),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
