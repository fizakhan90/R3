// lib/widgets/xp_animation_widget.dart
import 'package:flutter/material.dart';
import 'package:r3/screens/learning/learning_theme.dart';

class XpAnimationWidget extends StatefulWidget {
  final int xp;
  final VoidCallback onAnimationComplete;

  const XpAnimationWidget({
    super.key,
    required this.xp,
    required this.onAnimationComplete,
  });

  @override
  _XpAnimationWidgetState createState() => _XpAnimationWidgetState();
}

class _XpAnimationWidgetState extends State<XpAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Chip(

            label: Text(
              "+${widget.xp} XP", 
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: LearningTheme.accent,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }
}