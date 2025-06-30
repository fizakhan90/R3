import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/disruption_hub_screen.dart';
import 'package:r3/screens/learning/learning_activity_screen.dart'; // ✅ Make sure this exists
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
          // After dialog closes, restart monitoring
          Provider.of<AppState>(context, listen: false).startMonitoringService();
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
        color = Colors.green;
        icon = Icons.shield_outlined;
        break;
      case "PERMISSION_DENIED":
        message =
            "ACTION REQUIRED:\nPlease grant 'Usage Access' permission for R3 to work. Tap here to try opening settings again.";
        color = Colors.amber;
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
          Provider.of<AppState>(context, listen: false).startMonitoringService();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontSize: 16),
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
            title: const Text("R3 Dashboard"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "Welcome to R3",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  "You have ${appState.distractingApps.length} app(s) marked for interception.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                _buildStatusWidget(appState.monitoringStatus),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
