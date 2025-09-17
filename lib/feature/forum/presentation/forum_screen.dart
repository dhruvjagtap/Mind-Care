import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forum_provider.dart';

final forumMessagesProvider = StreamProvider<QuerySnapshot>((ref) {
  final forumRef = FirebaseFirestore.instance.collection('forums');
  return forumRef.orderBy('createdAt', descending: true).snapshots();
});

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});
  static const routeName = '/forums';

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _reportController = TextEditingController();

  String? _replyToMessageId;
  String? _replyToMessageText;
  final Set<String> _selectedMessages = {};
  bool _selectionMode = false;

  @override
  void dispose() {
    _controller.dispose();
    _reportController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    try {
      await ref
          .read(forumServiceProvider)
          .sendMessage(
            ref,
            message,
            replyTo: _replyToMessageId != null
                ? {'messageId': _replyToMessageId, 'text': _replyToMessageText}
                : null,
          );

      _controller.clear();

      if (!mounted) return;
      setState(() {
        _replyToMessageId = null;
        _replyToMessageText = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send message: $e")));
    }
  }

  void _showReactionPicker(String postId) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Text('👍', style: TextStyle(fontSize: 24)),
              onPressed: () {
                ref.read(forumServiceProvider).reactPost(postId, '👍');
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Text('❤️', style: TextStyle(fontSize: 24)),
              onPressed: () {
                ref.read(forumServiceProvider).reactPost(postId, '❤️');
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Text('😂', style: TextStyle(fontSize: 24)),
              onPressed: () {
                ref.read(forumServiceProvider).reactPost(postId, '😂');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // toggle selection
  void _toggleSelection(String msgId) {
    setState(() {
      if (_selectedMessages.contains(msgId)) {
        _selectedMessages.remove(msgId);
        if (_selectedMessages.isEmpty) _selectionMode = false;
      } else {
        _selectedMessages.add(msgId);
        _selectionMode = true;
      }
    });
  }

  void _showReportDialog(String messageId) {
    _reportController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Message'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Why are you reporting this message?'),
              TextField(
                controller: _reportController,
                decoration: const InputDecoration(
                  hintText: 'Reason (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reason = _reportController.text.trim();
              await ref
                  .read(forumServiceProvider)
                  .reportMessage(ref, messageId, reason);
              Navigator.pop(ctx);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Message reported')));
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  // void _showReactionsDetails(Map<String, dynamic> reactions) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (ctx) {
  //       return ListView(
  //         shrinkWrap: true,
  //         children: reactions.entries.map((entry) {
  //           final userId = entry.key;
  //           final emoji = entry.value;

  //           // Shorten userId for display (you can replace with profile name if available)
  //           final shortUserId = userId.length > 6
  //               ? userId.substring(0, 6)
  //               : userId;

  //           return ListTile(
  //             leading: Text(emoji, style: const TextStyle(fontSize: 20)),
  //             title: Text("User$shortUserId"),
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }

  void _showReactionsDetails(Map<String, dynamic> reactions) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          shrinkWrap: true,
          children: reactions.entries.map((entry) {
            final userId = entry.key;
            final value = entry.value;

            // 🔹 Support both old (string) and new (map) formats
            String emoji;
            if (value is String) {
              emoji = value;
            } else if (value is Map<String, dynamic>) {
              emoji = value['emoji'] as String? ?? '';
            } else {
              emoji = '❓';
            }

            final shortUserId = userId.length > 6
                ? userId.substring(0, 6)
                : userId;

            return ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 20)),
              title: Text("User$shortUserId"),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesStream = ref.watch(forumMessagesProvider);

    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedMessages.clear();
                    _selectionMode = false;
                  });
                },
              ),
              title: Text("${_selectedMessages.length} selected"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () async {
                    for (final id in _selectedMessages) {
                      await FirebaseFirestore.instance
                          .collection('forums')
                          .doc(id)
                          .update({'starred': true});
                    }
                    setState(() {
                      _selectedMessages.clear();
                      _selectionMode = false;
                    });
                  },
                ),
                if (_selectedMessages.length == 1)
                  IconButton(
                    icon: const Icon(Icons.report),
                    onPressed: () {
                      final msgId = _selectedMessages.first;
                      _showReportDialog(msgId);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    for (final id in _selectedMessages) {
                      // get doc to check author
                      final doc = await FirebaseFirestore.instance
                          .collection('forums')
                          .doc(id)
                          .get();
                      if (!doc.exists) continue;

                      final data = doc.data() ?? {}; // 🔹 CHANGE: null-safe
                      final authorId = data['userId'] as String?;

                      try {
                        if (authorId != null && authorId == currentUser?.uid) {
                          await ref
                              .read(forumServiceProvider)
                              .deleteMessage(id);
                        } else {
                          await ref.read(forumServiceProvider).deleteForMe(id);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Delete failed: $e")),
                          );
                        }
                      }
                    }

                    if (!mounted) return;

                    setState(() {
                      _selectedMessages.clear();
                      _selectionMode = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Selected messages removed from your view',
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          : AppBar(
              title: const Text("Forum"),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "clear") {
                      // clear chat logic
                    } else if (value == "search") {
                      // search logic
                    } else if (value == "media") {
                      // media links docs
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: "clear",
                      child: Text("Clear Chat"),
                    ),
                    const PopupMenuItem(value: "search", child: Text("Search")),
                    const PopupMenuItem(
                      value: "media",
                      child: Text("Media, Links, Docs"),
                    ),
                  ],
                ),
              ],
            ),

      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (snapshot) {
                final docs = snapshot.docs;
                final currentUser = FirebaseAuth.instance.currentUser;

                // filter out documents that contain current user's uid in `hiddenFor`
                final messages = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data == null) return false;
                  if (!data.containsKey('hiddenFor')) return true;
                  final hiddenList = List<String>.from(data['hiddenFor']);
                  return !(currentUser != null &&
                      hiddenList.contains(currentUser.uid));
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final data = msg.data() as Map<String, dynamic>;

                    // 🔹 Safely get userId
                    final userId = data['userId'] as String? ?? '';
                    final isMe = userId == currentUser?.uid;
                    final shortUserId = userId.length > 6
                        ? userId.substring(0, 6)
                        : userId;

                    // 🔹 Safely get message text
                    final messageText = data['message'] as String? ?? '';

                    // 🔹 Safely get reply info
                    String? replyText;
                    if (data.containsKey('replyTo') && data['replyTo'] is Map) {
                      final replyMap = Map<String, dynamic>.from(
                        data['replyTo'],
                      );
                      replyText = replyMap['text'] as String? ?? '';
                    }

                    // 🔹 Safely get reactions
                    final reactions =
                        data.containsKey('reactions') &&
                            data['reactions'] is Map
                        ? Map<String, dynamic>.from(data['reactions'])
                        : <String, dynamic>{};

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () {
                          _toggleSelection(msg.id);
                          if (_selectedMessages.length == 1) {
                            _showReactionPicker(msg.id);
                          }
                        },
                        onTap: () {
                          if (_selectionMode) {
                            _toggleSelection(msg.id);
                          } else {
                            _showReactionPicker(msg.id);
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (isMe && details.primaryVelocity! < 0) {
                              setState(() {
                                _replyToMessageId = msg.id;
                                _replyToMessageText = messageText;
                              });
                            } else if (!isMe && details.primaryVelocity! > 0) {
                              setState(() {
                                _replyToMessageId = msg.id;
                                _replyToMessageText = messageText;
                              });
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _selectedMessages.contains(msg.id)
                                ? Colors.blue.withOpacity(0.3)
                                : (isMe
                                      ? Colors.blue
                                      : theme.colorScheme.surfaceVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (replyText != null && replyText.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    replyText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              Text(
                                messageText,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "User$shortUserId",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              if (reactions.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: (() {
                                    final Map<String, int> counts = {};
                                    for (final reaction in reactions.values) {
                                      final emoji = reaction is String
                                          ? reaction
                                          : (reaction['emoji'] ?? '');
                                      if (emoji.isEmpty) continue;
                                      counts[emoji] = (counts[emoji] ?? 0) + 1;
                                    }

                                    return counts.entries.map((entry) {
                                      final emoji = entry.key;
                                      final count = entry.value;
                                      return GestureDetector(
                                        onTap: () =>
                                            _showReactionsDetails(reactions),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            count > 1
                                                ? "$emoji ×$count"
                                                : emoji,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  })(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // Reply preview
          if (_replyToMessageId != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _replyToMessageText ?? '',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _replyToMessageId = null;
                        _replyToMessageText = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Share your thoughts...",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
