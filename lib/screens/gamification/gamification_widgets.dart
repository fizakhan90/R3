import 'package:flutter/material.dart';
import '../learning/learning_theme.dart'; // We can reuse the beautiful theme from before
import 'gamification_models.dart';

/// A header card that shows the user's current XP and progress to the next goal.
class ProgressHeaderCard extends StatelessWidget {
  final int currentXP;
  final Milestone? nextMilestone;

  const ProgressHeaderCard({
    super.key,
    required this.currentXP,
    this.nextMilestone,
  });

  @override
  Widget build(BuildContext context) {
    final int goalXP = nextMilestone?.xpRequired ?? currentXP;
    final int previousMilestoneXP = MilestoneData.milestones
        .lastWhere((m) => m.xpRequired <= currentXP, orElse: () => const Milestone(xpRequired: 0, title: '', description: '', icon: Icons.error))
        .xpRequired;

    final double progress = (currentXP - previousMilestoneXP) / (goalXP - previousMilestoneXP);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LearningTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LearningTheme.card.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: LearningTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Your XP: $currentXP", style: const TextStyle(color: LearningTheme.textSecondary)),
              if (nextMilestone != null)
                Text("Next Goal: $goalXP", style: const TextStyle(color: LearningTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                  backgroundColor: LearningTheme.card,
                  valueColor: AlwaysStoppedAnimation<Color>(LearningTheme.accent),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A card representing a single milestone, visually changing based on lock status.
class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final bool isUnlocked;

  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUnlocked ? LearningTheme.surface : LearningTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked ? LearningTheme.accent.withOpacity(0.5) : LearningTheme.surface,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isUnlocked ? LearningTheme.accent.withOpacity(0.15) : LearningTheme.surface,
              child: Icon(
                isUnlocked ? milestone.icon : Icons.lock_outline,
                color: isUnlocked ? LearningTheme.accent : LearningTheme.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? LearningTheme.textPrimary : LearningTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milestone.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: LearningTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "${milestone.xpRequired}\nXP",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? LearningTheme.accent : LearningTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}