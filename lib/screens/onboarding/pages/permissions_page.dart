// lib/screens/onboarding/pages/permissions_page.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  _PermissionsPageState createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.systemAlertWindow.status;
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.systemAlertWindow.request();
    setState(() {
      _isPermissionGranted = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.layers,
            size: 60,
            color: Colors.deepPurple.shade200,
          ),
          const SizedBox(height: 24),
          Text(
            "Final Permission",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "R3 needs permission to 'Display over other apps' to show the interception screen. This is the core function of the app.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPermissionGranted ? Colors.green : Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: Icon(_isPermissionGranted ? Icons.check_circle : Icons.shield_outlined),
            onPressed: _isPermissionGranted ? null : _requestPermission,
            label: Text(_isPermissionGranted ? "Permission Granted" : "Grant 'Display Over' Permission"),
          ),
          const SizedBox(height: 100),
          if (!_isPermissionGranted)
            const Text(
              "Please grant this permission to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.amber),
            )
          else
            const Column(
              children: [
                Icon(Icons.swipe_left_outlined, color: Colors.white38, size: 40),
                Text("You're all set! Swipe to finish.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
              ],
            )
        ],
      ),
    );
  }
}