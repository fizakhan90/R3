// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/main_app_screen.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:r3/screens/onboarding/onboarding_screen.dart';
import 'package:r3/services/app_state.dart';
import 'package:r3/services/distraction_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  
  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  
  const MyApp({super.key, required this.onboardingComplete});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'R3',
        // Apply the consistent, polished theme across the entire app
        theme: LearningTheme.theme,
        debugShowCheckedModeBanner: false,
        // The AppWrapper is the perfect place to route the user
        home: AppWrapper(onboardingComplete: onboardingComplete),
      ),
    );
  }
}

/// This wrapper handles app-wide concerns like distraction monitoring
/// and now also routes the user to the correct initial screen.
class AppWrapper extends StatefulWidget {
  final bool onboardingComplete;
  
  const AppWrapper({super.key, required this.onboardingComplete});
  
  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize distraction monitoring after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DistractionMonitor.instance.initialize(context);
    });
  }
  
  @override
  void dispose() {
    DistractionMonitor.instance.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // If onboarding is not complete, show that first.
    // Otherwise, show the main app with its bottom navigation bar.
    return widget.onboardingComplete ? const MainAppScreen() : const OnboardingScreen();
  }
}