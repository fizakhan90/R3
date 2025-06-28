import 'package:flutter/material.dart';
import 'package:r3/services/gemini_service.dart';

class LearningActivityScreen extends StatefulWidget {
  const LearningActivityScreen({super.key});

  @override
  _LearningActivityScreenState createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;

  @override
  @override
void initState() {
  super.initState();

  _controller.addListener(() {
    setState(() {}); // Rebuild on every text change
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _startConversation();
  });
}


  Future<void> _startConversation() async {
    // 👇 Show greeting message bubble immediately
    const greetingMessage = """
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

    setState(() {
      _messages.add({"role": "ai", "text": greetingMessage});
    });

    // Also send to Gemini to begin conversation context
    await _geminiService.sendMessage(greetingMessage, isUser: true);
  }

  Future<void> _sendMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": userInput});
      _isLoading = true;
    });

    final aiResponse = await _geminiService.sendMessage(userInput);

    setState(() {
      _messages.add({"role": "ai", "text": aiResponse});
      _controller.clear();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _geminiService.resetConversation();
    super.dispose();
  }

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    final text = msg['text'] ?? '';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              child: Text("R3", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isUser ? Colors.blueAccent : Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
  title: const Text("Learning a New Skill"),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isLoading,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your reply...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (text) {
                      if (!_isLoading) _sendMessage(text);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
  icon: const Icon(Icons.send, color: Colors.white),
  onPressed: _isLoading || _controller.text.trim().isEmpty
      ? null
      : () => _sendMessage(_controller.text.trim()),
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
