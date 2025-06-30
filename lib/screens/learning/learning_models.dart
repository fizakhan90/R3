import 'package:flutter/material.dart';

enum MessageRole { user, ai, error }

class ChatMessage {
  final MessageRole role;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAI => role == MessageRole.ai;
  bool get isError => role == MessageRole.error;
}

class LearningTopic {
  final String text;
  final String icon;
  final Color color;
  final String description;

  LearningTopic({
    required this.text,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class LearningData {
  static final List<LearningTopic> topics = [
    LearningTopic(
      text: "Spanish Basics",
      icon: "🇪🇸",
      color: const Color(0xFFE74C3C),
      description: "Start with common phrases",
    ),
    LearningTopic(
      text: "Chess Strategy",
      icon: "♟️",
      color: const Color(0xFFC0392B),
      description: "Master the game of kings",
    ),
    LearningTopic(
      text: "Touch Typing",
      icon: "⌨️",
      color: const Color(0xFF27AE60),
      description: "Type faster without looking",
    ),
    LearningTopic(
      text: "Mindfulness",
      icon: "🧘",
      color: const Color(0xFF8E44AD),
      description: "Find peace and focus",
    ),
    LearningTopic(
      text: "Guitar Chords",
      icon: "🎸",
      color: const Color(0xFFF39C12),
      description: "Strum your first song",
    ),
    LearningTopic(
      text: "Digital Art",
      icon: "🎨",
      color: const Color(0xFF2980B9),
      description: "Create art on your device",
    ),
    LearningTopic(
      text: "Cooking Skills",
      icon: "👨‍🍳",
      color: const Color(0xFFD35400),
      description: "Master essential recipes",
    ),
    LearningTopic(
      text: "Photo Tips",
      icon: "📸",
      color: const Color(0xFF7F8C8D),
      description: "Capture better moments",
    ),
  ];

  // A more concise and friendly welcome message
  static const String welcomeMessage =
      "I'm R3, your learning companion. Pick a topic to begin, or ask me anything you're curious about!";
}