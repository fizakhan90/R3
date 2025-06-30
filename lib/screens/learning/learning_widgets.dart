import 'package:flutter/material.dart';
import 'learning_theme.dart';
import 'learning_models.dart';

// --- Redesigned Welcome Card ---
class WelcomeCard extends StatelessWidget {
  final AnimationController fadeController;

  const WelcomeCard({super.key, required this.fadeController});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: fadeController, curve: Curves.easeIn),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: LearningTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LearningTheme.card.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome! 👋", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              LearningData.welcomeMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Redesigned Suggestion Grid ---
class SuggestionGrid extends StatelessWidget {
  final List<LearningTopic> suggestions;
  final AnimationController slideController;
  final Function(String) onTopicSelected;

  const SuggestionGrid({
    super.key,
    required this.suggestions,
    required this.slideController,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity: slideController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return TopicCard(
                topic: suggestions[index],
                onTap: () => onTopicSelected(suggestions[index].text),
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- Redesigned Topic Card (much cleaner) ---
class TopicCard extends StatelessWidget {
  final LearningTopic topic;
  final VoidCallback onTap;

  const TopicCard({super.key, required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LearningTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LearningTheme.card.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: topic.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(topic.icon, style: const TextStyle(fontSize: 24)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.text,
                      style: const TextStyle(
                        color: LearningTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: const TextStyle(
                        color: LearningTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Redesigned Message Bubble with better animations and layout ---
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ChatMessage? previousMessage; // To check if avatar is needed
  final Animation<double> animation;

  const MessageBubble({
    super.key,
    required this.message,
    this.previousMessage,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final bool showAvatar = !isUser && (previousMessage?.isUser ?? true);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (showAvatar) const AiAvatar(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(),
                    borderRadius: _getBorderRadius(isUser),
                  ),
                  child: SelectableText(
                    message.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBubbleColor() {
    if (message.isError) return LearningTheme.errorBubble;
    return message.isUser ? LearningTheme.userBubble : LearningTheme.aiBubble;
  }

  BorderRadius _getBorderRadius(bool isUser) {
    return BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: Radius.circular(isUser ? 22 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 22),
    );
  }
}

// --- AI Avatar Widget (reusable) ---
class AiAvatar extends StatelessWidget {
  const AiAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LearningTheme.accentGradient,
      ),
      child: const Center(
        child: Text("🤖", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// --- Redesigned Typing Indicator with a classic dot animation ---
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final List<Animation<double>> _animations = [];
  final int dotCount = 3;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      dotCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    for (int i = 0; i < dotCount; i++) {
      _animations.add(
        Tween<double>(begin: 0.0, end: -6.0).animate(
          CurvedAnimation(
            parent: _controllers[i],
            curve: Curves.easeInOut,
          ),
        ),
      );

      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AiAvatar(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: LearningTheme.aiBubble,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(dotCount, (index) {
                return AnimatedBuilder(
                  animation: _animations[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animations[index].value),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: LearningTheme.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Redesigned Message Input Area (cohesive and clean) ---
class MessageInputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSendMessage;

  const MessageInputArea({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasText = controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: LearningTheme.background,
        border: Border(
          top: BorderSide(color: LearningTheme.surface, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: LearningTheme.inputDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextField(
                    controller: controller,
                    enabled: !isLoading,
                    minLines: 1,
                    maxLines: 5,
                    style: const TextStyle(
                      color: LearningTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Start a new lesson...",
                      hintStyle: TextStyle(color: LearningTheme.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (text) {
                      if (!isLoading && hasText) onSendMessage(text);
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: hasText ? LearningTheme.accent : LearningTheme.card,
                    shape: const CircleBorder(),
                  ),
                  onPressed: isLoading || !hasText
                      ? null
                      : () => onSendMessage(controller.text.trim()),
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}