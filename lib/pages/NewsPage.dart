import 'dart:convert';

import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

bool isLoading = false;
late LocationData _locationData;
late var weatherData;
late var dailyData;

var hour1, hour2, hour3, hour4, hour5, hour6;

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

  final response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${long}&exclude=daily,minutely&appid=e06b232367a3cf853b063117eeff93b3&units=metric'));
  isLoading = false;
  weatherData = json.decode(response.body);

  var today = DateTime.now();

  hour1 = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][0]["dt"] * 1000));
  hour2 = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][1]["dt"] * 1000));
  hour3 = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][2]["dt"] * 1000));
  hour4 = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][3]["dt"] * 1000));
  hour5 = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][4]["dt"] * 1000));
  hour6 = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][5]["dt"] * 1000));

  var hour1Temp = weatherData["hourly"][0]["temp"]/50;
  var hour2Temp = weatherData["hourly"][1]["temp"]/50;
  var hour3Temp = weatherData["hourly"][2]["temp"]/50;
  var hour4Temp = weatherData["hourly"][3]["temp"]/50;
  var hour5Temp = weatherData["hourly"][4]["temp"]/50;
  var hour6Temp = weatherData["hourly"][5]["temp"]/50;

  features = [
    Feature(
      title: "Temperature",
      color: Colors.lightBlue,
      data: [hour1Temp, hour2Temp, hour3Temp, hour4Temp, hour5Temp, hour6Temp],
    ),
  ];

  return true;
}

class _NewsPageState extends State<NewsPage> {



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
    var width = ((MediaQuery.of(context).size.width)/3)-20;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
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
                    // Icons.calendar_today_outlined,
                    FontAwesomeIcons.calendar,
                    size: 22,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "HOURLY SUMMARY",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Text(
                        // "${weatherData['current']['weather'][0]['description']}",
                        "${weatherData['current']['weather'][0]['description'].toString()[0].toUpperCase()}${weatherData['current']['weather'][0]['description'].toString().substring(1).toLowerCase()}",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ]
              ),
              SizedBox(height: 30),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(
                        // shadowLightColor: Colors.grey,
                        depth: 5,
                        intensity: 1,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                        color: Color(0xFFF5F5F5)
                      ),
                      child: Container(
                        width: width,
                        // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][0]["dt"] * 1000))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${weatherData['hourly'][0]['temp'].round()}°",
                                    style: TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][0]["humidity"]}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][0]["clouds"]}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][0]["wind_speed"]} ms",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][0]["uvi"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("${weatherData['hourly'][0]['weather'][0]['main']}",),
                          ],
                        ),
                      ),
                    ),
                    Neumorphic(
                      style: NeumorphicStyle(
                        // shadowLightColor: Colors.grey,
                        depth: 5,
                        intensity: 1,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                        color: Color(0xFFF5F5F5)
                      ),
                      child: Container(
                        width: width,
                        // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][1]["dt"] * 1000))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${weatherData['hourly'][1]['temp'].round()}°",
                                    style: TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][1]["humidity"]}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][1]["clouds"]}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][1]["wind_speed"]} ms",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][1]["uvi"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("${weatherData['hourly'][1]['weather'][0]['main']}",),
                          ],
                        ),
                      ),
                    ),
                    Neumorphic(
                      style: NeumorphicStyle(
                        // shadowLightColor: Colors.grey,
                        depth: 5,
                        intensity: 1,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                        color: Color(0xFFF5F5F5)
                      ),
                      child: Container(
                        width: width,
                        // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(weatherData['hourly'][2]["dt"] * 1000))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${weatherData['hourly'][2]['temp'].round()}°",
                                    style: TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][2]["humidity"]}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][2]["clouds"]}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][2]["wind_speed"]} ms",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    "${weatherData['hourly'][2]["uvi"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("${weatherData['hourly'][2]['weather'][0]['main']}",),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 30),
              Text("Temperature Chart"),
              LineGraph(
                features: features,
                size: Size(400, 200),
                labelX: [hour1, hour2, hour3, hour4, hour5, hour6],
                labelY: ['0°C', '10°C', '20°C', '30°C', '40°C', '50°C'],
                showDescription: false,
                graphColor: Colors.black,
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
