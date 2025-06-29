// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/home_screen.dart';
import 'package:r3/screens/onboarding/onboarding_screen.dart';
import 'package:r3/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This GlobalKey is the correct way to handle navigation from background events.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        navigatorKey: navigatorKey, // Assign the key here
        title: 'R3',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: onboardingComplete ? const AppWrapper() : const OnboardingScreen(),
      ),
    );
  }
}

// This wrapper correctly initializes the monitoring service when the app starts.
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).startMonitoringService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}