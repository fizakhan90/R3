// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/main_app_screen.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:r3/screens/onboarding/onboarding_screen.dart';
import 'package:r3/services/app_state.dart';
import 'package:r3/services/distraction_monitor.dart';
import 'package:r3/services/user_progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

  // Load user progress from local storage before the app runs
  await UserProgressService.instance.loadProgress();
  
  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider.value(value: UserProgressService.instance),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'R3',
        theme: LearningTheme.theme,
        debugShowCheckedModeBanner: false,
        home: AppWrapper(onboardingComplete: onboardingComplete),
      ),
    );
  }
}

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
    return widget.onboardingComplete ? const MainAppScreen() : const OnboardingScreen();
  }
}