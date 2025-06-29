import 'package:flutter/material.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '🐶 + 🐶 = ?',
      'options': ['🐕🐕', '🐱🐱', '🐶🐶', '🐺🐺'],
      'answer': '🐶🐶',
    },
    {
      'question': '3 + 2 = ?',
      'options': ['4', '5', '6', '7'],
      'answer': '5',
    },
    {
      'question': '🔴 + 🔵 = ?',
      'options': ['🟣', '🟢', '⚪', '🟠'],
      'answer': '🟣',
    },
  ];

  int _currentIndex = 0;
  String _feedback = '';

  void _checkAnswer(String selected) {
    if (selected == _questions[_currentIndex]['answer']) {
      setState(() {
        _feedback = '✅ Correct!';
      });
    } else {
      setState(() {
        _feedback = '❌ Try Again!';
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _feedback = '';
        _currentIndex++;
        if (_currentIndex >= _questions.length) {
          Navigator.of(context).pop(); // End puzzle
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _questions.length) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Well done! 🎉',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      );
    }

    final current = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quick Puzzle'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              current['question'],
              style: const TextStyle(fontSize: 28, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...current['options'].map<Widget>((opt) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _checkAnswer(opt),
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Text(
              _feedback,
              style: const TextStyle(fontSize: 20, color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }
}
