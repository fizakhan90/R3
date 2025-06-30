// lib/widgets/healthy_habit_card.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:r3/services/user_progress_service.dart';
import 'package:r3/widgets/xp_animation_widget.dart'; 

class Habit {
  final String text;
  final IconData icon;
  final int xp;

  const Habit({required this.text, required this.icon, required this.xp});
}

class HealthyHabitCard extends StatefulWidget {
  const HealthyHabitCard({super.key});

  @override
  State<HealthyHabitCard> createState() => _HealthyHabitCardState();
}

class _HealthyHabitCardState extends State<HealthyHabitCard> {
  final GlobalKey _doneButtonKey = GlobalKey();
  bool _isDonePressed = false; // To disable the button after one press

  final List<Habit> _habits = [
    const Habit(icon: Icons.self_improvement, text: "Take 3 deep, mindful breaths.", xp: 10),
    const Habit(icon: Icons.local_drink, text: "Drink a glass of water.", xp: 5),
    const Habit(icon: Icons.directions_walk, text: "Stretch or walk for 2 minutes.", xp: 15),
    const Habit(icon: Icons.book, text: "Write one thing you're grateful for.", xp: 20),
    const Habit(icon: Icons.visibility_off_outlined, text: "Look at something 20 feet away for 20 seconds.", xp: 10),
    const Habit(icon: Icons.favorite_border, text: "Send a kind message to a loved one.", xp: 20),
    const Habit(icon: Icons.palette_outlined, text: "Doodle or sketch for a few minutes.", xp: 15),
    const Habit(icon: Icons.eco_outlined, text: "Step outside and feel the fresh air.", xp: 10),
    const Habit(icon: Icons.cleaning_services_outlined, text: "Do a 3-minute desk or room declutter.", xp: 15),
  ];

  late Habit _currentHabit;

  @override
  void initState() {
    super.initState();
    _currentHabit = _getRandomHabit(null);
  }

  Habit _getRandomHabit(Habit? previousHabit) {
    final random = Random();
    Habit newHabit;
    do {
      newHabit = _habits[random.nextInt(_habits.length)];
    } while (newHabit == previousHabit);
    return newHabit;
  }

  void _showAnotherHabit() {
    setState(() {
      _currentHabit = _getRandomHabit(_currentHabit);
    });
  }

  void _onDonePressed() {
    if (_isDonePressed) return; // Prevent multiple clicks

    setState(() {
      _isDonePressed = true;
    });

    // Grant XP using the central service
    context.read<UserProgressService>().addXP(_currentHabit.xp);
    // Show the rewarding animation
    _showXpAnimation(_currentHabit.xp);

    // Wait a bit before closing to let user see animation start
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showXpAnimation(int xp) {
    // Find the button's position
    final RenderBox? renderBox = _doneButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    late OverlayEntry overlayEntry; // Declare it here to access in the callback

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: position.dy - 40, // Start slightly above the button
          left: position.dx + (size.width / 2) - 40, // Center horizontally
          child: XpAnimationWidget(
            xp: xp,
            onAnimationComplete: () {
              // This is the key: remove the overlay only when the animation is truly finished.
              overlayEntry.remove();
            },
          ),
        );
      },
    );

    // Insert the overlay and let it handle its own lifecycle.
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext G) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: LearningTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LearningTheme.card.withOpacity(0.5)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Column(
            key: ValueKey<String>(_currentHabit.text),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _currentHabit.icon,
                color: LearningTheme.accent,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                "Your Healthy Break",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: LearningTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _currentHabit.text,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: LearningTheme.textSecondary,
                  fontWeight: FontWeight.normal,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    key: _doneButtonKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LearningTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      // Change style when pressed to give feedback
                      disabledBackgroundColor: Colors.green.shade600,
                    ),
                    // Disable the button when pressed
                    onPressed: _isDonePressed ? null : _onDonePressed,
                    child: Text(
                      _isDonePressed ? "XP Gained!" : "Done! ✨",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    // Disable this button too after 'Done' is pressed
                    onPressed: _isDonePressed ? null : _showAnotherHabit,
                    child: const Text(
                      "Try another suggestion",
                      style: TextStyle(color: LearningTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}