import 'package:flutter/material.dart';
import '../learning/learning_theme.dart';
import 'gamification_models.dart';
import 'gamification_widgets.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  _GamificationScreenState createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  final UserProgressService _progressService = UserProgressService();
  final List<Milestone> _milestones = MilestoneData.milestones;

  int? _userXP;
  Milestone? _nextMilestone;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final xp = await _progressService.getUserXP();
    if (!mounted) return;

    setState(() {
      _userXP = xp;
      // Find the next milestone the user is working towards
      _nextMilestone = _milestones.firstWhere(
        (m) => m.xpRequired > _userXP!,
        orElse: () => _milestones.last, // Handle case where user has unlocked all
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LearningTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your Journey"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: LearningTheme.surface, height: 1.5),
          ),
        ),
        body: _userXP == null
            ? const Center(child: CircularProgressIndicator(color: LearningTheme.accent))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ProgressHeaderCard(
                      currentXP: _userXP!,
                      nextMilestone: _nextMilestone,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(
                        "Milestones",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final milestone = _milestones[index];
                          final isUnlocked = _userXP! >= milestone.xpRequired;
                          return MilestoneCard(
                            milestone: milestone,
                            isUnlocked: isUnlocked,
                          );
                        },
childCount: _milestones.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
      ),
    );
  }
}