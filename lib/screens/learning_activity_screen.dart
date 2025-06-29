// lib/screens/learning_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r3/services/gemini_service.dart';

class LearningActivityScreen extends StatefulWidget {
  final String topic;
  const LearningActivityScreen({super.key, required this.topic});

  @override
  _LearningActivityScreenState createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  Future<bool> _onWillPop() async {
    SystemNavigator.pop();
    return false;
  }

  void _startConversation() async {
    setState(() => _isLoading = true);
    final initialPrompt = "Teach me the basics of ${widget.topic} in a short, engaging way.";
    _messages.add({"role": "user", "text": "Tell me about ${widget.topic}!"});
    try {
      final response = await _geminiService.sendMessage(initialPrompt);
      setState(() {
        _messages.add({"role": "ai", "text": response});
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "Sorry, an error occurred. Please try again."});
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "text": userInput});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();
    try {
      final aiResponse = await _geminiService.sendMessage(userInput);
      setState(() {
        _messages.add({"role": "ai", "text": aiResponse});
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "Sorry, an error occurred. Please try again."});
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _geminiService.resetConversation();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Learning: ${widget.topic}"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: "End Session",
            onPressed: _onWillPop,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.deepPurple : Colors.grey[850],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(msg['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.deepPurple),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(top: BorderSide(color: Colors.grey[800]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask a question...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}