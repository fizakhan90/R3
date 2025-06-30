// lib/screens/breathing_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r3/screens/learning/learning_theme.dart';
import 'package:r3/services/user_progress_service.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Timers and Progress
  Timer? _sessionTimer;
  Timer? _progressTimer;
  final Duration _sessionDuration = const Duration(seconds: 60);
  int _elapsedSeconds = 0;
  
  // Gamification and State
  bool _isSessionComplete = false;
  final int _xpEarned = 25;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _animationController.repeat(reverse: true);

    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_elapsedSeconds < _sessionDuration.inSeconds) {
        // This setState call correctly triggers a rebuild
        setState(() => _elapsedSeconds++);
      } else {
        timer.cancel();
      }
    });

    _sessionTimer = Timer(_sessionDuration, _onSessionComplete);
  }

  void _onSessionComplete() {
    if (!mounted) return;
    context.read<UserProgressService>().addXP(_xpEarned);

    setState(() {
      _isSessionComplete = true;
    });
    
    _animationController.stop();
    _progressTimer?.cancel();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sessionTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LearningTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            if (!_isSessionComplete)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(
              value: _elapsedSeconds / _sessionDuration.inSeconds,
              backgroundColor: LearningTheme.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(LearningTheme.accent),
            ),
          ),
        ),
        body: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isSessionComplete
                ? _buildSuccessView()
                : _buildBreathingView(),
          ),
        ),
      ),
    );
  }

  /// The main view for the breathing exercise.
  Widget _buildBreathingView() {
    return AnimatedBuilder(
      key: const ValueKey('breathing'),
      animation: _animationController,
      builder: (context, child) {
        final String phase = _animationController.status == AnimationStatus.reverse
            ? "Breathe Out"
            : "Breathe In";

        final int breathCount = (_elapsedSeconds / 8).floor();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              phase,
              style: const TextStyle(
                fontSize: 32,
                color: LearningTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Transform.scale(
              scale: _animation.value,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LearningTheme.accent.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: LearningTheme.accent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            Text(
              "Breath Count: $breathCount",
              style: const TextStyle(color: LearningTheme.textSecondary, fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  /// The view shown after the session is successfully completed.
  Widget _buildSuccessView() {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 100),
          const SizedBox(height: 24),
          const Text(
            "Session Complete!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            "+$_xpEarned XP Earned",
            style: const TextStyle(color: LearningTheme.accent, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LearningTheme.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Finish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}