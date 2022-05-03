import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weather_app/pages/NewsPage.dart';
import 'package:weather_app/pages/PlacesPage.dart';
import 'package:weather_app/pages/WeatherPage.dart';

import 'PreferencePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  Widget? getBody(int index) {
    switch (index)
    {
      case 0:
        return WeatherPage();
      case 1:
        return PlacesPage();
      case 2:
        return NewsPage();
      case 3:
        return PreferencePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: getBody(_index),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        borderRadius: 30,
        elevation: 30,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF556FF7),
        selectedBackgroundColor: Colors.transparent,
        unselectedItemColor: Color(0xFF262F41),
        onTap: (int val) {
          setState(() => _index = val);
        },
        currentIndex: _index,
        items: [
          FloatingNavbarItem(icon: FontAwesomeIcons.cloudSun, title: 'Weather'),
          FloatingNavbarItem(icon: Icons.location_on_outlined, title: 'Places'),
          FloatingNavbarItem(icon: FontAwesomeIcons.newspaper, title: 'News'),
          FloatingNavbarItem(icon: Icons.person_rounded, title: 'Preference'),
        ],
      ),
    );
  }
}