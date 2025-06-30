import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:r3/screens/gamification/gamification_models.dart' hide UserProgressService;
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:provider/provider.dart'; 
import 'package:r3/services/user_progress_service.dart'; 



// --- Data Models (No changes needed) ---
enum PuzzleDifficulty { easy, medium }

class Puzzle {
  final String question;
  final List<String> options;
  final String answer;
  final String category;
  final PuzzleDifficulty difficulty;
  final int xp;

  const Puzzle({
    required this.question,
    required this.options,
    required this.answer,
    required this.category,
    this.difficulty = PuzzleDifficulty.easy,
    this.xp = 10,
  });
}

class BrainBoostFact {
  final IconData icon;
  final String text;
  const BrainBoostFact({required this.icon, required this.text});
}

// --- The Puzzle Screen ---
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _xpAnimationController;

  final List<Puzzle> _puzzles = [
    // ... [Puzzle list is the same as the previous gentle version]
     const Puzzle(
      question: "What is 25 x 4?",
      options: ['125', '80', '100', '150'],
      answer: '100',
      category: "Mental Math",
      xp: 10,
    ),
    const Puzzle(
      question: "Which number comes next: 5, 10, 15, 20, ?",
      options: ['30', '40', '25', '22'],
      answer: '25',
      category: "Simple Patterns",
      xp: 10,
    ),
    const Puzzle(
      question: "What has a thumb and four fingers but is not alive?",
      options: ['A Hand', 'A Glove', 'A Robot', 'A Drawing'],
      answer: 'A Glove',
      category: "Wordplay",
      difficulty: PuzzleDifficulty.easy,
      xp: 15,
    ),
    const Puzzle(
      question: "What month of the year has 28 days?",
      options: ['February', 'Only February', 'All of them', 'None'],
      answer: 'All of them',
      category: "Lateral Thinking",
      difficulty: PuzzleDifficulty.medium,
      xp: 20,
    ),
    const Puzzle(
      question: "Which of these is the odd one out?",
      options: ['Apple', 'Banana', 'Carrot', 'Orange'],
      answer: 'Carrot',
      category: "Categorization",
      xp: 10,
    ),
    const Puzzle(
      question: "I am full of holes but can still hold water. What am I?",
      options: ['A Net', 'A Sieve', 'A Sponge', 'A Cloud'],
      answer: 'A Sponge',
      category: "Riddle",
      difficulty: PuzzleDifficulty.medium,
      xp: 15,
    ),
  ];

  final List<BrainBoostFact> _brainFacts = [
    const BrainBoostFact(
        icon: Icons.memory,
        text: 'Logic puzzles improve working memory and reasoning skills.'),
    const BrainBoostFact(
        icon: Icons.emoji_events,
        text: 'Solving a puzzle releases dopamine, boosting mood and motivation!'),
    const BrainBoostFact(
        icon: Icons.lightbulb_outline,
        text: 'Lateral thinking challenges you to solve problems creatively.'),
    const BrainBoostFact(
        icon: Icons.auto_awesome,
        text: 'A quick brain break can significantly boost your focus for hours.'),
  ];

  late int _currentIndex;
  late int _totalXpEarned;
  String? _selectedOption;
  bool _isAnswered = false;
  final Map<String, GlobalKey> _buttonKeys = {};

  // --- 1. New state variable to control the 'Next' button ---
  bool _showNextButton = false;

  @override
  void initState() {
    super.initState();
    _puzzles.shuffle();
    _currentIndex = 0;
    _totalXpEarned = 0;
    _generateButtonKeysForCurrentPuzzle();

    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _xpAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }
  
  void _generateButtonKeysForCurrentPuzzle() {
    _buttonKeys.clear();
    if (_currentIndex < _puzzles.length) {
      for (var option in _puzzles[_currentIndex].options) {
        _buttonKeys[option] = GlobalKey();
      }
    }
  }

  void _showXpAnimation(int xp) {
    // ... [This function is correct and remains the same] ...
     final correctButtonKey = _buttonKeys[_puzzles[_currentIndex].answer]!;
    final RenderBox renderBox = correctButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: position.dy - 30,
          left: position.dx + (size.width / 2) - 25,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: _xpAnimationController, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, -1.0),
              ).animate(_xpAnimationController),
              child: Material(
                color: Colors.transparent,
                child: Chip(
                  label: Text("+$xp XP", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  backgroundColor: LearningTheme.accent,
                  elevation: 4,
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
    _xpAnimationController.forward(from: 0).then((_) => overlayEntry.remove());
  }

  // --- 3. Refactored answer logic with explicit user control ---
  void _checkAnswer(String selected) {
  if (_isAnswered) return;

  setState(() {
    _isAnswered = true;
    _selectedOption = selected;
  });

  final currentPuzzle = _puzzles[_currentIndex];
  final isCorrect = selected == currentPuzzle.answer;

  if (isCorrect) {
    _showXpAnimation(currentPuzzle.xp);

    // ✅ This is the key change: Call the central service to add XP.
    // context.read<T>() is a shortcut for Provider.of<T>(context, listen: false)
    context.read<UserProgressService>().addXP(currentPuzzle.xp);

    _totalXpEarned += currentPuzzle.xp;
    setState(() {
      _showNextButton = true;
    });
  } else {
    _shakeController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _resetCurrentPuzzle();
      }
    });
  }
}

  // This is now called ONLY by the 'Next' button
  void _advanceToNextPuzzle() {
    setState(() {
      _currentIndex++;
      _isAnswered = false;
      _selectedOption = null;
      _showNextButton = false; // Hide the button for the new puzzle
      _generateButtonKeysForCurrentPuzzle();
    });
  }
  
  void _resetCurrentPuzzle() {
    setState(() {
      _isAnswered = false;
      _selectedOption = null;
    });
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    _xpAnimationController.dispose();
    super.dispose();
  }

  Widget _buildOptionButton(String option) {
    // ... [This function is correct and remains the same] ...
    Color buttonColor = LearningTheme.surface;
    IconData? icon;

    if (_isAnswered) {
      String correctAnswer = _puzzles[_currentIndex].answer;
      if (option == _selectedOption) {
        buttonColor = (option == correctAnswer) ? Colors.green : Colors.red;
        icon = (option == correctAnswer) ? Icons.check_circle : Icons.cancel;
      } else if (option == correctAnswer) {
        buttonColor = Colors.green.withOpacity(0.5);
      } else {
        buttonColor = LearningTheme.surface.withOpacity(0.5);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        key: _buttonKeys[option],
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: _isAnswered ? 0 : 2,
        ),
        onPressed: _isAnswered ? null : () => _checkAnswer(option), // Disable button after answering
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white), const SizedBox(width: 12)],
            Text(option, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // --- 2. New widget for the 'Next' button ---
  Widget _buildNextButton() {
    return AnimatedOpacity(
      opacity: _showNextButton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: IgnorePointer(
        ignoring: !_showNextButton,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: LearningTheme.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _advanceToNextPuzzle,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text("Next Puzzle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _puzzles.length) {
      return _buildSuccessScreen();
    }
    
    final currentPuzzle = _puzzles[_currentIndex];
    final progress = (_currentIndex / _puzzles.length);

    return Scaffold(
      backgroundColor: LearningTheme.background,
      appBar: AppBar(
        title: const Text('Brain Break'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: LearningTheme.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(LearningTheme.accent),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey<int>(_currentIndex),
                  children: [
                    const SizedBox(height: 30),
                    Chip(
                      label: Text(currentPuzzle.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: LearningTheme.accent.withOpacity(0.15),
                      side: BorderSide.none,
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final sineValue = sin(pi * _shakeController.value * 8);
                        return Transform.translate(
                          offset: Offset(sineValue * 10, 0),
                          child: child,
                        );
                      },
                      child: Text(
                        currentPuzzle.question,
                        style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...currentPuzzle.options.map((opt) => _buildOptionButton(opt)).toList(),
                    // Add the 'Next' button here
                    _buildNextButton(),
                  ],
                ),
              ),
            ),
            _buildBrainBoostCard(key: ValueKey<int>(_currentIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildBrainBoostCard({Key? key}) {
    // ... [This function is the same]
    final fact = _brainFacts[_currentIndex % _brainFacts.length];
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LearningTheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(fact.icon, color: LearningTheme.accent, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              fact.text,
              style: const TextStyle(color: LearningTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    // ... [This function is the same]
    return Scaffold(
      backgroundColor: LearningTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text('Brain Boost Complete!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              '+$_totalXpEarned Total XP Earned!',
              style: const TextStyle(color: LearningTheme.accent, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LearningTheme.accent,
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