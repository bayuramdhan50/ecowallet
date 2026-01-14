import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool read;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  factory ChatMessage.fromMap(String id, Map<dynamic, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'read': read,
    };
  }
}

class ChatService {
  // Explicitly use database from the correct region (asia-southeast1)
  DatabaseReference get _database {
    try {
      // Get the database instance with the correct URL
      final firebaseApp = Firebase.app();
      final databaseURL =
          'https://ecowallet-97c36-default-rtdb.asia-southeast1.firebasedatabase.app';

      return FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL: databaseURL,
      ).ref();
    } catch (e) {
      print('Error getting database reference: $e');
      rethrow;
    }
  }

  // Generate a unique chat ID between two users (always same regardless of order)
  String getChatId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}_${users[1]}';
  }

  // Send a message
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final senderId = prefs.getString('userId') ?? '';

      if (senderId.isEmpty) {
        throw Exception('User not logged in');
      }

      final chatId = getChatId(senderId, receiverId);
      final messageRef = _database.child('messages').child(chatId).push();

      final chatMessage = ChatMessage(
        id: messageRef.key!,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        read: false,
      );

      await messageRef.set(chatMessage.toMap());

      // Update chat metadata
      await _database.child('chats').child(chatId).set({
        'participants': [senderId, receiverId],
        'lastMessage': message,
        'lastMessageTime': chatMessage.timestamp.millisecondsSinceEpoch,
        'lastSenderId': senderId,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream for a specific chat
  Stream<List<ChatMessage>> getMessages(String otherUserId) async* {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        yield [];
        return;
      }

      final chatId = getChatId(userId, otherUserId);
      final messagesRef = _database.child('messages').child(chatId);

      await for (final event in messagesRef.onValue) {
        final messages = <ChatMessage>[];
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            messages.add(
              ChatMessage.fromMap(key, value as Map<dynamic, dynamic>),
            );
          });

          // Sort by timestamp
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        }
        yield messages;
      }
    } catch (e) {
      yield [];
    }
  }

  // Get all chats for admin
  Stream<List<Map<String, dynamic>>> getAllChats() async* {
    try {
      final chatsRef = _database.child('chats');

      await for (final event in chatsRef.onValue) {
        final chatsList = <Map<String, dynamic>>[];
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          data.forEach((chatId, chatData) {
            final chat = Map<String, dynamic>.from(chatData as Map);
            chat['chatId'] = chatId;
            chatsList.add(chat);
          });

          // Sort by last message time (newest first)
          chatsList.sort((a, b) {
            final aTime = a['lastMessageTime'] ?? 0;
            final bTime = b['lastMessageTime'] ?? 0;
            return bTime.compareTo(aTime);
          });
        }
        yield chatsList;
      }
    } catch (e) {
      yield [];
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String otherUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) return;

      final chatId = getChatId(userId, otherUserId);
      final messagesRef = _database.child('messages').child(chatId);

      final snapshot = await messagesRef.get();
      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final updates = <String, dynamic>{};

        data.forEach((key, value) {
          final msg = value as Map<dynamic, dynamic>;
          if (msg['receiverId'] == userId && msg['read'] == false) {
            updates['$key/read'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await messagesRef.update(updates);
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  // Get admin ID from backend (first admin user)
  Future<String> getAdminId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Check if current user is admin
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final user = json.decode(userData);
        if (user['role'] == 'admin') {
          return user['id'].toString();
        }
      }

      // Cache admin ID in preferences
      String? cachedAdminId = prefs.getString('cached_admin_id');
      if (cachedAdminId != null) {
        return cachedAdminId;
      }

      // Fetch from backend - get any admin user
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:3000/api/users'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            final users = data['data'] as List;
            // Find first admin user
            final admin = users.firstWhere(
              (u) => u['role'] == 'admin',
              orElse: () => null,
            );

            if (admin != null) {
              final adminId = admin['id'].toString();
              await prefs.setString('cached_admin_id', adminId);
              return adminId;
            }
          }
        }
      }

      // Fallback: return '1' as default admin ID
      return '1';
    } catch (e) {
      print('Error getting admin ID: $e');
      return '1'; // Default fallback
    }
  }
}
