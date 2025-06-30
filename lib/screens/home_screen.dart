import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/disruption_hub_screen.dart'; // Make sure path is correct
import 'package:r3/screens/gamification/gamification_screen.dart';
import 'package:r3/screens/learning/learning_activity_screen.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:r3/services/app_state.dart';
import 'package:r3/services/usage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsageService _usageService = UsageService();
  StreamSubscription? _distractionSubscription;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to safely interact with context after the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.startMonitoringService();

      // Listen for distractions to show the disruption hub
      _distractionSubscription = _usageService.distractionStream.listen((packageName) {
        // Prevent showing dialog if one is already open
        if (ModalRoute.of(context)?.isCurrent != true) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const DisruptionHubScreen(),
        ).then((_) {
          // Restart monitoring after the user finishes with the hub
          Provider.of<AppState>(context, listen: false).startMonitoringService();
        });
      });
    });
  }

  @override
  void dispose() {
    _distractionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the latest app state
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          // --- Themed AppBar ---
          appBar: AppBar(
            title: const Text("Dashboard"),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // TODO: Navigate to a settings screen
                },
              ),
            ],
          ),
          // --- Dynamic Dashboard Body ---
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _WelcomeHeaderCard(appState: appState)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    "Quick Actions",
                    style: TextStyle(
                      color: LearningTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // --- Grid of Action Cards ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _ActionCard(
                      icon: Icons.school_outlined,
                      title: "Learning",
                      subtitle: "Start a new lesson",
                      color: LearningTheme.accent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningActivityScreen())),
                    ),
                    _ActionCard(
                      icon: Icons.emoji_events_outlined,
                      title: "Milestones",
                      subtitle: "View your progress",
                      color: const Color(0xFFF39C12), // Amber
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamificationScreen())),
                    ),
                    // Add more action cards here if needed
                  ],
                ),
              ),
              // --- Status Card at the Bottom ---
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _StatusCard(appState: appState),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Reusable Dashboard Components ---

/// A card to welcome the user and show their primary goal.
class _WelcomeHeaderCard extends StatelessWidget {
  final AppState appState;
  const _WelcomeHeaderCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LearningTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to R³",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: LearningTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appState.distractingApps.isEmpty
                ? "You're all set to begin your journey."
                : "Monitoring ${appState.distractingApps.length} distracting app(s).",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LearningTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A card for quick navigation to other app features.
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LearningTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: LearningTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A redesigned status card to show monitoring and permission status.
class _StatusCard extends StatelessWidget {
  final AppState appState;
  const _StatusCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    String message;
    Color color;
    IconData icon;
    VoidCallback? onTap;

    switch (appState.monitoringStatus) {
      case "STARTED_SUCCESSFULLY":
        message = "Monitoring is active in the background.";
        color = const Color(0xFF2ECC71); // A pleasant green
        icon = Icons.shield_outlined;
        break;
      case "PERMISSION_DENIED":
        message = "ACTION REQUIRED: Tap to grant permissions.";
        color = const Color(0xFFF39C12); // Amber/Warning
        icon = Icons.warning_amber_rounded;
        onTap = () => appState.startMonitoringService();
        break;
      default:
        message = "Status: ${appState.monitoringStatus}";
        color = LearningTheme.textSecondary;
        icon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            if (onTap != null) Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}