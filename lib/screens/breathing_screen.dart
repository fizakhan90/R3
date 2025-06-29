import 'package:flutter/material.dart';
import 'dart:async';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String phase = "Inhale";
  int breathCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => phase = "Exhale");
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() => phase = "Inhale");
          _controller.forward();
        }
      });

    _animation = Tween<double>(begin: 100, end: 200).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Stop after 1 minute
    _timer = Timer(const Duration(minutes: 1), () {
      _controller.stop();
      Navigator.of(context).pop(); // Close screen after 1 min
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              phase,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: _animation.value,
                  height: _animation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.3),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              "Take deep, slow breaths.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
