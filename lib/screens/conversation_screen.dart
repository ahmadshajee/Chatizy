import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import '../widgets/glass_widgets.dart';

/// Conversation view matching the premium Apple Glass UI design.
/// Frosted app bar, translucent bubble gradients, online indicator glow,
/// and floating pill message input bar.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.85);
    final defaultBorderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1);
    final handleColor = isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2);
    final iconColor = isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF636366);
    final textStyle = TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: defaultBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: defaultBorderColor,
              width: 0.8,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8, top: 8),
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      isStarred ? Icons.star : Icons.star_border,
                      color: isStarred
                          ? const Color(0xFFFFCC00) // Star Yellow
                          : iconColor,
                    ),
                    title: Text(
                      isStarred ? 'Unstar Message' : 'Star Message',
                      style: textStyle,
                    ),
                    onTap: () {
                      chatProvider.toggleStarMessage(message.id);
                      Navigator.pop(ctx);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.copy, color: iconColor),
                    title: Text(
                      'Copy Text',
                      style: textStyle,
                    ),
                    onTap: () {
                      // Perform copy logic here if needed
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDark 
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.6),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        leadingWidth: 90,
        leading: GestureDetector(
          onTap: () {
            chatProvider.closeConversation();
            Navigator.of(context).pop();
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: Color(0xFF0A84FF), size: 20),
              Text(
                'Chats',
                style: TextStyle(
                  color: Color(0xFF0A84FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Centered Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFF0DF5E3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  (partner?.displayName ?? room?.displayName ?? '?')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Centered name with small online indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    partner?.displayName ?? room?.displayName ?? 'Chat',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (partner?.isOnline == true) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF30D158),
                    ),
                  ),
                ],
              ],
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
                    child: CircularProgressIndicator(color: Color(0xFF0A84FF)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length + 1, // +1 for encryption notice
                    itemBuilder: (context, index) {
                      // Encryption notice in the middle
                      if (index == messages.length ~/ 2 && messages.length > 2) {
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
                      ).animate().fade(duration: 250.ms).slideY(begin: 0.05, end: 0);
                    },
                  ),
          ),

          // iMessage style nested input bar with plus button
          Padding(
            padding: EdgeInsets.fromLTRB(
              8,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                // Plus button (outside the message container)
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF8E8E93), size: 28),
                  onPressed: () {
                    // Action sheet or media upload
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.08) 
                          : const Color(0xFFE9E9EB).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.12) 
                            : const Color(0xFFE5E5EA),
                        width: 0.8,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            maxLines: null,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'iMessage',
                              hintStyle: TextStyle(
                                color: isDark 
                                    ? Colors.white.withValues(alpha: 0.35) 
                                    : const Color(0xFF8E8E93),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        // Send button nested inside container
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF007AFF), // iMessage Blue
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isMe
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1C1C1E));

    final timeColor = isMe
        ? Colors.white.withValues(alpha: 0.6)
        : (isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF8E8E93));

    final bubbleBgColor = isMe
        ? null
        : (isDark ? const Color(0xFF262629).withValues(alpha: 0.85) : const Color(0xFFE9E9EB).withValues(alpha: 0.85));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4), // iMessage style tight spacing
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ClipPath(
            clipper: IMessageBubbleClipper(isMe: isMe, showTail: showTail),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: EdgeInsets.fromLTRB(
                isMe ? 14 : (showTail ? 22 : 14),
                10,
                isMe ? (showTail ? 22 : 14) : 14,
                10,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF2997FF), // Bright Blue
                          Color(0xFF007AFF), // Apple Blue
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isMe ? null : bubbleBgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isStarred) ...[
                        const Icon(
                          Icons.star,
                          size: 11,
                          color: Color(0xFFFFCC00),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 9,
                          color: timeColor,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        // Read receipt: grey = sent, blue = read
                        Text(
                          '✓✓',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: message.isRead
                                ? const Color(0xFF30D158) // Bright green check for read
                                : Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final defaultBg = isDark 
        ? Colors.black.withValues(alpha: 0.3) 
        : Colors.white.withValues(alpha: 0.65);
        
    final defaultBorder = isDark 
        ? Colors.white.withValues(alpha: 0.08) 
        : Colors.white.withValues(alpha: 0.45);
        
    final defaultText = isDark 
        ? Colors.white.withValues(alpha: 0.4) 
        : const Color(0xFF8E8E93);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: defaultBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: defaultBorder,
            width: 0.5,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 12,
              color: defaultText,
            ),
            const SizedBox(width: 6),
            Text(
              'Messages are end-to-end encrypted',
              style: TextStyle(
                color: defaultText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Clipper for authentic Apple iMessage bubble shape (with curved bottom corner tail)
class IMessageBubbleClipper extends CustomClipper<Path> {
  final bool isMe;
  final bool showTail;

  IMessageBubbleClipper({required this.isMe, required this.showTail});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double r = 18.0; // corner radius

    if (!showTail) {
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(r),
      ));
      return path;
    }

    if (isMe) {
      // Tail on bottom right. We leave 10px on the right for the tail.
      final double w = size.width - 10;
      final double h = size.height;

      // Start at top-left corner
      path.moveTo(0, r);
      // Top-left arc
      path.arcToPoint(
        const Offset(r, 0),
        radius: const Radius.circular(r),
        clockwise: true,
      );
      // Top-right line
      path.lineTo(w - r, 0);
      // Top-right arc
      path.arcToPoint(
        Offset(w, r),
        radius: const Radius.circular(r),
        clockwise: true,
      );
      // Right line down to where tail starts
      path.lineTo(w, h - r);
      // Curve to the tail tip
      path.quadraticBezierTo(w, h - 8, size.width - 2, h - 2);
      path.quadraticBezierTo(size.width, h, size.width, h);
      // Curve back under the bubble
      path.quadraticBezierTo(w, h, w - 8, h - 1.5);
      path.quadraticBezierTo(w - 12, h, w - 18, h);
      // Bottom-left line
      path.lineTo(r, h);
      // Bottom-left arc
      path.arcToPoint(
        Offset(0, h - r),
        radius: const Radius.circular(r),
        clockwise: true,
      );
      path.close();
    } else {
      // Tail on bottom left. We leave 10px on the left for the tail.
      final double w = size.width;
      final double h = size.height;
      const double tailStartX = 10.0;

      // Start at top-left corner (inside tail offset)
      path.moveTo(tailStartX + r, 0);
      // Line to top-right
      path.lineTo(w - r, 0);
      // Top-right arc
      path.arcToPoint(
        Offset(w, r),
        radius: const Radius.circular(r),
        clockwise: true,
      );
      // Bottom-right line
      path.lineTo(w, h - r);
      // Bottom-right arc
      path.arcToPoint(
        Offset(w - r, h),
        radius: const Radius.circular(r),
        clockwise: true,
      );
      // Bottom line to tail start
      path.lineTo(tailStartX + 18, h);
      // Curve back under the bubble
      path.quadraticBezierTo(tailStartX + 12, h, tailStartX + 8, h - 1.5);
      path.quadraticBezierTo(tailStartX, h, 0, h);
      // Curve to tail tip
      path.quadraticBezierTo(2, h - 2, tailStartX, h - 8);
      // Left line up to top-left
      path.lineTo(tailStartX, r);
      // Top-left arc
      path.arcToPoint(
        const Offset(tailStartX + r, 0),
        radius: const Radius.circular(r),
        clockwise: true,
      );
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant IMessageBubbleClipper oldClipper) {
    return oldClipper.isMe != isMe || oldClipper.showTail != showTail;
  }
}
