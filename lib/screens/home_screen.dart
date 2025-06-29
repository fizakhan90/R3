// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/main.dart';
import 'package:r3/screens/disruption_hub_screen.dart';
import 'package:r3/services/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _distractionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMonitoring();
    });
  }

  void _startMonitoring() {
    final appState = Provider.of<AppState>(context, listen: false);
    _distractionSubscription?.cancel();
    _distractionSubscription = appState.usageService.distractionStream.listen((packageName) {
      // Temporarily stop listening to avoid multiple triggers
      _distractionSubscription?.pause();
      final currentContext = navigatorKey.currentContext;
      if (currentContext != null) {
        Navigator.of(currentContext).push(
          MaterialPageRoute(builder: (context) => const DisruptionHubScreen()),
        ).then((_) {
          // After the entire disruption flow is over, restart monitoring.
          appState.startMonitoringService();
          if (mounted) _distractionSubscription?.resume();
        });
      }
    });
  }

  @override
  void dispose() {
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Text("Welcome to R3", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                  "You have ${appState.distractingApps.length} app(s) marked for interception.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                ),
                const Spacer(),
                _buildStatusWidget(appState.monitoringStatus),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusWidget(String status) {
    String message; Color color; IconData icon;
    switch (status) {
      case "STARTED_SUCCESSFULLY": message = "Monitoring is active."; color = Colors.green; icon = Icons.shield_outlined; break;
      case "PERMISSION_DENIED": message = "ACTION REQUIRED: Grant Usage Access permission."; color = Colors.amber; icon = Icons.warning_amber_rounded; break;
      default: message = "Status: $status"; color = Colors.grey; icon = Icons.info_outline; break;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Text(message, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}