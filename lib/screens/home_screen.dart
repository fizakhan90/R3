// lib/screens/home_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/disruption_hub_screen.dart';
import 'package:r3/services/app_state.dart';
import 'package:r3/services/usage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // We need an instance of UsageService to access the stream
  final UsageService _usageService = UsageService();
  StreamSubscription? _distractionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      
      // Start monitoring
      appState.startMonitoringService();
      
      // --- THE NEW PART: LISTEN FOR DISTRACTIONS ---
      _distractionSubscription = _usageService.distractionStream.listen((packageName) {
        // When a distraction is detected, show the hub as a dialog
        showDialog(
          context: context,
          barrierDismissible: false, // User must interact
          builder: (context) => const DisruptionHubScreen(),
        ).then((_) {
          // IMPORTANT: After the dialog is closed, restart monitoring.
          appState.startMonitoringService();
        });
      });
    });
  }

  @override
  void dispose() {
    // Always cancel subscriptions to avoid memory leaks
    _distractionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("R3 Dashboard"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 80, color: Colors.deepPurple),
                  const SizedBox(height: 24),
                  const Text(
                    "You're all set!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "R3 is now actively monitoring for your selected distractions. Close the app and let it work in the background.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 40),
                  if (appState.distractingApps.isNotEmpty)
                    Text(
                      "Monitoring ${appState.distractingApps.length} app(s).",
                      style: const TextStyle(color: Colors.white54),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}