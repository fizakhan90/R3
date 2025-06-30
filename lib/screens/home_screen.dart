// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/disruption_hub_screen.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:r3/services/app_state.dart';
import 'package:r3/services/usage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsageService _usageService = UsageService();
  StreamSubscription? _distractionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.startMonitoringService();

      _distractionSubscription =
          _usageService.distractionStream.listen((packageName) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const DisruptionHubScreen(),
        ).then((_) {
          Provider.of<AppState>(context, listen: false)
              .startMonitoringService();
        });
      });
    });
  }

  @override
  void dispose() {
    _distractionSubscription?.cancel();
    super.dispose();
  }

 

  Widget _buildStatusWidget(String status) {
    String message;
    Color color;
    IconData icon;

    switch (status) {
      case "STARTED_SUCCESSFULLY":
        message = "Monitoring is active. R3 is working in the background.";
        color = Colors.greenAccent;
        icon = Icons.shield_outlined;
        break;
      case "PERMISSION_DENIED":
        message =
            "ACTION REQUIRED: Please grant 'Usage Access' permission for R3 to work.";
        color = Colors.orangeAccent;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        message = "Status: $status";
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: () {
        if (status == "PERMISSION_DENIED") {
          Provider.of<AppState>(context, listen: false)
              .startMonitoringService();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to R3",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "You have ${appState.distractingApps.length} app(s) marked for interception.",
                  style: const TextStyle(color: LearningTheme.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 32),
                
               

                const Spacer(),
                _buildStatusWidget(appState.monitoringStatus),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}