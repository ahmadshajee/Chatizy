import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import '../widgets/glass_widgets.dart';

/// Displays all messages the user has starred across conversations.
/// Redesigned with transparent scaffold, glass cards, and staggered entrance animations.
class StarredMessagesScreen extends StatefulWidget {
  const StarredMessagesScreen({super.key});

  @override
  State<StarredMessagesScreen> createState() => _StarredMessagesScreenState();
}

class _StarredMessagesScreenState extends State<StarredMessagesScreen> {
  List<Message>? _starredMessages;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStarredMessages();
  }

  Future<void> _loadStarredMessages() async {
    final chatProvider = context.read<ChatProvider>();
    try {
      final messages = await chatProvider.getStarredMessages();
      if (mounted) {
        setState(() {
          _starredMessages = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Starred Messages',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ChatizyTheme.primary))
          : _starredMessages == null || _starredMessages!.isEmpty
               ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ChatizyTheme.starYellow.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: ChatizyTheme.starYellow.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                        child: const Icon(Icons.star_rounded,
                            size: 64,
                            color: ChatizyTheme.starYellow),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        'No Starred Messages',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ).animate().fade(delay: 150.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Long-press any message in a chat to star it',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      ).animate().fade(delay: 250.ms),
                    ],
                  ),
                )
               : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    ChatizyTheme.marginPage,
                    12,
                    ChatizyTheme.marginPage,
                    100,
                  ),
                  itemCount: _starredMessages!.length,
                  itemBuilder: (context, index) {
                    final msg = _starredMessages![index];
                    return _StarredMessageCard(
                      message: msg,
                      index: index,
                    );
                  },
                ),
    );
  }
}

class _StarredMessageCard extends StatelessWidget {
  final Message message;
  final int index;

  const _StarredMessageCard({
    required this.message,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, h:mm a').format(message.createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: ChatizyTheme.starYellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  message.senderName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(0xFF0A84FF).withValues(alpha: 0.12)
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: message.isMe
                      ? const Color(0xFF0A84FF).withValues(alpha: 0.2)
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                  width: 0.8,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fade(delay: (index * 50).ms, duration: 350.ms)
    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}
