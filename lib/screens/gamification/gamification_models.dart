import 'package:flutter/material.dart';

/// Represents a single unlockable milestone.
class Milestone {
  final int xpRequired;
  final String title;
  final String description;
  final IconData icon;

  const Milestone({
    required this.xpRequired,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// A static class to hold all the milestone data for the app.
class MilestoneData {
  static final List<Milestone> milestones = [
    const Milestone(
      xpRequired: 100,
      title: "Curious Beginner",
      description: "You've started your journey and taken the first step!",
      icon: Icons.emoji_events_outlined,
    ),
    const Milestone(
      xpRequired: 500,
      title: "Focus Foundation",
      description: "Your focus habits are improving, boosting brain connectivity.",
      icon: Icons.lightbulb_outline_rounded,
    ),
    const Milestone(
      xpRequired: 1200,
      title: "Mindful Momentum",
      description: "Taking regular breaks has enhanced your attention span.",
      icon: Icons.self_improvement_rounded,
    ),
    const Milestone(
      xpRequired: 2500,
      title: "Eye Care Expert",
      description: "You've significantly reduced digital eye strain. Your eyes thank you!",
      icon: Icons.visibility_outlined,
    ),
    const Milestone(
      xpRequired: 5000,
      title: "Cognitive Champion",
      description: "Your brain is sharper and more resilient. Keep up the great work!",
      icon: Icons.shield_outlined,
    ),
    const Milestone(
      xpRequired: 10000,
      title: "Screen Time Sensei",
      description: "You have mastered the art of healthy screen habits. Truly inspiring! 🚀",
      icon: Icons.auto_awesome,
    ),
  ];
}

/// A mock service to simulate fetching user progress.
/// In a real app, this would connect to a database like Firebase or a local DB.
class UserProgressService {
  // Let's pretend the user has earned 1550 XP for demonstration.
  // Try changing this value to see the UI update!
  final int _currentXP = 1550;

  Future<int> getUserXP() async {
    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentXP;
  }
}