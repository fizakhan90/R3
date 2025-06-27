// lib/screens/onboarding/pages/welcome_page.dart
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "R³",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Reboot. Reform. Rebuild.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Welcome to a more mindful way of using your phone. Let's set up your goals.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 100),
          const Icon(
            Icons.swipe_left_outlined,
            color: Colors.white38,
            size: 40,
          ),
          const Text(
            "Swipe to begin",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
            ),
          )
        ],
      ),
    );
  }
}