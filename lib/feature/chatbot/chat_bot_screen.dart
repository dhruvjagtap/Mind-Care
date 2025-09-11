import 'package:flutter/material.dart';
import '../analytics/analytics_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String initialMood;

  const ChatbotScreen({super.key, required this.initialMood});

  static const routeName = '/chatbot';

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  bool _isBotTyping = false;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String introMessage;

  @override
  void initState() {
    super.initState();

    // Log chatbot opened with mood
    analyticsService.logEvent(
      "chatbot_opened",
      params: {"mood": widget.initialMood},
    );

    // Set intro message based on mood
    switch (widget.initialMood) {
      case "happy":
        introMessage = "Hi! Want to chat or explore resources today?";
        break;
      case "neutral":
        introMessage = "😐 Okay! Want to talk about how your day is going?";
        break;
      case "sad":
        introMessage =
            "🙁 I’m here for you. Want to share what’s on your mind?";
        break;
      case "none":
        introMessage =
            "Hi, I’m Lumi ✨. I’m here for you. How are you feeling today?";
        break;
      default:
        introMessage =
            "Hi, I’m Lumi ✨. I’m here for you. How are you feeling today?";
    }

    // Show friendly welcome message when screen opens
    _messages.add({
      "role": "bot",
      "text": introMessage,
      "time": DateTime.now().toIso8601String(),
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();

    setState(() {
      _messages.add({
        "role": "user",
        "text": userMessage,
        "time": DateTime.now().toIso8601String(),
      });
    });

    _controller.clear();
    _scrollToBottom();

    // 📌 1. Log user message
    analyticsService.logEvent(
      "chatbot_message_sent",
      params: {"text": userMessage},
    );

    // 📌 2. Detect inferred mood from message
    String inferredMood = _detectMood(userMessage);

    // 📌 3. Log inferred mood
    analyticsService.logEvent(
      "chatbot_inferred_mood",
      params: {"mood": inferredMood},
    );

    // 📌 4. Optional: trigger special treatment
    if (inferredMood == "sad") {
      analyticsService.logEvent("chatbot_trigger_special_treatment");
      // TODO: here you can suggest resources or counsellor booking
    }

    // Show typing indicator
    setState(() => _isBotTyping = true);

    Future.delayed(const Duration(seconds: 2), () {
      final responseText = "I hear you. Let's talk more about: $userMessage";

      setState(() {
        _isBotTyping = false;
        _messages.add({
          "role": "bot",
          "text": responseText,
          "time": DateTime.now().toIso8601String(),
        });
      });

      // 📌 5. Log bot response
      analyticsService.logEvent(
        "chatbot_bot_response",
        params: {"response": responseText},
      );

      _scrollToBottom();
    });
  }

  String _detectMood(String message) {
    final lower = message.toLowerCase();

    final sadKeywords = [
      "sad",
      "stressed",
      "tired",
      "anxious",
      "hopeless",
      "lonely",
      "angry",
    ];
    final happyKeywords = ["happy", "excited", "good", "great", "awesome"];

    if (sadKeywords.any((word) => lower.contains(word))) {
      return "sad";
    } else if (happyKeywords.any((word) => lower.contains(word))) {
      return "happy";
    } else {
      return "neutral";
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

  String _formatTime(String? isoString) {
    if (isoString == null) return "";
    final dt = DateTime.parse(isoString);
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Lumi ✨")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isBotTyping && index == _messages.length) {
                  // Typing indicator
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        child: Icon(Icons.favorite, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("Typing..."),
                      ),
                    ],
                  );
                }

                final message = _messages[index];
                bool isUser = message["role"] == "user";

                // The chat bubble
                final messageBubble = Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: isUser
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message["text"] ?? "",
                        style: TextStyle(
                          color: isUser
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message["time"]),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );

                // Bot bubble with avatar
                if (!isUser) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        radius: 18,
                        child: Icon(Icons.auto_awesome, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Flexible(child: messageBubble),
                    ],
                  );
                }

                // User bubble
                return Align(
                  alignment: Alignment.centerRight,
                  child: messageBubble,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.surfaceVariant,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
