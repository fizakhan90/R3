// lib/screens/disruption_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:r3/screens/breathing_screen.dart';
import 'package:r3/screens/learning/learning_activity_screen.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:r3/screens/puzzle_screen.dart';
import 'package:r3/widgets/healthy_habit_card.dart';

class DisruptionHubScreen extends StatelessWidget {
  const DisruptionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a semi-transparent background for a "layered" effect
      backgroundColor: LearningTheme.background.withOpacity(0.95),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.pan_tool_alt_outlined,
                  color: LearningTheme.accent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  "A Mindful Pause",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: LearningTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "You've opened a distracting app. Choose a healthier, more rewarding alternative.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: LearningTheme.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 40),

                // --- 2. Using the new custom action buttons ---

                _DisruptionActionButton(
                  label: "1-Min Breathing Break",
                  icon: Icons.air_rounded,
                  color: const Color(0xFF3498DB),
                  xpText: "+25 XP", // Specific reward
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const BreathingScreen()),
                    );
                  },
                ),
                _DisruptionActionButton(
                  label: "Try a Quick Puzzle",
                  icon: Icons.extension_rounded,
                  color: const Color(0xFFE67E22),
                  xpText: "Earn XP", // Reward varies
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const PuzzleScreen()),
                    );
                  },
                ),
                _DisruptionActionButton(
                  label: "Get a Healthy Habit",
                  icon: Icons.self_improvement_rounded,
                  color: const Color(0xFF2ECC71),
                  xpText: "~+15 XP", // Reward is approximate
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const HealthyHabitCard(),
                    );
                  },
                ),
                _DisruptionActionButton(
                  label: "Learn Something New",
                  icon: Icons.lightbulb_rounded,
                  color: const Color(0xFF9B59B6),
                  xpText: "Start Lesson", // The reward is the knowledge
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const LearningActivityScreen()),
                    );
                  },
                ),

                const SizedBox(height: 24),
                TextButton(
                  child: const Text(
                    "Continue to app anyway",
                    style: TextStyle(color: LearningTheme.textSecondary),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 1. New Reusable Action Button Widget ---
class _DisruptionActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String xpText;
  final VoidCallback onPressed;

  const _DisruptionActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.xpText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 65, // A taller, more prominent button
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.15),
            foregroundColor: color, // For splash color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
            ),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Row(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: LearningTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // The XP "Chip"
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  xpText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}