// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/home_screen.dart';
import 'package:r3/screens/onboarding/onboarding_screen.dart';
import 'package:r3/screens/learning_activity_screen.dart';
import 'package:r3/services/app_state.dart';
import 'package:r3/services/distraction_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
  
  runApp(MyApp(onboardingComplete: onboardingComplete));
}

// class MyApp extends StatelessWidget {
//   final bool onboardingComplete;
  
//   const MyApp({super.key, required this.onboardingComplete});

//   @override
//   Widget build(BuildContext context) {
//     // The ChangeNotifierProvider makes our AppState available everywhere
//     return ChangeNotifierProvider(
//       create: (context) => AppState(),
//       child: MaterialApp(
//         title: 'R3',
//         theme: ThemeData.dark().copyWith(
//           scaffoldBackgroundColor: Color(0xFF121212),
//           primaryColor: Colors.deepPurple,
//         ),
//         debugShowCheckedModeBanner: false,
//         home: onboardingComplete ? HomeScreen() : OnboardingScreen(),
//       ),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  
  const MyApp({super.key, required this.onboardingComplete});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'R3',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF121212),
          primaryColor: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: AppWrapper(onboardingComplete: onboardingComplete),
      ),
    );
  }
}

// New wrapper class to handle distraction monitoring
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
    return widget.onboardingComplete ? HomeScreen() : OnboardingScreen();
  }
}