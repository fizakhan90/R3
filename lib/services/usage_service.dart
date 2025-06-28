// lib/services/usage_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// A simple data model for an installed application.
class AppInfo {
  final String name;
  final String packageName;
  final Uint8List? icon;

  AppInfo({required this.name, required this.packageName, this.icon});

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppInfo(
      name: map['name'] ?? 'Unknown App',
      packageName: map['packageName'] ?? '',
      icon: map['icon'] as Uint8List?,
    );
  }
}

// This service class is our bridge to the native Android platform.
class UsageService {
  static const _channel = MethodChannel('com.r3.app/usage_stats');
  final StreamController<String> _distractionStreamController = StreamController.broadcast();
  
  // --- NEW --- Add a new stream for the live debug data
  final StreamController<String> _foregroundAppStreamController = StreamController.broadcast();

  Stream<String> get distractionStream => _distractionStreamController.stream;
  // --- NEW --- Expose the new stream
  Stream<String> get foregroundAppStream => _foregroundAppStreamController.stream;

  UsageService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // --- MODIFIED --- Update the handler to listen for both messages
  Future<void> _handleMethodCall(MethodCall call) async {
    final String? packageName = call.arguments as String?;
    if (packageName == null) return;

    switch (call.method) {
      case 'onDistraction':
        _distractionStreamController.add(packageName);
        break;
      case 'onForegroundAppUpdate': // Listen for our new debug message
        _foregroundAppStreamController.add(packageName);
        break;
    }
  }


  // --- THIS IS THE FUNCTION WE NEED RIGHT NOW ---
  // It asks the native code for the list of installed apps.
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('getInstalledApps');
      if (result == null) return [];
      return result.map((appMap) => AppInfo.fromMap(appMap)).toList();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to get installed apps: '${e.message}'.");
      }
      return [];
    }
  }

  // --- WE WILL USE THESE FUNCTIONS LATER ---
Future<String> startMonitoring({required List<String> appsToMonitor}) async {
    if (appsToMonitor.isEmpty) {
      return "NO_APPS_SELECTED";
    }
    try {
      // It now returns the String message from the native side.
      final String? result = await _channel.invokeMethod('startMonitoring', {'appsToMonitor': appsToMonitor});
      return result ?? "UNKNOWN_ERROR";
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to start monitoring: '${e.message}'.");
      }
      return "PLATFORM_EXCEPTION";
    }
  }

  Future<void> stopMonitoring() async {
    // Implementation for later
  }

  void dispose() {
    _distractionStreamController.close();
  }
}