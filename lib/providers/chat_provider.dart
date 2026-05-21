import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../models/profile.dart';
import '../services/chat_service.dart';

/// Manages chat state: room list, active conversation messages, and real-time streams.
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatRoom> _rooms = [];
  List<Message> _messages = [];
  ChatRoom? _activeRoom;
  Profile? _activeChatPartner;
  bool _isLoading = false;
  RealtimeChannel? _messageChannel;
  Set<String> _starredMessageIds = {};

  List<ChatRoom> get rooms => _rooms;
  List<Message> get messages => _messages;
  ChatRoom? get activeRoom => _activeRoom;
  Profile? get activeChatPartner => _activeChatPartner;
  bool get isLoading => _isLoading;
  Set<String> get starredMessageIds => _starredMessageIds;

  /// Load all chat rooms for the current user.
  Future<void> loadRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rooms = await _chatService.getChatRooms();
    } catch (e) {
      debugPrint('Error loading rooms: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Open a conversation: load messages and subscribe to real-time updates.
  Future<void> openConversation(ChatRoom room) async {
    // Unsubscribe from previous room
    await _closeConversation();

    _activeRoom = room;
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _chatService.getMessages(room.id);

      // Load chat partner profile for 1-on-1 chats
      if (!room.isGroup && room.memberIds.length >= 2) {
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final partnerId = room.memberIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => room.memberIds.first,
        );
        _activeChatPartner = await _chatService.getProfile(partnerId);
      }

      // Load starred message IDs
      _starredMessageIds = await _chatService.getStarredMessageIds();

      // Mark messages as read when opening conversation
      await _chatService.markMessagesAsRead(room.id);
      for (final msg in _messages) {
        if (!msg.isMe) msg.isRead = true;
      }

      // Subscribe to new messages
      _messageChannel = _chatService.subscribeToMessages(room.id, (message) {
        // Avoid duplicates
        if (!_messages.any((m) => m.id == message.id)) {
          _messages.add(message);
          // Auto-mark incoming messages as read since we're in the conversation
          if (!message.isMe) {
            _chatService.markMessagesAsRead(room.id);
            message.isRead = true;
          }
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error opening conversation: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Send a message in the active room.
  Future<void> sendMessage(String content, String senderName, {String? receiverDomain}) async {
    if (_activeRoom == null || content.trim().isEmpty) return;

    try {
      final msg = await _chatService.sendMessage(
        roomId: _activeRoom!.id,
        content: content.trim(),
        senderName: senderName,
        receiverDomain: receiverDomain,
      );

      // Add locally if not already added by real-time
      if (!_messages.any((m) => m.id == msg.id)) {
        _messages.add(msg);
        notifyListeners();
      }

      // Update room's last message
      _activeRoom!.lastMessage = content.trim();
      _activeRoom!.lastMessageTime = msg.createdAt;
      _activeRoom!.lastMessageSenderName = senderName;
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  /// Start a new direct chat with a user.
  Future<ChatRoom?> startDirectChat(String otherUserId, {String? companyDomain}) async {
    try {
      final room = await _chatService.createDirectChat(
        otherUserId: otherUserId,
        companyDomain: companyDomain,
      );
      await loadRooms(); // Refresh room list
      return room;
    } catch (e) {
      debugPrint('Error creating chat: $e');
      rethrow;
    }
  }

  /// Search for users.
  Future<List<Profile>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    return _chatService.searchUsers(query);
  }

  /// Search for a user by exact email address.
  Future<Profile?> searchByEmail(String email) async {
    if (email.trim().isEmpty) return null;
    return _chatService.searchByEmail(email);
  }

  /// Get company employees.
  Future<List<Profile>> getCompanyEmployees(String domain) async {
    return _chatService.getCompanyEmployees(domain);
  }

  /// Get personal contacts (anyone the user has a direct chat with).
  Future<List<Profile>> getPersonalContacts() async {
    return _chatService.getPersonalContacts();
  }

  // ─── Starred Messages ───────────────────────────────────────────────

  /// Toggle star on a message.
  Future<void> toggleStarMessage(String messageId) async {
    if (_starredMessageIds.contains(messageId)) {
      _starredMessageIds.remove(messageId);
      notifyListeners();
      await _chatService.unstarMessage(messageId);
    } else {
      _starredMessageIds.add(messageId);
      notifyListeners();
      await _chatService.starMessage(messageId);
    }
  }

  /// Check if a message is starred.
  bool isMessageStarred(String messageId) {
    return _starredMessageIds.contains(messageId);
  }

  /// Get all starred messages.
  Future<List<Message>> getStarredMessages() async {
    return _chatService.getStarredMessages();
  }

  // ─── Chat Backup ────────────────────────────────────────────────────

  /// Export all messages for backup.
  Future<List<Map<String, dynamic>>> exportMessages() async {
    return _chatService.exportAllMessages();
  }

  // ─── Contact Management ─────────────────────────────────────────────

  /// Remove a contact (deletes the DM room between them).
  Future<void> removeContact(String contactId) async {
    try {
      await _chatService.removeContact(contactId);
      await loadRooms(); // Refresh room list
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing contact: $e');
    }
  }

  /// Remove multiple contacts at once.
  Future<void> removeContacts(List<String> contactIds) async {
    try {
      await _chatService.removeContacts(contactIds);
      await loadRooms();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing contacts: $e');
    }
  }

  /// Send a broadcast message to multiple users.
  Future<int> broadcastMessage({
    required List<String> recipientIds,
    required String content,
    required String senderName,
    String? senderDomain,
  }) async {
    try {
      final count = await _chatService.broadcastMessage(
        recipientIds: recipientIds,
        content: content,
        senderName: senderName,
        senderDomain: senderDomain,
      );
      await loadRooms();
      return count;
    } catch (e) {
      debugPrint('Error broadcasting: $e');
      return 0;
    }
  }

  /// Create a group chat.
  Future<ChatRoom?> createGroupChat({
    required String groupName,
    required List<String> memberIds,
    String? companyDomain,
  }) async {
    try {
      final room = await _chatService.createGroupChat(
        groupName: groupName,
        memberIds: memberIds,
        companyDomain: companyDomain,
      );
      await loadRooms();
      return room;
    } catch (e) {
      debugPrint('Error creating group: $e');
      return null;
    }
  }

  /// Close active conversation and unsubscribe.
  Future<void> _closeConversation() async {
    if (_messageChannel != null) {
      await _chatService.unsubscribe(_messageChannel!);
      _messageChannel = null;
    }
    _activeRoom = null;
    _activeChatPartner = null;
    _messages = [];
    _starredMessageIds = {};
  }

  /// Navigate back from conversation.
  Future<void> closeConversation() async {
    await _closeConversation();
    notifyListeners();
  }

  @override
  void dispose() {
    _closeConversation();
    super.dispose();
  }
}
