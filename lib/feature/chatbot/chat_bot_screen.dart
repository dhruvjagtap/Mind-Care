import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  static const routeName = '/chatbot';

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  bool _isBotTyping = false;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Show friendly welcome message when screen opens
    _messages.add({
      "role": "bot",
      "text": "Hi, I’m Lumi ✨. I’m here for you. How are you feeling today?",
      "time": DateTime.now().toIso8601String(),
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "role": "user",
        "text": _controller.text.trim(),
        "time": DateTime.now().toIso8601String(),
      });
    });

    String userMessage = _controller.text.trim();
    _controller.clear();

    _scrollToBottom();

    // Show typing indicator
    setState(() => _isBotTyping = true);

    // Fake bot reply
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isBotTyping = false;
        _messages.add({
          "role": "bot",
          "text": "I hear you. Let's talk more about: $userMessage",
          "time": DateTime.now().toIso8601String(),
        });
      });
      _scrollToBottom();
    });
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
