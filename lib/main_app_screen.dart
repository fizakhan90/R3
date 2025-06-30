// lib/screens/main_app_screen.dart
import 'package:flutter/material.dart';
import 'package:r3/screens/gamification/gamification_screen.dart'; // Import your new screens
import 'package:r3/screens/home_screen.dart';
import 'package:r3/screens/learning/learning_activity_screen.dart';
import 'package:r3/screens/learning/learning_theme.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // List of the main pages for your navigation
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    LearningActivityScreen(),
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
      // IndexedStack is used to preserve the state of each page.
      // When you switch tabs, the previous tab's state (e.g., scroll position) is not lost.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_rounded),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'Progress',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Styling to match our modern theme
        backgroundColor: LearningTheme.surface,
        selectedItemColor: LearningTheme.accent,
        unselectedItemColor: LearningTheme.textSecondary,
        type: BottomNavigationBarType.fixed, // Good for 3-5 items
        showUnselectedLabels: true,
        elevation: 8.0,
      ),
    );
  }
}