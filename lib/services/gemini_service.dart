import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r3/secrets.dart'; // Ensure this path is correct

class GeminiService {
  final String _apiKey = geminiApiKey;
  final String _model = "gemini-1.5-flash-latest";

  // --- 1. A Powerful System Instruction ---
  // This sets the AI's persona and rules for the entire conversation.
  // It's much more effective than a one-time starter prompt.
  final Map<String, dynamic> _systemInstruction = {
    "role": "system",
    "parts": [
      {
        "text": """
You ARE a friendly, encouraging, and extremely concise learning buddy named R3. Your primary goal is to break down complex topics into simple, bite-sized, and easily digestible chunks.

**Your Core Rules:**
1.  **BE CONCISE:** Your responses MUST be short. Aim for 2-4 sentences, or under 100 words. Never write long paragraphs. Use lists or bullet points for clarity.
2.  **BE ENCOURAGING:** Use a positive and uplifting tone. Use emojis like ✨, 🚀, 👍, and 🎉 to make learning feel light and fun.
3.  **BE A GUIDE, NOT A LECTURER:** Don't give all the information at once. Your goal is to spark curiosity and guide the user to the next small step. Always end your response with an open-ended question to encourage a reply.
4.  **AVOID JARGON:** Explain things in the simplest terms possible, as if explaining to a 10-year-old.
5.  **HANDLE GREETINGS:** If the user says "hi" or starts a conversation, respond with a warm, short greeting and ask what they're curious about today.
"""
      }
    ]
  };

  // The conversation history will only contain user/model turns.
  final List<Map<String, dynamic>> _chatHistory = [];

  Future<String> sendMessage(String message) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey",
    );

    // Add the user's new message to the history
    _chatHistory.add({
      "role": "user",
      "parts": [
        {"text": message}
      ]
    });

    // --- 2. API Configuration for Hard Limits ---
    // This is the most reliable way to control response length.
    final generationConfig = {
      "temperature": 0.8,
      "maxOutputTokens": 256, // Hard limit on response size.
      "topP": 0.95,
      "topK": 64
    };

    // Construct the full request body
    final requestBody = jsonEncode({
      "contents": _chatHistory,
      "system_instruction": _systemInstruction, // Apply the system rules
      "generationConfig": generationConfig,    // Apply the generation limits
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Safely access the response text
        final candidates = body['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          if (content != null && content['parts'] != null) {
            final reply = content['parts'][0]['text'] as String;

            // Add the AI's reply to the history for context in the next turn
            _chatHistory.add({
              "role": "model",
              "parts": [
                {"text": reply}
              ]
            });
            return reply;
          }
        }
        // If the structure is unexpected, return an error.
        return "Sorry, I received an unexpected response format.";
      } else {
        if (kDebugMode) {
          print("API Error: ${response.statusCode} - ${response.body}");
        }
        // Attempt to parse a more helpful error message from the API response
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['error']['message'] ?? 'Please try again later.';
          return "Sorry, an error occurred: $errorMessage";
        } catch (e) {
          return "Sorry, I couldn't get a response. Status code: ${response.statusCode}";
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Network Error: $e");
      }
      return "Network error. Please check your connection and try again.";
    }
  }

  // Resets the conversation for a fresh start.
  void resetConversation() {
    _chatHistory.clear();
  }
}