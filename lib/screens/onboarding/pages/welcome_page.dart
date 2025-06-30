// lib/screens/onboarding/pages/welcome_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:r3/screens/learning/learning_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the theme for consistent styling across the app
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Using RichText to apply different styles within the same text block for branding
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              // Use the largest, boldest style from our theme for the main logo
              style: textTheme.displayLarge,
              children: [
                const TextSpan(text: "R"),
                TextSpan(
                  text: "³",
                  style: TextStyle(
                    color: LearningTheme.accent, // Apply our brand's accent color
                    fontFeatures: const [FontFeature.superscripts()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Reboot. Reform. Rebuild.",
            textAlign: TextAlign.center,
            // Use the consistent subtitle style from our theme
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 48), // Increased spacing for better visual separation
          Text(
            "Welcome to a more mindful way of using your phone. Let's set up your goals.",
            textAlign: TextAlign.center,
            // Use the consistent body text style from our theme for readability
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 100),
          Icon(
            Icons.swipe_left_outlined,
            // Use a theme color with opacity for a subtle hint
            color: LearningTheme.textSecondary.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            "Swipe to begin",
            textAlign: TextAlign.center,
            // Use a smaller, secondary text style for the hint
            style: textTheme.bodyMedium?.copyWith(
              color: LearningTheme.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}