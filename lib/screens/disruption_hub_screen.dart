// lib/screens/disruption_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r3/screens/breathing_activity_screen.dart';
import 'package:r3/screens/learning_activity_screen.dart';

class DisruptionHubScreen extends StatelessWidget {
  const DisruptionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.pause_circle_outline, size: 60, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                "A Mindful Pause",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                "You've opened a distracting app.\nChoose a better reward.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),

              // Option 1: Learn Something New
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                label: const Text("Learn Something New", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  // Directly navigate to the Learning Screen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LearningActivityScreen(topic: "a new skill"),
                  ));
                },
              ),
              const SizedBox(height: 16),

              // Option 2: Breathing Activity
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.air, color: Colors.white),
                label: const Text("Take a Breathing Break", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  // Directly navigate to the Breathing Screen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BreathingActivityScreen(),
                  ));
                },
              ),
              const SizedBox(height: 40),

              // Option 3: Continue to app
              TextButton(
                child: const Text("Continue to app anyway", style: TextStyle(color: Colors.white54)),
                onPressed: () {
                  // This force-exits the app, returning to the OS.
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}