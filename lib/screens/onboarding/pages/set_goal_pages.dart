// lib/screens/onboarding/pages/set_goal_page.dart
import 'package:flutter/material.dart';
import 'package:r3/screens/learning/learning_theme.dart';

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

  // Helper to format the time for display
  String _formatTime(double value) {
    final hours = value ~/ 60;
    final minutes = (value % 60).round();
    if (hours == 0) return "$minutes min";
    if (minutes == 0) return "$hours hr";
    return "$hours hr $minutes min";
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What's your daily goal?",
            style: textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: LearningTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "This isn't a strict limit, just a target to help you reflect.",
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          // --- Dynamic Goal Display ---
          Text(
            _formatTime(_currentSliderValue),
            style: textTheme.displayLarge?.copyWith(
              fontSize: 48,
              color: LearningTheme.accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // --- Themed Slider ---
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: LearningTheme.accent,
              inactiveTrackColor: LearningTheme.surface,
              trackHeight: 6.0,
              thumbColor: LearningTheme.accent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayColor: LearningTheme.accent.withOpacity(0.24),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
              activeTickMarkColor: LearningTheme.accent.withOpacity(0.5),
              inactiveTickMarkColor: LearningTheme.surface,
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: LearningTheme.accent,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: _currentSliderValue,
              min: 15,
              max: 180,
              divisions: 11, // (180 - 15) / 15 = 11 steps of 15 min
              label: "${_currentSliderValue.round()} min",
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
                widget.onGoalChanged(value.round());
              },
            ),
          ),
          const SizedBox(height: 80),
          // --- Themed Primary Finish Button ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LearningTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: widget.onFinished,
            child: const Text("Finish Setup & Start"),
          ),
        ],
      ),
    );
  }
}