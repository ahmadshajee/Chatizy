import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../models/chat_room.dart';
import '../models/profile.dart';

/// Handles chat operations: rooms, members, messages, and real-time subscriptions.
class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  // ─── Chat Rooms ──────────────────────────────────────────────────────

  /// Get all chat rooms the current user is a member of, with last message info.
  Future<List<ChatRoom>> getChatRooms() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    // Get room IDs user is a member of
    final memberData = await _client
        .from('room_members')
        .select('room_id')
        .eq('user_id', userId);

    if (memberData.isEmpty) return [];

    final roomIds = (memberData as List).map((m) => m['room_id'] as String).toList();

    // Get room details
    final roomsData = await _client
        .from('chat_rooms')
        .select()
        .inFilter('id', roomIds);

    final rooms = <ChatRoom>[];
    for (final roomJson in roomsData) {
      final room = ChatRoom.fromJson(roomJson);

      // Get members for display name
      final members = await _client
          .from('room_members')
          .select('user_id')
          .eq('room_id', room.id);
      room.memberIds = (members as List).map((m) => m['user_id'] as String).toList();

      // Get other member's name for 1-on-1 chats
      if (!room.isGroup) {
        final otherUserId = room.memberIds.firstWhere(
          (id) => id != userId,
          orElse: () => userId,
        );
        try {
          final otherProfile = await _client
              .from('profiles')
              .select('full_name, nickname')
              .eq('id', otherUserId)
              .single();
          room.displayName = (otherProfile['nickname'] as String?) ??
              (otherProfile['full_name'] as String?) ??
              'Unknown';
        } catch (_) {
          room.displayName = 'Unknown';
        }
      }

      // Get last message
      try {
        final lastMsg = await _client
            .from('messages')
            .select()
            .eq('room_id', room.id)
            .order('created_at', ascending: false)
            .limit(1)
            .single();
        room.lastMessage = lastMsg['content'] as String?;
        room.lastMessageTime = DateTime.tryParse(lastMsg['created_at'] as String? ?? '');
        room.lastMessageSenderName = lastMsg['sender_name'] as String?;
      } catch (_) {
        // No messages yet
      }

      rooms.add(room);
    }

    // Sort by last message time (most recent first)
    rooms.sort((a, b) {
      final aTime = a.lastMessageTime ?? a.createdAt;
      final bTime = b.lastMessageTime ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    return rooms;
  }

  /// Create a new 1-on-1 chat room between two users.
  Future<ChatRoom> createDirectChat({
    required String otherUserId,
    String? companyDomain,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    // Check if a DM room already exists between these two users
    final existingRooms = await _client
        .from('room_members')
        .select('room_id')
        .eq('user_id', userId);

    for (final memberRow in existingRooms) {
      final roomId = memberRow['room_id'] as String;
      final otherMembers = await _client
          .from('room_members')
          .select('user_id')
          .eq('room_id', roomId)
          .neq('user_id', userId);

      if (otherMembers.length == 1 && otherMembers[0]['user_id'] == otherUserId) {
        // Room already exists
        final roomData = await _client
            .from('chat_rooms')
            .select()
            .eq('id', roomId)
            .single();
        final room = ChatRoom.fromJson(roomData);
        if (!room.isGroup) return room;
      }
    }

    // Create new room
    // Only set company_domain if the current user belongs to that domain.
    // For cross-domain chats (e.g. personal user → employee), leave it null
    // to avoid RLS policy violations.
    String? roomDomain;
    if (companyDomain != null) {
      try {
        final currentProfile = await _client
            .from('profiles')
            .select('company_domain')
            .eq('id', userId)
            .single();
        final userDomain = currentProfile['company_domain'] as String?;
        if (userDomain != null && userDomain == companyDomain) {
          roomDomain = companyDomain;
        }
      } catch (_) {
        // If we can't fetch, leave roomDomain null to be safe
      }
    }

    final roomData = await _client
        .from('chat_rooms')
        .insert({
          'company_domain': roomDomain,
          'is_group': false,
        })
        .select()
        .single();

    final room = ChatRoom.fromJson(roomData);

    // Add both users as members
    await _client.from('room_members').insert([
      {'room_id': room.id, 'user_id': userId},
      {'room_id': room.id, 'user_id': otherUserId},
    ]);

    room.memberIds = [userId, otherUserId];
    return room;
  }

  // ─── Messages ────────────────────────────────────────────────────────

  /// Get all messages in a room, ordered chronologically.
  Future<List<Message>> getMessages(String roomId) async {
    final userId = _currentUserId;
    final data = await _client
        .from('messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true);

    return (data as List).map((json) {
      final msg = Message.fromJson(json);
      msg.isMe = msg.senderId == userId;
      return msg;
    }).toList();
  }

  /// Send a message in a room.
  Future<Message> sendMessage({
    required String roomId,
    required String content,
    required String senderName,
    String? receiverDomain,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final data = await _client
        .from('messages')
        .insert({
          'room_id': roomId,
          'sender_id': userId,
          'sender_name': senderName,
          'receiver_domain': receiverDomain,
          'content': content,
        })
        .select()
        .single();

    final msg = Message.fromJson(data);
    msg.isMe = true;
    return msg;
  }

  /// Subscribe to new messages in a room (real-time).
  RealtimeChannel subscribeToMessages(
    String roomId,
    void Function(Message message) onMessage,
  ) {
    final userId = _currentUserId;
    return _client
        .channel('messages:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            final msg = Message.fromJson(payload.newRecord);
            msg.isMe = msg.senderId == userId;
            onMessage(msg);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from a channel.
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  // ─── Contacts / User Search ──────────────────────────────────────────

  /// Search for users by name, email, or nickname.
  Future<List<Profile>> searchUsers(String query) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final data = await _client
          .from('profiles')
          .select()
          .or('full_name.ilike.%$query%,nickname.ilike.%$query%,email.ilike.%$query%')
          .neq('id', userId)
          .limit(20);

      return (data as List).map((json) => Profile.fromJson(json)).toList();
    } catch (e) {
      // Fallback if the email column is missing on profiles table
      try {
        final data = await _client
            .from('profiles')
            .select()
            .or('full_name.ilike.%$query%,nickname.ilike.%$query%')
            .neq('id', userId)
            .limit(20);

        return (data as List).map((json) => Profile.fromJson(json)).toList();
      } catch (innerError) {
        return [];
      }
    }
  }

  /// Search for a user by exact email address.
  /// Returns the profile if found, null otherwise.
  Future<Profile?> searchByEmail(String email) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .ilike('email', email.trim())
          .neq('id', userId)
          .limit(1);

      if ((data as List).isEmpty) return null;
      return Profile.fromJson(data.first);
    } on PostgrestException catch (e) {
      if (e.code == '42703' || e.message.contains('column') && e.message.contains('does not exist')) {
        throw Exception(
          'Database migration required: The "email" column is missing in your Supabase "profiles" table. Please run the SQL migration in your Supabase dashboard to enable email search.'
        );
      }
      throw Exception('Search failed: ${e.message}');
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Get all employees in a company domain.
  Future<List<Profile>> getCompanyEmployees(String domain) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('company_domain', domain)
        .order('full_name');

    return (data as List).map((json) => Profile.fromJson(json)).toList();
  }

  /// Get contacts for personal users (anyone they have a DM with).
  Future<List<Profile>> getPersonalContacts() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      // Get all room IDs user is a member of
      final memberData = await _client
          .from('room_members')
          .select('room_id')
          .eq('user_id', userId);

      if (memberData.isEmpty) return [];

      final roomIds = (memberData as List).map((m) => m['room_id'] as String).toList();

      // Find other member IDs in those rooms
      final allMembers = await _client
          .from('room_members')
          .select('room_id, user_id')
          .inFilter('room_id', roomIds);

      // Group members by room ID to identify 1-on-1 direct rooms
      final roomToUsers = <String, List<String>>{};
      for (final row in allMembers as List) {
        final rId = row['room_id'] as String;
        final uId = row['user_id'] as String;
        roomToUsers.putIfAbsent(rId, () => []).add(uId);
      }

      final contactIds = <String>{};
      for (final entry in roomToUsers.entries) {
        final users = entry.value;
        if (users.length == 2) {
          final otherId = users.firstWhere((id) => id != userId, orElse: () => '');
          if (otherId.isNotEmpty) {
            contactIds.add(otherId);
          }
        }
      }

      if (contactIds.isEmpty) return [];

      // Fetch profiles of these contacts
      final profilesData = await _client
          .from('profiles')
          .select()
          .inFilter('id', contactIds.toList())
          .order('full_name');

      return (profilesData as List).map((json) => Profile.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get a single user profile by ID.
  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  // ─── Read Receipts ──────────────────────────────────────────────────

  /// Mark all messages in a room as read (messages not sent by current user).
  Future<void> markMessagesAsRead(String roomId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('room_id', roomId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } catch (e) {
      // Silently fail — read receipts are non-critical
    }
  }

  // ─── Starred Messages ───────────────────────────────────────────────

  /// Star a message.
  Future<void> starMessage(String messageId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _client.from('starred_messages').upsert({
      'user_id': userId,
      'message_id': messageId,
    });
  }

  /// Unstar a message.
  Future<void> unstarMessage(String messageId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _client
        .from('starred_messages')
        .delete()
        .eq('user_id', userId)
        .eq('message_id', messageId);
  }

  /// Get all starred message IDs for the current user.
  Future<Set<String>> getStarredMessageIds() async {
    final userId = _currentUserId;
    if (userId == null) return {};

    try {
      final data = await _client
          .from('starred_messages')
          .select('message_id')
          .eq('user_id', userId);

      return (data as List).map((r) => r['message_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Get all starred messages with full message data.
  Future<List<Message>> getStarredMessages() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final starredData = await _client
          .from('starred_messages')
          .select('message_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (starredData.isEmpty) return [];

      final messageIds = (starredData as List)
          .map((r) => r['message_id'] as String)
          .toList();

      final messagesData = await _client
          .from('messages')
          .select()
          .inFilter('id', messageIds);

      return (messagesData as List).map((json) {
        final msg = Message.fromJson(json);
        msg.isMe = msg.senderId == userId;
        return msg;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Export all messages for backup as a list of JSON maps.
  Future<List<Map<String, dynamic>>> exportAllMessages() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    // Get room IDs user is a member of
    final memberData = await _client
        .from('room_members')
        .select('room_id')
        .eq('user_id', userId);

    if (memberData.isEmpty) return [];

    final roomIds = (memberData as List).map((m) => m['room_id'] as String).toList();

    // Get all messages from those rooms
    final messagesData = await _client
        .from('messages')
        .select()
        .inFilter('room_id', roomIds)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(messagesData);
  }

  // ─── Contact Management ─────────────────────────────────────────────

  /// Remove a contact by deleting the DM room between the current user and the contact.
  Future<void> removeContact(String contactId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    // Find DM rooms where both users are members
    final myRooms = await _client
        .from('room_members')
        .select('room_id')
        .eq('user_id', userId);

    for (final row in myRooms) {
      final roomId = row['room_id'] as String;

      // Check if the contact is also a member of this room
      final otherMembers = await _client
          .from('room_members')
          .select('user_id')
          .eq('room_id', roomId)
          .eq('user_id', contactId);

      if (otherMembers.isNotEmpty) {
        // Verify it's a 1-on-1 room (not a group)
        final roomData = await _client
            .from('chat_rooms')
            .select('is_group')
            .eq('id', roomId)
            .single();

        if (roomData['is_group'] == false) {
          // Delete room members first, then messages, then the room
          await _client.from('room_members').delete().eq('room_id', roomId);
          await _client.from('messages').delete().eq('room_id', roomId);
          await _client.from('chat_rooms').delete().eq('id', roomId);
          return;
        }
      }
    }
  }

  /// Remove multiple contacts at once.
  Future<void> removeContacts(List<String> contactIds) async {
    for (final id in contactIds) {
      await removeContact(id);
    }
  }

  /// Send a broadcast message to multiple users.
  /// Creates DM rooms if they don't exist, then sends the message to each.
  Future<int> broadcastMessage({
    required List<String> recipientIds,
    required String content,
    required String senderName,
    String? senderDomain,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return 0;

    int sentCount = 0;
    for (final recipientId in recipientIds) {
      try {
        // Get or create DM room
        final room = await createDirectChat(
          otherUserId: recipientId,
          companyDomain: senderDomain,
        );

        // Send message
        await _client.from('messages').insert({
          'room_id': room.id,
          'sender_id': userId,
          'sender_name': senderName,
          'content': content,
        });

        sentCount++;
      } catch (e) {
        // Skip failed sends, continue with others
      }
    }
    return sentCount;
  }

  /// Create a group chat with multiple members.
  Future<ChatRoom> createGroupChat({
    required String groupName,
    required List<String> memberIds,
    String? companyDomain,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final roomData = await _client
        .from('chat_rooms')
        .insert({
          'company_domain': companyDomain,
          'is_group': true,
        })
        .select()
        .single();

    final room = ChatRoom.fromJson(roomData);
    room.displayName = groupName;

    // Add all members including current user
    final allMembers = <String>{userId, ...memberIds};
    await _client.from('room_members').insert(
      allMembers.map((id) => {'room_id': room.id, 'user_id': id}).toList(),
    );

    room.memberIds = allMembers.toList();
    return room;
  }
}
