// lib/services/usage_service.dart
import 'dart:async';
import 'dart:typed_data';
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

  Stream<String> get distractionStream => _distractionStreamController.stream;

  UsageService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onDistraction') {
      final String? packageName = call.arguments as String?;
      if (packageName != null) {
        _distractionStreamController.add(packageName);
      }
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
  Future<void> startMonitoring({required List<String> appsToMonitor}) async {
    if (appsToMonitor.isEmpty) return;
    try {
      await _channel.invokeMethod('startMonitoring', {'appsToMonitor': appsToMonitor});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to start monitoring: '${e.message}'.");
      }
    }
  }

  Future<void> stopMonitoring() async {
    // Implementation for later
  }

  void dispose() {
    _distractionStreamController.close();
  }
}