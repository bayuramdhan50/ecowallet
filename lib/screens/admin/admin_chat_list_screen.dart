import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../services/chat_service.dart';
import 'admin_chat_detail_screen.dart';
import 'package:intl/intl.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final ChatService _chatService = ChatService();
  String _myAdminId = '';

  @override
  void initState() {
    super.initState();
    _loadAdminId();
  }

  Future<void> _loadAdminId() async {
    final adminId = await _chatService.getAdminId();
    setState(() {
      _myAdminId = adminId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Messages'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getAllChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = List<String>.from(
                chat['participants'] ?? [],
              );

              // Get client ID (not the admin)
              final clientId = participants.firstWhere(
                (id) => id != _myAdminId,
                orElse: () => 'Unknown',
              );

              final lastMessage = chat['lastMessage'] ?? '';
              final lastTime = chat['lastMessageTime'] ?? 0;
              final lastSenderId = chat['lastSenderId'] ?? '';
              final isSentByAdmin = lastSenderId == _myAdminId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                  child: Text(
                    clientId.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(
                  'User $clientId',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    if (isSentByAdmin) ...[
                      const Icon(Icons.done, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  _formatTime(lastTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminChatDetailScreen(clientId: clientId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return '';

    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}
