import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';

/// Displays all messages the user has starred across conversations.
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
      backgroundColor: ChatizyTheme.surface,
      appBar: AppBar(
        backgroundColor: ChatizyTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: ChatizyTheme.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Starred Messages',
          style: Theme.of(context).textTheme.headlineSmall,
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
                      Icon(Icons.star_border,
                          size: 64,
                          color: ChatizyTheme.starYellow.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'No starred messages',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: ChatizyTheme.outline),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Long-press a message to star it',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: ChatizyTheme.outline),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(ChatizyTheme.marginPage),
                  itemCount: _starredMessages!.length,
                  itemBuilder: (context, index) {
                    final msg = _starredMessages![index];
                    return _StarredMessageCard(message: msg);
                  },
                ),
    );
  }
}

class _StarredMessageCard extends StatelessWidget {
  final Message message;

  const _StarredMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, h:mm a').format(message.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ChatizyTheme.glassPanelRounded,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: ChatizyTheme.starYellow, size: 18),
              const SizedBox(width: 8),
              Text(
                message.senderName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                timeStr,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ChatizyTheme.outline,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isMe
                  ? ChatizyTheme.primary.withValues(alpha: 0.08)
                  : ChatizyTheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: ChatizyTheme.radiusMd,
            ),
            child: Text(
              message.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
