/// Message model matching the `public.messages` table.
class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? receiverDomain;
  final String content;
  final DateTime createdAt;
  bool isRead;

  /// Client-side flag for whether this message is from the current user.
  bool isMe;

  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.receiverDomain,
    required this.content,
    required this.createdAt,
    this.isMe = false,
    this.isRead = false,
  });

  /// Check if content is a Supabase Storage URL (image or audio).
  bool get isMediaUrl =>
      content.startsWith('http') &&
      (content.contains('storage') || content.contains('supabase'));

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? 'Unknown',
      receiverDomain: json['receiver_domain'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'receiver_domain': receiverDomain,
      'content': content,
    };
  }
}
