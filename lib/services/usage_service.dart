// lib/services/usage_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  Future<String> startMonitoring({required List<String> appsToMonitor}) async {
    if (appsToMonitor.isEmpty) return "NO_APPS_SELECTED";
    try {
      final String? result = await _channel.invokeMethod('startMonitoring', {'appsToMonitor': appsToMonitor});
      return result ?? "UNKNOWN_ERROR";
    } on PlatformException catch (e) {
      if (kDebugMode) print("Failed to start monitoring: '${e.message}'.");
      return "PLATFORM_EXCEPTION";
    }
  }

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('getInstalledApps');
      if (result == null) return [];
      final sortedList = result.map((appMap) => AppInfo.fromMap(appMap)).toList();
      sortedList.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sortedList;
    } on PlatformException catch (e) {
      if (kDebugMode) print("Failed to get installed apps: '${e.message}'.");
      return [];
    }
  }

  void dispose() {
    _distractionStreamController.close();
  }
}