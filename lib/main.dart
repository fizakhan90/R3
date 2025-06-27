import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/home_screen.dart';
import 'package:r3/screens/onboarding/onboarding_screen.dart';
import 'package:r3/screens/learning_activity_screen.dart';
import 'package:r3/services/app_state.dart';
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
    // The ChangeNotifierProvider makes our AppState available everywhere
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'R3',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF121212),
          primaryColor: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: LearningActivityScreen()
      ),
    );
  }
}