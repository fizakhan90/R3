// lib/screens/challenges_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:r3/services/user_progress_service.dart'; 

class Challenge {
  final String text;
  final String category;
  final IconData icon;

  const Challenge({
    required this.text,
    required this.category,
    required this.icon,
  });
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<Challenge> _allChallenges = [
    // Mindfulness & Presence
    const Challenge(
      text: "Do a 1-minute 'box breath' exercise: Inhale (4s), Hold (4s), Exhale (4s), Hold (4s).",
      category: "Mindfulness",
      icon: Icons.self_improvement_rounded,
    ),
    const Challenge(
      text: "Place your phone in another room for 15 minutes and simply observe your surroundings.",
      category: "Mindfulness",
      icon: Icons.visibility_off_outlined,
    ),
    const Challenge(
      text: "Listen to a full song with your eyes closed, without any other distractions.",
      category: "Mindfulness",
      icon: Icons.music_note_outlined,
    ),

    // Focus & Cognition
    const Challenge(
      text: "Read 5 pages from a physical book or an e-reader (not a social media article).",
      category: "Focus & Cognition",
      icon: Icons.menu_book_outlined,
    ),
    const Challenge(
      text: "Work on a single task for 25 minutes without checking your phone (The Pomodoro Technique).",
      category: "Focus & Cognition",
      icon: Icons.timer_outlined,
    ),
    const Challenge(
      text: "Before opening a social app, state your exact purpose out loud (e.g., 'I'm checking messages from Jane').",
      category: "Focus & Cognition",
      icon: Icons.psychology_outlined,
    ),

    // Movement & Body
    const Challenge(
      text: "Do a 5-minute stretching routine, focusing on your neck, shoulders, and back.",
      category: "Movement & Body",
      icon: Icons.sports_gymnastics_outlined,
    ),
    const Challenge(
      text: "Take a 10-minute walk and try to notice 5 things you've never seen before.",
      category: "Movement & Body",
      icon: Icons.directions_walk_rounded,
    ),
    const Challenge(
      text: "Stand up and do 20 jumping jacks or high-knees to get your blood flowing.",
      category: "Movement & Body",
      icon: Icons.directions_run_rounded,
    ),

    // Connection & Gratitude
    const Challenge(
      text: "Write down three specific things that went well today, no matter how small.",
      category: "Connection & Gratitude",
      icon: Icons.edit_note_outlined,
    ),
    const Challenge(
      text: "Send a genuine message to a friend or family member telling them you appreciate them.",
      category: "Connection & Gratitude",
      icon: Icons.favorite_border_rounded,
    ),
    const Challenge(
      text: "Call a friend or family member for a 5-minute chat instead of texting.",
      category: "Connection & Gratitude",
      icon: Icons.phone_in_talk_outlined,
    ),
  ];

  Challenge? _dailyChallenge;
  int _challengeStreak = 0;
  bool _isChallengeCompletedToday = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyChallenge();
  }

  Future<void> _loadDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";

    final lastCompletedDateString = prefs.getString('lastCompletedDate');
    _isChallengeCompletedToday = lastCompletedDateString == todayKey;

    // --- Streak Logic: Check if the last completion was yesterday ---
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayKey = "${yesterday.year}-${yesterday.month}-${yesterday.day}";
    if (lastCompletedDateString == yesterdayKey) {
      _challengeStreak = prefs.getInt('challengeStreak') ?? 0;
    } else if (lastCompletedDateString != todayKey) {
      // If they missed a day (or more), reset the streak
      _challengeStreak = 0;
      await prefs.setInt('challengeStreak', 0);
    } else {
      _challengeStreak = prefs.getInt('challengeStreak') ?? 0;
    }

    // Use a date-based seed for a consistent daily challenge
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    // Create a shuffled list without modifying the original
    final shuffledList = List<Challenge>.from(_allChallenges)..shuffle(random);
    _dailyChallenge = shuffledList.first;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- FULLY IMPLEMENTED COMPLETION LOGIC ---
  Future<void> _markChallengeAsCompleted() async {
    // 1. Grant XP using the central service
    const int challengeXP = 50;
    context.read<UserProgressService>().addXP(challengeXP);

    // 2. Update local state immediately for a responsive UI
    setState(() {
      _isChallengeCompletedToday = true;
      _challengeStreak++; // Increment streak visually right away
    });

    // 3. Save the new state to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";
    await prefs.setString('lastCompletedDate', todayKey);
    await prefs.setInt('challengeStreak', _challengeStreak);

    // 4. Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🎉 Great job! +$challengeXP XP. Streak: $_challengeStreak day(s)."),
        backgroundColor: const Color(0xFF2ECC71), // A pleasant green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Challenge"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: LearningTheme.surface, height: 1.5),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: LearningTheme.accent))
            : Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: LearningTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: LearningTheme.accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          avatar: Icon(_dailyChallenge!.icon, color: LearningTheme.accent, size: 18),
                          label: Text(
                            _dailyChallenge!.category,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: LearningTheme.textPrimary),
                          ),
                          backgroundColor: LearningTheme.accent.withOpacity(0.15),
                          side: BorderSide(color: LearningTheme.accent.withOpacity(0.3)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _dailyChallenge!.text,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: LearningTheme.textPrimary,
                                fontWeight: FontWeight.normal,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isChallengeCompletedToday ? "✅ Completed" : "🔄 In Progress",
                              style: TextStyle(
                                color: _isChallengeCompletedToday
                                    ? const Color(0xFF2ECC71)
                                    : const Color(0xFFF39C12),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "🔥 Streak: $_challengeStreak day${_challengeStreak == 1 ? '' : 's'}",
                              style: const TextStyle(
                                color: LearningTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // --- Animated Button Visibility ---
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(sizeFactor: animation, child: child),
                            );
                          },
                          child: !_isChallengeCompletedToday
                              ? SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: LearningTheme.accent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    onPressed: _markChallengeAsCompleted,
                                    icon: const Icon(Icons.check_circle_outline),
                                    label: const Text("Mark as Done", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                )
                              : const SizedBox.shrink(), // Show nothing when completed
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}