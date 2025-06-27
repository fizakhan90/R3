// lib/services/app_state.dart
import 'package:flutter/material.dart';
import 'package:r3/services/usage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  final UsageService _usageService = UsageService();
  List<String> _distractingApps = [];
  int _screenTimeGoal = 60;

  List<String> get distractingApps => _distractingApps;
  int get screenTimeGoal => _screenTimeGoal;

  AppState() {
    _loadPreferences();
  }

  // Load saved choices from the device
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _distractingApps = prefs.getStringList('distractingApps') ?? [];
    _screenTimeGoal = prefs.getInt('screenTimeGoal') ?? 60;
    notifyListeners();
  }

  // Tell the UsageService to start its work
  void startMonitoringService() {
    // First, make sure we have the latest data
    _loadPreferences().then((_) {
      _usageService.startMonitoring(appsToMonitor: _distractingApps);
    });
  }
}