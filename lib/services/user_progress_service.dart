// lib/services/user_progress_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService with ChangeNotifier {
  // --- Singleton Pattern ---
  UserProgressService._privateConstructor();
  static final UserProgressService instance = UserProgressService._privateConstructor();

  // --- Private State ---
  int _totalXP = 0;
  int _currentLevel = 1;

  // --- Public Getters ---
  int get totalXP => _totalXP;
  int get currentLevel => _currentLevel;
  
  /// Calculates the XP needed to reach the next level from the start of the current one.
  int get xpForNextLevel => _currentLevel * 250;
  
  /// Calculates the XP earned within the current level.
  int get xpInCurrentLevel {
    if (_currentLevel == 1) return _totalXP;
    
    // Calculate the cumulative XP required for all previous levels
    int previousLevelsXpThreshold = 0;
    for (int i = 1; i < _currentLevel; i++) {
        previousLevelsXpThreshold += i * 250;
    }
    return _totalXP - previousLevelsXpThreshold;
  }
  
  /// Calculates the total cumulative XP required to reach the current level.
  int get currentLevelTotalXpThreshold {
      if (_currentLevel == 1) return 0;
      int threshold = 0;
      for (int i = 1; i < _currentLevel; i++) {
          threshold += i * 250;
      }
      return threshold;
  }

  /// Adds XP and checks for level-ups.
  void addXP(int amount) {
    _totalXP += amount;
    print("Added $amount XP. New total: $_totalXP");

    // Check if the user has leveled up by comparing total XP with the next level's requirement
    while (_totalXP >= (currentLevelTotalXpThreshold + xpForNextLevel)) {
      _currentLevel++;
      print("🎉 LEVEL UP! Reached Level $_currentLevel!");
    }
    
    saveProgress();
    notifyListeners();
  }

  // --- Data Persistence using SharedPreferences ---
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userTotalXP', _totalXP);
    await prefs.setInt('userCurrentLevel', _currentLevel);
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _totalXP = prefs.getInt('userTotalXP') ?? 0;
    _currentLevel = prefs.getInt('userCurrentLevel') ?? 1;
    print("Progress Loaded from Local Storage: $_totalXP XP, Level $_currentLevel");
    notifyListeners();
  }
}