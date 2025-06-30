import 'dart:math';
import 'package:flutter/material.dart';

// --- Data Models for Cleaner Code ---

class Puzzle {
  final String question;
  final List<String> options;
  final String answer;

  const Puzzle({
    required this.question,
    required this.options,
    required this.answer,
  });
}

class BrainBoostFact {
  final IconData icon;
  final String text;

  const BrainBoostFact({required this.icon, required this.text});
}


// --- The Improved Puzzle Screen ---

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with TickerProviderStateMixin {
  // --- Richer Content ---
  final List<Puzzle> _puzzles = [
    const Puzzle(
      question: 'Which number fits the sequence: 2, 4, 8, 16, ?',
      options: ['24', '32', '64', '20'],
      answer: '32',
    ),
    const Puzzle(
      question: 'I have cities, but no houses. I have mountains, but no trees. What am I?',
      options: ['A dream', 'A book', 'A map', 'A phone'],
      answer: 'A map',
    ),
    const Puzzle(
      question: 'Solve this: 🧠 + 💡 = ?',
      options: ['🤔', '🤯', '🥳', '✨'],
      answer: '✨',
    ),
    const Puzzle(
      question: 'What is 7 x 8?',
      options: ['49', '54', '56', '63'],
      answer: '56',
    ),
    const Puzzle(
      question: 'Which shape comes next in the pattern: 🔴🟡🔴🟡?',
      options: ['🟡', '🔴', '🟢', '🔵'],
      answer: '🔴',
    ),
    const Puzzle(
      question: 'What has an eye but cannot see?',
      options: ['A storm', 'A potato', 'A needle', 'A keyhole'],
      answer: 'A needle',
    ),
  ];

  final List<BrainBoostFact> _brainFacts = [
    const BrainBoostFact(
      icon: Icons.memory,
      text: 'Puzzles help strengthen the connections between your brain cells.',
    ),
    const BrainBoostFact(
      icon: Icons.emoji_events,
      text: 'Solving a puzzle releases dopamine, a chemical that improves mood and motivation!',
    ),
    const BrainBoostFact(
      icon: Icons.lightbulb_outline,
      text: 'Mental exercises like this can improve your problem-solving skills.',
    ),
    const BrainBoostFact(
      icon: Icons.shield_outlined,
      text: 'Engaging your brain regularly may help reduce the risk of dementia.',
    ),
     const BrainBoostFact(
      icon: Icons.auto_awesome,
      text: 'A quick brain break can boost your focus for the rest of the day.',
    ),
  ];

  late int _currentIndex;
  late int _currentFactIndex;
  
  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    // Shuffle for a new experience each time!
    _puzzles.shuffle();
    _brainFacts.shuffle();
    _currentIndex = 0;
    _currentFactIndex = 0;
  }

  void _checkAnswer(String selected) {
    if (_isAnswered) return; // Prevent multiple taps

    setState(() {
      _selectedOption = selected;
      _isAnswered = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      if (_selectedOption == _puzzles[_currentIndex].answer) {
        // Correct answer, move to the next puzzle
        setState(() {
          _currentIndex++;
          // Cycle through facts
          _currentFactIndex = (_currentFactIndex + 1) % _brainFacts.length;
          _isAnswered = false;
          _selectedOption = null;
        });
      } else {
        // Incorrect answer, just reset to try again
        setState(() {
          _isAnswered = false;
          _selectedOption = null;
        });
        // Optional: Add a shake animation or more prominent feedback for wrong answers
      }
    });
  }

  // --- Helper method for building styled option buttons ---
  Widget _buildOptionButton(String option) {
    Color buttonColor = const Color(0xFF3A3A3C); // Default button color
    Color textColor = Colors.white;
    IconData? icon;

    if (_isAnswered) {
      String correctAnswer = _puzzles[_currentIndex].answer;
      if (option == _selectedOption) {
        if (option == correctAnswer) {
          buttonColor = Colors.green; // Selected and correct
          icon = Icons.check_circle;
        } else {
          buttonColor = Colors.red; // Selected but incorrect
          icon = Icons.cancel;
        }
      } else if (option == correctAnswer) {
        buttonColor = Colors.green.withOpacity(0.5); // The actual correct answer
      } else {
        buttonColor = Colors.grey.withOpacity(0.3); // Other incorrect options
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: _isAnswered ? 0 : 2,
        ),
        onPressed: () => _checkAnswer(option),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: textColor), const SizedBox(width: 12)],
            Text(option, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if all puzzles are completed
    if (_currentIndex >= _puzzles.length) {
      return _buildSuccessScreen();
    }

    final currentPuzzle = _puzzles[_currentIndex];
    final progress = (_currentIndex / _puzzles.length);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // A modern dark background
      appBar: AppBar(
        title: const Text('Brain Break'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          // --- Engaging Progress Bar ---
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Animated Puzzle Content ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey<int>(_currentIndex), // Important for animation
                children: [
                  const SizedBox(height: 40),
                  Text(
                    currentPuzzle.question,
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ...currentPuzzle.options.map((opt) => _buildOptionButton(opt)).toList(),
                ],
              ),
            ),
            // --- Animated Brain Boost Fact ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildBrainBoostCard(key: ValueKey<int>(_currentFactIndex)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrainBoostCard({Key? key}) {
    final fact = _brainFacts[_currentFactIndex];
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(fact.icon, color: Colors.cyanAccent, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              fact.text,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Scaffold _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text(
              'Brain Boost Complete!',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'You did a great job.',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Awesome!', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}