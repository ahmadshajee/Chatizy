import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import '../models/chat_room.dart';

/// Chats list screen matching the Chatizy design mockup.
/// Shows all conversations with avatars, last message preview,
/// timestamps, unread badges, and online indicators.
class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final rooms = chatProvider.rooms.where((r) {
      if (_searchQuery.isEmpty) return true;
      return (r.displayName ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Header with title and search
        Padding(
          padding: const EdgeInsets.fromLTRB(
              ChatizyTheme.marginPage, 8, ChatizyTheme.marginPage, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chats',
                      style: Theme.of(context).textTheme.displayLarge),
                  TextButton(
                    onPressed: () {},
                    child: Text('Edit',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: ChatizyTheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: ChatizyTheme.outline),
                  filled: true,
                  fillColor: ChatizyTheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: ChatizyTheme.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ChatizyTheme.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Chat list
        Expanded(
          child: chatProvider.isLoading && rooms.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: ChatizyTheme.primary))
              : rooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64,
                              color: ChatizyTheme.outlineVariant
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: ChatizyTheme.outline),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a new chat to begin messaging',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: ChatizyTheme.outline),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: ChatizyTheme.primary,
                      onRefresh: () => chatProvider.loadRooms(),
                      child: ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return _ChatListTile(
                            room: room,
                            onTap: () async {
                              await chatProvider.openConversation(room);
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushNamed('/conversation');
                              }
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const _ChatListTile({required this.room, required this.onTap});

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return DateFormat('h:mm a').format(dt);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE').format(dt);
    } else {
      return DateFormat('M/d/yy').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = room.unreadCount > 0;
    final timeStr = _formatTime(room.lastMessageTime);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: ChatizyTheme.marginPage, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: room.isGroup
                    ? ChatizyTheme.tertiaryContainer
                    : ChatizyTheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  (room.displayName ?? '?').substring(0, 1).toUpperCase(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: room.isGroup
                            ? ChatizyTheme.onTertiaryContainer
                            : ChatizyTheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ChatizyTheme.outlineVariant.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.displayName ?? 'Chat',
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeStr,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: hasUnread
                                        ? ChatizyTheme.primary
                                        : ChatizyTheme.outline,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.lastMessage ?? 'No messages yet',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: ChatizyTheme.outline,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ChatizyTheme.primary,
                            ),
                            child: Center(
                              child: Text(
                                room.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
      ),
    );
  }
}
