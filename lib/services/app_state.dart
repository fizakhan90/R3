// lib/services/app_state.dart
import 'package:flutter/material.dart';
import 'package:r3/services/usage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  final UsageService _usageService = UsageService();
  List<String> _distractingApps = [];
  String monitoringStatus = "Initializing...";

  List<String> get distractingApps => _distractingApps;
  UsageService get usageService => _usageService;

  Future<void> startMonitoringService() async {
    monitoringStatus = "Loading Preferences...";
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _distractingApps = prefs.getStringList('distractingApps') ?? [];
    final result = await _usageService.startMonitoring(appsToMonitor: _distractingApps);
    monitoringStatus = result;
    notifyListeners();
  }
}