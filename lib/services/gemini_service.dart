import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r3/secrets.dart';

class GeminiService {
  final String _apiKey = geminiApiKey;
  final String _model = "gemini-1.5-flash-latest";

  final List<Map<String, dynamic>> _chatHistory = [];

  Future<String> startConversation() async {
    const greetingPrompt = """
Hi! 👋 I'm your learning buddy.

Here are a few fun and easy topics to learn:

1. Learn the basics of a new language (e.g., Spanish or French)
2. Understand how chess works
3. Explore how to start sketching or drawing
4. Learn how to type faster on a keyboard
5. Dive into mindfulness or meditation
6. Discover how to play the guitar
7. Or... you can tell me **your own** topic you're curious about!

Which one would you like to explore?
""";

    // Important: send as user prompt so Gemini replies to it
    return await sendMessage(greetingPrompt, isUser: true);
  }

  Future<String> sendMessage(String message, {bool isUser = true}) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey",
    );

    // Add new message to history
    _chatHistory.add({
      "role": isUser ? "user" : "model",
      "parts": [
        {"text": message}
      ]
    });

    final requestBody = jsonEncode({"contents": _chatHistory});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final reply = body['candidates'][0]['content']['parts'][0]['text'];

        // Add model's reply to history
        _chatHistory.add({
          "role": "model",
          "parts": [
            {"text": reply}
          ]
        });

        return reply;
      } else {
        if (kDebugMode) {
          print("API Error: ${response.statusCode} - ${response.body}");
        }
        return "Sorry, I couldn't get a response. Status code: ${response.statusCode}";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Network Error: $e");
      }
      return "Network error occurred. Please check your connection.";
    }
  }

  void resetConversation() {
    _chatHistory.clear();
  }
}
