// lib/services/app_state.dart
import 'package:flutter/material.dart';
import 'package:r3/services/usage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class holds the application's state and acts as a central
// point for business logic. It uses the ChangeNotifier mixin so that
// widgets can subscribe to its changes using Provider.
class AppState with ChangeNotifier {
  // A single instance of our service bridge to the native side.
  final UsageService _usageService = UsageService();
  
  // --- State Variables ---
  // These hold the data for our app. They are private.
  List<String> _distractingApps = [];
  int _screenTimeGoal = 60;
  
  // This holds the status of the monitoring service (e.g., "STARTED_SUCCESSFULLY").
  String monitoringStatus = "Initializing...";
  
  // --- NEW --- This holds the live name of the foreground app for debugging.
  String currentForegroundApp = "No data yet...";

  // --- Public Getters ---
  // This is how UI widgets can safely read the state data.
  List<String> get distractingApps => _distractingApps;
  int get screenTimeGoal => _screenTimeGoal;

  // --- Constructor ---
  // This code runs once when the AppState is first created in main.dart.
  AppState() {
    // We set up a permanent listener to the foregroundAppStream from our service.
    // Whenever the native code sends a new foreground app name...
    _usageService.foregroundAppStream.listen((appName) {
      // ...we update our state variable...
      currentForegroundApp = appName;
      // ...and we notify all listening widgets to rebuild themselves.
      notifyListeners();
    });
  }
  
  // --- Logic Method ---
  // This method contains the logic for starting the monitoring process.
  Future<void> startMonitoringService() async {
    // Update the UI to show we're starting the process.
    monitoringStatus = "Loading Preferences...";
    notifyListeners();

    // Load the user's saved choices from the phone's storage.
    final prefs = await SharedPreferences.getInstance();
    _distractingApps = prefs.getStringList('distractingApps') ?? [];
    
    // Call the service to start monitoring and wait for its response.
    final result = await _usageService.startMonitoring(appsToMonitor: _distractingApps);
    
    // Update the status with the result from the native code.
    monitoringStatus = result;
    // Notify the UI again to show the final status (e.g., green or yellow box).
    notifyListeners();
  }
}