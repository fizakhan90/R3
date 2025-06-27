// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:r3/screens/home_screen.dart';
import 'package:r3/screens/onboarding/pages/select_apps_page.dart';
import 'package:r3/screens/onboarding/pages/set_goal_pages.dart';
import 'package:r3/screens/onboarding/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // We will store the user's choices here
  final Set<String> _selectedAppPackages = {};
  int _screenTimeGoal = 60; // Default goal

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  // This function is called from the "Select Apps" page
  void _onAppSelected(String packageName, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedAppPackages.add(packageName);
      } else {
        _selectedAppPackages.remove(packageName);
      }
    });
  }

  // This function is called from the "Set Goal" page
  void _onGoalChanged(int newGoal) {
    setState(() {
      _screenTimeGoal = newGoal;
    });
  }

  // This function saves everything and moves to the HomeScreen
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    await prefs.setStringList('distractingApps', _selectedAppPackages.toList());
    await prefs.setInt('screenTimeGoal', _screenTimeGoal);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // These are the pages of our survey
    final pages = [
      const WelcomePage(),
      SelectAppsPage(
        onAppSelected: _onAppSelected,
        selectedApps: _selectedAppPackages,
      ),
      SetGoalPage(
        onGoalChanged: _onGoalChanged,
        initialGoal: _screenTimeGoal,
        onFinished: _completeOnboarding,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: pages,
              ),
            ),
            // The progress dots at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: PageViewDotIndicator(
                currentItem: _currentPage,
                count: pages.length,
                unselectedColor: Colors.grey.shade700,
                selectedColor: Colors.white,
                size: const Size(12, 12),
                unselectedSize: const Size(8, 8),
                duration: const Duration(milliseconds: 200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}