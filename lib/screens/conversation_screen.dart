import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';

/// Conversation view matching the Chatizy design mockup.
/// Blue outgoing bubbles (right), gray incoming bubbles (left),
/// read receipts (grey=sent, blue=read), online indicator, and message input bar.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();

    _messageController.clear();
    await chat.sendMessage(
      text,
      auth.currentProfile?.displayName ?? 'Unknown',
      receiverDomain: auth.currentProfile?.companyDomain,
    );
    _scrollToBottom();
  }

  void _showMessageActions(BuildContext context, Message message) {
    final chatProvider = context.read<ChatProvider>();
    final isStarred = chatProvider.isMessageStarred(message.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: ChatizyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ChatizyTheme.outlineVariant,
                  borderRadius: ChatizyTheme.radiusFull,
                ),
              ),
              ListTile(
                leading: Icon(
                  isStarred ? Icons.star : Icons.star_border,
                  color: isStarred
                      ? ChatizyTheme.starYellow
                      : ChatizyTheme.onSurfaceVariant,
                ),
                title: Text(isStarred ? 'Unstar Message' : 'Star Message'),
                onTap: () {
                  chatProvider.toggleStarMessage(message.id);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy,
                    color: ChatizyTheme.onSurfaceVariant),
                title: const Text('Copy Text'),
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;
    final partner = chatProvider.activeChatPartner;
    final room = chatProvider.activeRoom;

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: ChatizyTheme.surface,
      appBar: AppBar(
        backgroundColor: ChatizyTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: ChatizyTheme.primary, size: 20),
          onPressed: () {
            chatProvider.closeConversation();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ChatizyTheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      (partner?.displayName ?? room?.displayName ?? '?')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            color: ChatizyTheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
                // Online green dot
                if (partner?.isOnline == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ChatizyTheme.onlineGreen,
                        border: Border.all(
                          color: ChatizyTheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner?.displayName ?? room?.displayName ?? 'Chat',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Online status subtitle
                  Text(
                    partner?.isOnline == true
                        ? 'Online'
                        : partner != null
                            ? 'Last seen ${_formatLastSeen(partner.lastSeen)}'
                            : '',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: partner?.isOnline == true
                              ? ChatizyTheme.onlineGreen
                              : ChatizyTheme.outline,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: ChatizyTheme.primary))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: ChatizyTheme.marginPage, vertical: 8),
                    itemCount: messages.length + 1, // +1 for encryption notice
                    itemBuilder: (context, index) {
                      // Encryption notice in the middle
                      if (index == messages.length ~/ 2 &&
                          messages.length > 2) {
                        return _EncryptionNotice();
                      }

                      final msgIndex =
                          index > messages.length ~/ 2 && messages.length > 2
                              ? index - 1
                              : index;

                      if (msgIndex >= messages.length) {
                        return const SizedBox.shrink();
                      }

                      final msg = messages[msgIndex];
                      final isLast = msgIndex == messages.length - 1;
                      final showTail = isLast ||
                          (msgIndex < messages.length - 1 &&
                              messages[msgIndex + 1].isMe != msg.isMe);
                      final isStarred = chatProvider.isMessageStarred(msg.id);

                      return GestureDetector(
                        onLongPress: () => _showMessageActions(context, msg),
                        child: _MessageBubble(
                          message: msg,
                          showTail: showTail,
                          isStarred: isStarred,
                        ),
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: ChatizyTheme.marginPage,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: ChatizyTheme.surface,
              border: Border(
                top: BorderSide(
                  color: ChatizyTheme.outlineVariant.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ChatizyTheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: ChatizyTheme.radiusFull,
                    ),
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ChatizyTheme.primary,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward,
                        color: Colors.white, size: 20),
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

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('M/d h:mm a').format(lastSeen);
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTail;
  final bool isStarred;

  const _MessageBubble({
    required this.message,
    required this.showTail,
    this.isStarred = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final timeStr = DateFormat('h:mm a').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? ChatizyTheme.primary : const Color(0xFFE9E9EB),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe || !showTail ? 18 : 4),
                bottomRight: Radius.circular(!isMe || !showTail ? 18 : 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isMe ? Colors.white : ChatizyTheme.onSurface,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isStarred) ...[
                      Icon(
                        Icons.star,
                        size: 12,
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : ChatizyTheme.starYellow,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : ChatizyTheme.outline,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      // Read receipt: grey = sent, blue = read
                      Text(
                        '✓✓',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: message.isRead
                              ? const Color(0xFF53BDEB) // Blue ticks
                              : Colors.white.withValues(alpha: 0.5), // Grey ticks
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EncryptionNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline,
              size: 12,
              color: ChatizyTheme.outline.withValues(alpha: 0.6)),
          const SizedBox(width: 4),
          Text(
            'Messages are end-to-end encrypted',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ChatizyTheme.outline.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
