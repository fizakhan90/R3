// lib/screens/learning_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:r3/services/gemini_service.dart';

class LearningActivityScreen extends StatefulWidget {
  final String topic;
  const LearningActivityScreen({super.key, required this.topic});

  @override
  _LearningActivityScreenState createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  final GeminiService _geminiService = GeminiService();
  late Future<String> _learningFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching the data from Gemini as soon as the screen loads
    _learningFuture = _geminiService.getLearningTopic(widget.topic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Learn About ${widget.topic}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // FutureBuilder is perfect for handling loading/error/data states
        child: FutureBuilder<String>(
          future: _learningFuture,
          builder: (context, snapshot) {
            // While loading:
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Asking the AI...", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }
            // If there was an error:
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  snapshot.data ?? "An unknown error occurred.",
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              );
            }
            // When data is ready:
            final lessonText = snapshot.data!;
            return SingleChildScrollView(
              child: Text(
                lessonText,
                style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}