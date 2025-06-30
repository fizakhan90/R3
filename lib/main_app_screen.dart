// lib/screens/main_app_screen.dart
import 'package:flutter/material.dart';
import 'package:r3/screens/challenges_screen.dart'; // ✅ Import the new ChallengesScreen
import 'package:r3/screens/gamification/gamification_screen.dart';
import 'package:r3/screens/home_screen.dart';
import 'package:r3/screens/learning/learning_theme.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // ✅ Updated list of pages for the navigation
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    ChallengesScreen(), // Replaced Learn with Challenges
    GamificationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // ✅ Updated the navigation bar items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl_rounded), // New icon
            label: 'Challenges', // New label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'Progress',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: LearningTheme.surface,
        selectedItemColor: LearningTheme.accent,
        unselectedItemColor: LearningTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8.0,
      ),
    );
  }
}