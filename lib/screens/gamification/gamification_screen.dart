// lib/screens/gamification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/gamification/gamification_models.dart';
import 'package:r3/screens/gamification/gamification_widgets.dart';
import 'package:r3/services/user_progress_service.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer widget to listen for changes in the UserProgressService
    return Consumer<UserProgressService>(
      builder: (context, progressService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Your Journey"),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                // Pass the live data from the service to the header card
                child: ProgressHeaderCard(
                  currentXP: progressService.totalXP,
                  currentLevel: progressService.currentLevel,
                  xpInCurrentLevel: progressService.xpInCurrentLevel,
                  xpForNextLevel: progressService.xpForNextLevel,
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text("Milestones", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final milestone = MilestoneData.milestones[index];
                      // Check unlock status against the live XP from the service
                      final isUnlocked = progressService.totalXP >= milestone.xpRequired;
                      return MilestoneCard(
                        milestone: milestone,
                        isUnlocked: isUnlocked,
                      );
                    },
                    childCount: MilestoneData.milestones.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}