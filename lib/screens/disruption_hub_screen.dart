// lib/screens/disruption_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:r3/screens/learning_activity_screen.dart';
import 'package:r3/services/distraction_monitor.dart';

class DisruptionHubScreen extends StatelessWidget {
  const DisruptionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FloatingActionButton(
  onPressed: () {
    // Test the disruption screen
    DistractionMonitor.instance.testDisruptionScreen();
  },
  child: Icon(Icons.warning),
  tooltip: 'Test Disruption Screen',
),
              const Text(
                "A Mindful Pause",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                "You've opened a distracting app. Choose a better reward.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                label: const Text("Learn Something New", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  // Close the dialog and open the learning screen
                  Navigator.of(context).pop(); // Close this hub screen first
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LearningActivityScreen(), // Let's learn Chess for now
                  ));
                },
              ),
              const SizedBox(height: 16),
              // We'll add puzzle and breathing buttons here later
              TextButton(
                child: const Text("Continue to app anyway", style: TextStyle(color: Colors.white54)),
                onPressed: () {
                  // Just close the interception screen
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}