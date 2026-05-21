/// Chat room model matching the `public.chat_rooms` table.
class ChatRoom {
  final String id;
  final String? companyDomain;
  final bool isGroup;
  final DateTime createdAt;

  // Populated client-side after join queries
  List<String> memberIds;
  String? displayName;
  String? lastMessage;
  DateTime? lastMessageTime;
  String? lastMessageSenderName;
  int unreadCount;

  ChatRoom({
    required this.id,
    this.companyDomain,
    required this.isGroup,
    required this.createdAt,
    this.memberIds = const [],
    this.displayName,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderName,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      companyDomain: json['company_domain'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_domain': companyDomain,
      'is_group': isGroup,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
