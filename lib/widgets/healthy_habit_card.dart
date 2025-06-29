import 'dart:math';
import 'package:flutter/material.dart';

class HealthyHabitCard extends StatefulWidget {
  const HealthyHabitCard({super.key});

  @override
  State<HealthyHabitCard> createState() => _HealthyHabitCardState();
}

class _HealthyHabitCardState extends State<HealthyHabitCard> {
  final List<String> _habits = [
    "🧘 Take a 1-minute mindful breath.",
    "💧 Drink a glass of water.",
    "🚶‍♂️ Walk for 5 minutes.",
    "📓 Write one thing you're grateful for.",
    "👀 Look away from the screen for 20 seconds.",
    "📞 Call or message a loved one.",
    "🎨 Doodle or sketch something!",
    "🌱 Step outside and feel the air.",
    "🛏️ Do a 3-minute desk declutter."
  ];

  late String _currentHabit;

  @override
  void initState() {
    super.initState();
    _currentHabit = _getRandomHabit();
  }

  String _getRandomHabit() {
    final random = Random();
    return _habits[random.nextInt(_habits.length)];
  }

  void _showAnotherHabit() {
    setState(() {
      _currentHabit = _getRandomHabit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Healthy Habit 💡', style: TextStyle(color: Colors.white)),
      content: Text(
        _currentHabit,
        style: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
      actions: [
        TextButton(
          onPressed: _showAnotherHabit,
          child: const Text("Another", style: TextStyle(color: Colors.blueAccent)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}
