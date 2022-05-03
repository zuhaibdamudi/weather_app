import 'dart:convert';

import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

bool isLoading = false;
late LocationData _locationData;
late var weatherData;
late var oneCall;
late var dailyData;
late var icon;
late var icon2;

var today = DateTime.now();
var day1 = today.day.toString() + "/" + today.month.toString();
var day2 = today.add(Duration(days: 1)).day.toString() + "/" + today.add(Duration(days:1)).month.toString();
var day3 = today.add(Duration(days: 2)).day.toString() + "/" + today.add(Duration(days:2)).month.toString();
var day4 = today.add(Duration(days: 3)).day.toString() + "/" + today.add(Duration(days:3)).month.toString();
var day5 = today.add(Duration(days: 4)).day.toString() + "/" + today.add(Duration(days:4)).month.toString();
var day6 = today.add(Duration(days: 5)).day.toString() + "/" + today.add(Duration(days:5)).month.toString();

late final List<Feature> features;

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
  final response3 = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${long}&exclude=hourly,minutely&appid=e06b232367a3cf853b063117eeff93b3&units=metric'));
  isLoading = false;
  weatherData = json.decode(response.body);
  oneCall = json.decode(response2.body);
  dailyData = json.decode(response3.body);
  // print(dailyData);

  // print(weatherData);

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

  var day1Max = dailyData["daily"][0]["temp"]["max"]/50;
  var day2Max = dailyData["daily"][1]["temp"]["max"]/50;
  var day3Max = dailyData["daily"][2]["temp"]["max"]/50;
  var day4Max = dailyData["daily"][3]["temp"]["max"]/50;
  var day5Max = dailyData["daily"][4]["temp"]["max"]/50;
  var day6Max = dailyData["daily"][5]["temp"]["max"]/50;
  print(day1Max);
  print(day2Max);
  print(day3Max);
  print(day4Max);
  print(day5Max);
  print(day6Max);

  var day1Min = dailyData["daily"][0]["temp"]["min"]/50;
  var day2Min = dailyData["daily"][1]["temp"]["min"]/50;
  var day3Min = dailyData["daily"][2]["temp"]["min"]/50;
  var day4Min = dailyData["daily"][3]["temp"]["min"]/50;
  var day5Min = dailyData["daily"][4]["temp"]["min"]/50;
  var day6Min = dailyData["daily"][5]["temp"]["min"]/50;

  features = [
    Feature(
      title: "Max Temp",
      color: Colors.deepOrange,
      data: [day1Max, day2Max, day3Max, day4Max, day5Max, day6Max],
    ),
    Feature(
      title: "Min Temp",
      color: Colors.lightBlue,
      data: [day1Min, day2Min, day3Min, day4Min, day5Min, day6Min],
    ),
  ];


  // print(await http.read(Uri.parse('https://example.com/foobar.txt')));

  return true;
}

class _WeatherPageState extends State<WeatherPage> {
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
      backgroundColor: Color(0xFFF7F7F7),
      body: Center(
        child: Container(
          // color: Colors.white,
          margin: EdgeInsets.all(10),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        // Icons.calendar_today_outlined,
                        FontAwesomeIcons.calendar,
                        size: 22,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "DAILY SUMMARY",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          weatherData["weather"][0]["main"],
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        // Icon(
                        //   FontAwesomeIcons.cloudShowersHeavy,
                        //   size: 50,
                        // ),
                        Image.network('http://openweathermap.org/img/wn/${icon}@2x.png'),
                      ]
                  ),
                  SizedBox(height: 10),
                  Neumorphic(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    style: NeumorphicStyle(
                      // shadowLightColor: Colors.grey,
                      depth: 5,
                      intensity: 0.5,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(18)),
                      color: Color(0xFFF6F6F6),
                    ),
                    child: Container(
                      height: 160,

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Center(
                                  child: Icon(
                                    icon2,
                                    size: 70,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Container(
                                  child: Column(
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        DateFormat.yMMMEd().format(DateTime.now()),
                                        // "${DateFormat.yMMMEd().format(DateTime.fromMillisecondsSinceEpoch(weatherData['dt'] * 1000))}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            // "23°",
                                            "${weatherData["main"]["temp_max"].round()}°",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 50,
                                            ),
                                          ),
                                          Text(
                                            "${weatherData["main"]["temp_min"].round()}°",
                                            style: TextStyle(
                                              color: Color(0xFFCED4E8),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 50,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        // weatherData["weather"][0]["description"],
                                        "${weatherData["weather"][0]["description"].toString()[0].toUpperCase()}${weatherData["weather"][0]["description"].toString().substring(1).toLowerCase()}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Icon(FontAwesomeIcons.cloudRain, size:20),
                                  SizedBox(width: 5),
                                  Text("${oneCall["minutely"][0]["precipitation"]}%"),
                                ],
                              ),
                              Row(
                                  children: [
                                    Icon(FontAwesomeIcons.droplet, size: 20,),
                                    SizedBox(width: 5),
                                    Text("${weatherData["main"]["humidity"]}%"),
                                  ]
                              ),

                              Row(
                                  children: [
                                    Icon(FontAwesomeIcons.wind, size: 20,),
                                    SizedBox(width: 5),
                                    Text("${weatherData["wind"]["speed"]} ms",)
                                  ]
                              ),
                              Row(
                                  children: [
                                    Icon(Icons.wb_sunny_rounded),
                                    SizedBox(width: 5),
                                    Text("4")
                                  ]
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text("Temperature Chart"),
                  LineGraph(
                    features: features,
                    size: Size(400, 200),
                    labelX: [day1, day2, day3, day4, day5, day6],
                    labelY: ['0°C', '10°C', '20°C', '30°C', '40°C', '50°C'],
                    showDescription: false,
                    graphColor: Colors.black,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
