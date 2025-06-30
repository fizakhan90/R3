// lib/screens/onboarding/pages/permissions_page.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r3/screens/learning/learning_theme.dart';

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

  // Check the permission status without requesting it.
  Future<void> _checkPermissionStatus() async {
    final status = await Permission.systemAlertWindow.status;
    if (mounted) {
      setState(() {
        _isPermissionGranted = status.isGranted;
      });
    }
  }

  // Request the permission and update the state.
  Future<void> _requestPermission() async {
    final status = await Permission.systemAlertWindow.request();
    if (mounted) {
      setState(() {
        _isPermissionGranted = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A more intuitive icon for "display over other apps"
          Icon(
            Icons.layers_clear_outlined,
            size: 64,
            color: LearningTheme.accent,
          ),
          const SizedBox(height: 24),
          Text(
            "Final Permission",
            style: textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: LearningTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "R3 needs permission to 'Display over other apps' to show you helpful breaks. This is the core function of the app.",
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // --- Themed Primary Action Button ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPermissionGranted ? Colors.green.shade600 : LearningTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _isPermissionGranted ? null : _requestPermission,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPermissionGranted ? Icons.check_circle_outline : Icons.shield_outlined,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(_isPermissionGranted ? "Permission Granted" : "Grant Permission"),
              ],
            ),
          ),
          const SizedBox(height: 100),
          // --- Animated Finish Hint ---
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: _isPermissionGranted ? 1.0 : 0.0,
            child: _isPermissionGranted
                ? Column(
                    children: [
                      Icon(
                        Icons.swipe_left_outlined,
                        color: LearningTheme.textSecondary.withOpacity(0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You're all set! Swipe to finish.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: LearningTheme.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(), // Show nothing if permission isn't granted
          ),
        ],
      ),
    );
  }
}