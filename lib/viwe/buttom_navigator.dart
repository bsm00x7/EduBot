import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Analytics/analytics_page.dart';
import 'Home/home_page.dart';

class ButtomNavigator extends StatefulWidget {
  const ButtomNavigator({super.key});

  @override
  State<ButtomNavigator> createState() => _ButtomNavigatorState();
}

class _ButtomNavigatorState extends State<ButtomNavigator> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
  }
  void navScreen(int value) {
    setState(() {
      _currentIndex = value;
    });

    debugPrint(_currentIndex.toString());
  }

  List screen =[
    HomePage(),
    AnalyticsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.secondary,
        selectedItemColor: theme.colorScheme.onSecondary,
        currentIndex: _currentIndex,
        selectedLabelStyle: GoogleFonts.openSans( fontWeight: FontWeight.w400),
        onTap: (value) => navScreen(value),
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.message),
            label: "Chat",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartColumn),
            label: "Analytic",
          ),
        ],
      ),
      body: SafeArea(
        child: screen [_currentIndex],
      ),
    );
  }
}
