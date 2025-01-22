import 'package:flutter/material.dart';
import 'package:earthquake_trackerr/pages/home_page.dart';
import 'package:earthquake_trackerr/pages/map_page.dart';
import 'package:earthquake_trackerr/pages/saved_earthquakes_page.dart';
import 'package:earthquake_trackerr/widgets/bottom_navigator.dart';
class MainScreen extends StatefulWidget {
  static String route = 'mainscreen-page';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MapPage(),
    SavedEarthquakesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigator(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
