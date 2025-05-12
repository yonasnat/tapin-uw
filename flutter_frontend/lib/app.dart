import 'package:flutter/material.dart';
import 'package:tapin/login.dart';
import 'package:tapin/explore_screen.dart';
import 'package:tapin/matchmaking_screen.dart';
import 'package:tapin/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Color(0xFFE9C983),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined, color: Colors.black45),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, color: Colors.black45),
            label: 'Matchmaking',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle, color: Colors.black45),
            label: 'Profile',
          ),
        ],
      ),
      body:
          <Widget>[
            EventsPage(),
            const MatchmakingScreen(),
            const ProfileScreen(),
          ][currentPageIndex],
    );
  }
}
