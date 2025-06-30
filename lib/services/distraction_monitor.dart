// lib/services/distraction_monitor.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:r3/services/usage_service.dart';
import 'package:r3/screens/disruption_hub_screen.dart';

class DistractionMonitor {
  static DistractionMonitor? _instance;
  static DistractionMonitor get instance => _instance ??= DistractionMonitor._();
  
  DistractionMonitor._();
  
  final UsageService _usageService = UsageService();
  StreamSubscription<String>? _distractionSubscription;
  BuildContext? _context;
  bool _isDisruptionScreenShowing = false;
  
  // Initialize the monitor with app context
  void initialize(BuildContext context) {
    _context = context;
    _startListening();
  }
  
  void _startListening() {
    _distractionSubscription?.cancel();
    
    _distractionSubscription = _usageService.distractionStream.listen((packageName) {
      print('🚨 Distraction detected: $packageName');
      _showDisruptionScreen(packageName);
    });
  }
  
  // Future<void> _showDisruptionScreen(String packageName) async {
  //   // The overlay is now handled by native Android code
  //   // This is just for logging/analytics purposes
  //   print('🚨 Distraction logged for analytics: $packageName');
  //   _isDisruptionScreenShowing = false;
  // }
  Future<void> _showDisruptionScreen(String packageName) async {
  if (_context == null || _isDisruptionScreenShowing) return;

  _isDisruptionScreenShowing = true;

  await showDialog(
    context: _context!,
    barrierDismissible: false,
    builder: (context) => const DisruptionHubScreen(),
  );

  _isDisruptionScreenShowing = false;
}

  void dispose() {
    _distractionSubscription?.cancel();
    _usageService.dispose();
  }
  
  // Method to manually test the disruption screen
  void testDisruptionScreen() {
    if (_context != null) {
      _showDisruptionScreen('test.package');
    }
  }
}