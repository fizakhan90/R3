import 'package:flutter/material.dart';
import 'package:r3/services/gemini_service.dart'; 
import 'learning_theme.dart';
import 'learning_widgets.dart';
import 'learning_models.dart';

class LearningActivityScreen extends StatefulWidget {
  const LearningActivityScreen({super.key});

  @override
  _LearningActivityScreenState createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen>
    with TickerProviderStateMixin {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<LearningTopic> _suggestions = LearningData.topics;

  late AnimationController _welcomeFadeController;
  late AnimationController _suggestionsSlideController;
  late AnimationController _listAnimationController;

  bool _isLoading = false;
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _initializeAnimations();
    // Start the intro animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWelcomeAnimation());
  }

  void _initializeAnimations() {
    _welcomeFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _suggestionsSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _startWelcomeAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _welcomeFadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _suggestionsSlideController.forward();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    final userMessage = ChatMessage(
      role: MessageRole.user,
      text: userInput.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      if (_showWelcome) _showWelcome = false;
    });
    _controller.clear();
    _scrollToBottom();
    _listAnimationController.forward(from: 0);

      final aiResponse = await _geminiService.sendMessage(userInput);



    if (mounted) {
      final aiMessage = ChatMessage(
        role: aiResponse.startsWith("Sorry") || aiResponse.startsWith("Network")
            ? MessageRole.error
            : MessageRole.ai,
        text: aiResponse,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
      _scrollToBottom();
      _listAnimationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _welcomeFadeController.dispose();
    _suggestionsSlideController.dispose();
    _listAnimationController.dispose();
    _geminiService.resetConversation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LearningTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Learning Journey"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: LearningTheme.surface, height: 1.5),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (_showWelcome) ...[
                    SliverToBoxAdapter(
                      child: WelcomeCard(fadeController: _welcomeFadeController),
                    ),
                    SliverToBoxAdapter(
                      child: SuggestionGrid(
                        suggestions: _suggestions,
                        slideController: _suggestionsSlideController,
                        onTopicSelected: _sendMessage,
                      ),
                    ),
                  ],
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final message = _messages[index];
                        final previousMessage = index > 0 ? _messages[index - 1] : null;
                        return MessageBubble(
                          message: message,
                          previousMessage: previousMessage,
                          animation: CurvedAnimation(
                            parent: _listAnimationController,
                            curve: Curves.easeOut,
                          ),
                        );
                      },
                      childCount: _messages.length,
                    ),
                  ),
                  if (_isLoading)
                    const SliverToBoxAdapter(
                      child: TypingIndicator(),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
            MessageInputArea(
              controller: _controller,
              isLoading: _isLoading,
              onSendMessage: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}