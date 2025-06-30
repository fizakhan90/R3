// lib/screens/challenges_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:r3/services/user_progress_service.dart';



// --- 1. A more structured data model for challenges ---
// This makes the code cleaner and allows for future expansion (e.g., descriptions, points).
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
  // --- 2. An expanded list of psychologically-grounded challenges ---
  final List<Challenge> _allChallenges = [
    // --- Category: Mindfulness & Presence ---
    const Challenge(
      text: "Do a 1-minute 'box breath' exercise: Inhale (4s), Hold (4s), Exhale (4s), Hold (4s).",
      category: "Mindfulness",
      icon: Icons.self_improvement_rounded,
    ),
    const Challenge(
      text: "Place your phone in another room for 15 minutes and simply observe your surroundings.",
      category: "Mindfulness",
      icon: Icons.self_improvement_rounded,
    ),
    const Challenge(
      text: "Listen to a full song with your eyes closed, without any other distractions.",
      category: "Mindfulness",
      icon: Icons.self_improvement_rounded,
    ),

    // --- Category: Focus & Cognition ---
    const Challenge(
      text: "Read 5 pages from a physical book or an e-reader (not a social media article).",
      category: "Focus & Cognition",
      icon: Icons.psychology_rounded,
    ),
    const Challenge(
      text: "Work on a single task for 25 minutes without checking your phone (The Pomodoro Technique).",
      category: "Focus & Cognition",
      icon: Icons.psychology_rounded,
    ),
    const Challenge(
      text: "Before opening a social app, state your exact purpose out loud (e.g., 'I'm checking messages from Jane').",
      category: "Focus & Cognition",
      icon: Icons.psychology_rounded,
    ),

    // --- Category: Movement & Body ---
    const Challenge(
      text: "Do a 5-minute stretching routine, focusing on your neck, shoulders, and back.",
      category: "Movement & Body",
      icon: Icons.directions_run_rounded,
    ),
    const Challenge(
      text: "Take a 10-minute walk and try to notice 5 things in your environment you've never seen before.",
      category: "Movement & Body",
      icon: Icons.directions_run_rounded,
    ),
    const Challenge(
      text: "Stand up and do 20 jumping jacks or high-knees to get your blood flowing.",
      category: "Movement & Body",
      icon: Icons.directions_run_rounded,
    ),

    // --- Category: Connection & Gratitude ---
    const Challenge(
      text: "Write down three specific things that went well today, no matter how small.",
      category: "Connection & Gratitude",
      icon: Icons.favorite_rounded,
    ),
    const Challenge(
      text: "Send a genuine message to a friend or family member telling them you appreciate them.",
      category: "Connection & Gratitude",
      icon: Icons.favorite_rounded,
    ),
    const Challenge(
      text: "Call a friend or family member for a 5-minute chat instead of texting.",
      category: "Connection & Gratitude",
      icon: Icons.favorite_rounded,
    ),
  ];

  Challenge? _dailyChallenge;
  int _challengeStreak = 0;
  bool _isChallengeCompletedToday = false;

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

    _challengeStreak = prefs.getInt('challengeStreak') ?? 0;

    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    _allChallenges.shuffle(random);
    _dailyChallenge = _allChallenges.first;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _markChallengeAsCompleted() async {
  // ... [existing logic to handle prefs and streaks]

  // ✅ Add a fixed amount of XP for completing a daily challenge
  const int challengeXP = 50;
  context.read<UserProgressService>().addXP(challengeXP);

  // ... [existing setState logic]

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // ✅ Updated message to show XP earned
      content: Text("🎉 Great job! +$challengeXP XP. Streak: $_challengeStreak day(s)."),
      backgroundColor: Colors.green,
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
        child: _dailyChallenge == null
            ? const Center(child: CircularProgressIndicator())
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
                        // --- 3. Updated UI with Category Tag ---
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
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isChallengeCompletedToday ? "✅ Completed" : "🔄 In Progress",
                              style: TextStyle(
                                color: _isChallengeCompletedToday ? Colors.greenAccent : Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "🔥 Streak: $_challengeStreak day${_challengeStreak == 1 ? '' : 's'}",
                              style: const TextStyle(
                                color: LearningTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (!_isChallengeCompletedToday) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _markChallengeAsCompleted,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Mark as Done", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}