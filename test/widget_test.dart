import 'package:flutter_test/flutter_test.dart';
import 'package:chatizy/models/message.dart';

void main() {
  group('Message Model Tests', () {
    test('Message.fromJson parsing', () {
      final json = {
        'id': 'msg-123',
        'room_id': 'room-456',
        'sender_id': 'sender-789',
        'sender_name': 'Alice',
        'receiver_domain': 'example.com',
        'content': 'Hello World',
        'created_at': '2026-06-06T00:00:00.000Z',
        'is_read': true,
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg-123');
      expect(message.roomId, 'room-456');
      expect(message.senderId, 'sender-789');
      expect(message.senderName, 'Alice');
      expect(message.receiverDomain, 'example.com');
      expect(message.content, 'Hello World');
      expect(message.isRead, true);
    });

    test('isMediaUrl detects storage and supabase links', () {
      final msg1 = Message(
        id: '1',
        roomId: 'room',
        senderId: 'sender',
        senderName: 'name',
        content: 'https://supabase.co/storage/v1/object/public/avatar.png',
        createdAt: DateTime.now(),
      );
      expect(msg1.isMediaUrl, true);

      final msg2 = Message(
        id: '2',
        roomId: 'room',
        senderId: 'sender',
        senderName: 'name',
        content: 'Hello World',
        createdAt: DateTime.now(),
      );
      expect(msg2.isMediaUrl, false);
    });
  });
}
