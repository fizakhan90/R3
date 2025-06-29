// lib/screens/breathing_activity_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreathingActivityScreen extends StatefulWidget {
  const BreathingActivityScreen({super.key});

  @override
  _BreathingActivityScreenState createState() => _BreathingActivityScreenState();
}

class _BreathingActivityScreenState extends State<BreathingActivityScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instruction = "Get Ready...";
  int _breathCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _instruction = "Breathe Out...");
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathCount++;
          _instruction = "Breathe In...";
        });
        if (_breathCount >= 4) { // 1 ready + 3 breaths
          // When done, exit the app completely.
          Timer(const Duration(seconds: 2), () => SystemNavigator.pop());
        } else {
          _controller.forward();
        }
      }
    });

    // Start after a short delay
    Timer(const Duration(seconds: 2), () {
      setState(() => _instruction = "Breathe In...");
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF102a27), // Teal background
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _instruction,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (_controller.value * 0.5),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.withOpacity(0.4),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}