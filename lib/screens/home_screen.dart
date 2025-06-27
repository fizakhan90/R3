// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/services/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Use Provider to access the AppState and start monitoring
    // We use addPostFrameCallback to ensure the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).startMonitoringService();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use a Consumer to listen for changes in AppState
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