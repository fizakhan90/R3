// lib/screens/onboarding/pages/set_goal_page.dart
import 'package:flutter/material.dart';

class SetGoalPage extends StatefulWidget {
  final Function(int) onGoalChanged;
  final VoidCallback onFinished;
  final int initialGoal;

  const SetGoalPage({
    super.key,
    required this.onGoalChanged,
    required this.onFinished,
    required this.initialGoal,
  });

  @override
  _SetGoalPageState createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialGoal.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What's your daily goal?",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "This isn't a strict limit, just a target to help you reflect.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Text(
            "${_currentSliderValue.round()} minutes",
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _currentSliderValue,
            min: 15,
            max: 180,
            divisions: 11, // (180 - 15) / 15 = 11 steps
            label: _currentSliderValue.round().toString(),
            activeColor: Colors.deepPurple,
            inactiveColor: Colors.grey.shade700,
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
              // This calls the function in onboarding_screen.dart
              // to update the goal value.
              widget.onGoalChanged(value.round());
            },
          ),
          const SizedBox(height: 80),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            // This calls the onFinished function to save data and navigate away.
            onPressed: widget.onFinished,
            child: const Text(
              "Finish Setup",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}