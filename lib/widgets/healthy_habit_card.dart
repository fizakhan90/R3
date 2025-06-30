import 'dart:math';
import 'package:flutter/material.dart';

// --- Data Model for a Habit ---
// Using a class makes the code cleaner and easier to extend later.
class Habit {
  final String text;
  final IconData icon;

  const Habit({required this.text, required this.icon});
}

// --- The Improved Widget ---
class HealthyHabitCard extends StatefulWidget {
  const HealthyHabitCard({super.key});

  @override
  State<HealthyHabitCard> createState() => _HealthyHabitCardState();
}

class _HealthyHabitCardState extends State<HealthyHabitCard> {
  // A list of Habit objects, combining text and a relevant icon.
  final List<Habit> _habits = [
    const Habit(icon: Icons.self_improvement, text: "Take 3 deep, mindful breaths."),
    const Habit(icon: Icons.local_drink, text: "Drink a glass of water."),
    const Habit(icon: Icons.directions_walk, text: "Stretch or walk for 2 minutes."),
    const Habit(icon: Icons.book, text: "Write one thing you're grateful for."),
    const Habit(icon: Icons.visibility_off_outlined, text: "Look at something 20 feet away for 20 seconds."),
    const Habit(icon: Icons.favorite_border, text: "Send a kind message to a loved one."),
    const Habit(icon: Icons.palette_outlined, text: "Doodle or sketch for a few minutes."),
    const Habit(icon: Icons.eco_outlined, text: "Step outside and feel the fresh air."),
    const Habit(icon: Icons.cleaning_services_outlined, text: "Do a 3-minute desk or room declutter."),
  ];

  late Habit _currentHabit;

  @override
  void initState() {
    super.initState();
    // Get the initial random habit.
    _currentHabit = _getRandomHabit(null);
  }

  // Improved logic to avoid showing the same habit twice in a row.
  Habit _getRandomHabit(Habit? previousHabit) {
    final random = Random();
    Habit newHabit;
    do {
      newHabit = _habits[random.nextInt(_habits.length)];
    } while (newHabit == previousHabit); // Keep looping if it's the same as the last one
    return newHabit;
  }

  void _showAnotherHabit() {
    setState(() {
      // Pass the current habit to avoid picking it again.
      _currentHabit = _getRandomHabit(_currentHabit);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using Theme.of(context) makes your widget adapt to the app's overall theme.
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2E), // A slightly softer dark color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // We use a Column in the content for better layout control.
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // A nice fade transition for when the habit changes.
          return FadeTransition(opacity: animation, child: child);
        },
        // The Key is crucial! It tells AnimatedSwitcher that the child has changed.
        child: Column(
          key: ValueKey<String>(_currentHabit.text),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Icon(
              _currentHabit.icon,
              color: Colors.greenAccent, // A vibrant, positive accent color
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              "Your Healthy Break",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _currentHabit.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.4, // Improved line spacing
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
      // We remove the default title and actions to use our custom content layout.
      title: null,
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A primary, filled button for the positive action.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Done! ✨", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            // A secondary, less prominent button for an alternative.
            TextButton(
              onPressed: _showAnotherHabit,
              child: const Text(
                "Try another suggestion",
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
      ],
      // Remove default padding to have full control over the layout.
      contentPadding: EdgeInsets.zero,
    );
  }
}