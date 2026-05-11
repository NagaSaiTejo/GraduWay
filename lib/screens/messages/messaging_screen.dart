import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../core/api_config.dart';

class MessagingListScreen extends ConsumerStatefulWidget {
  const MessagingListScreen({super.key});

  @override
  ConsumerState<MessagingListScreen> createState() =>
      _MessagingListScreenState();
}

class _MessagingListScreenState extends ConsumerState<MessagingListScreen> {
  List<dynamic> _connections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConnections();
  }

  Future<void> _fetchConnections() async {
    final email = ref.read(authProvider).loginEmail;
    try {
      final response = await http.get(Uri.parse(ApiConfig.connections(email)));
      if (response.statusCode == 200) {
        setState(() {
          _connections = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching connections: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Messages',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _connections.isEmpty
              ? const Center(
                  child: Text(
                      'No messages yet. Connect with alumni to start chatting!',
                      style: TextStyle(color: AppColors.textMuted)))
              : ListView.builder(
                  itemCount: _connections.length,
                  itemBuilder: (context, index) {
                    final conn = _connections[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: conn['profileImageUrl'] != null
                            ? NetworkImage(conn['profileImageUrl'])
                            : null,
                        child: conn['profileImageUrl'] == null
                            ? Text(conn['name'][0])
                            : null,
                      ),
                      title: Text(conn['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          conn['role'] == 'alumni' ? 'Alumni' : 'Student',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                  receiverEmail: conn['email'],
                                  receiverName: conn['name'])),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  final String receiverEmail;
  final String receiverName;

  const ChatScreen(
      {super.key, required this.receiverEmail, required this.receiverName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  List<dynamic> _messages = [];
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final senderEmail = ref.read(authProvider).loginEmail;
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.chatHistory(senderEmail, widget.receiverEmail)),
      );
      if (response.statusCode == 200) {
        setState(() {
          _messages = jsonDecode(response.body);
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final senderEmail = ref.read(authProvider).loginEmail;

    // Optimistic UI update
    final tempMsg = {
      'senderEmail': senderEmail,
      'receiverEmail': widget.receiverEmail,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };
    setState(() {
      _messages.add(tempMsg);
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    try {
      await http.post(
        Uri.parse(ApiConfig.messagingSend),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderEmail': senderEmail,
          'receiverEmail': widget.receiverEmail,
          'content': content,
        }),
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = ref.watch(authProvider).loginEmail;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(widget.receiverName,
            style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['senderEmail'] == currentUserEmail;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: isMe
                                ? null
                                : Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            msg['content'],
                            style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : AppColors.textPrimary),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.bgPage,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
