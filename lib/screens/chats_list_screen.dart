import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import '../models/chat_room.dart';
import '../widgets/glass_widgets.dart';

/// Chats list screen matching the premium Apple Glass UI design.
/// Shows all conversations with frosted floating cards, custom gradient avatars,
/// timestamps, glowing unread badges, and entrance animations.
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Column(
      children: [
        // Header with title and search
        Padding(
          padding: const EdgeInsets.fromLTRB(
              ChatizyTheme.marginPage, 16, ChatizyTheme.marginPage, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chats',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -1.0,
                        ),
                  ).animate().fade(duration: 400.ms).slideX(begin: -0.1, end: 0),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Edit',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF0A84FF),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ).animate().fade(duration: 400.ms),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar with GlassTextField
              GlassTextField(
                controller: _searchController,
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search, size: 20),
                onChanged: (v) => setState(() => _searchQuery = v),
              ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),

        Expanded(
          child: chatProvider.isLoading && rooms.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0A84FF)),
                )
              : rooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a new chat to begin messaging',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ).animate().fade(duration: 400.ms),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: RefreshIndicator(
                          color: const Color(0xFF0A84FF),
                          backgroundColor: isDark ? const Color(0xFF070B19) : Colors.white.withValues(alpha: 0.9),
                          onRefresh: () => chatProvider.loadRooms(),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: rooms.length,
                            separatorBuilder: (context, index) => Divider(
                              indent: 82, // skip unread dot and avatar
                              endIndent: 16,
                              color: isDark 
                                  ? Colors.white.withValues(alpha: 0.08) 
                                  : const Color(0xFFE5E5EA).withValues(alpha: 0.6),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return _ChatListTile(
                                room: room,
                                index: index,
                                onTap: () async {
                                  await chatProvider.openConversation(room);
                                  if (context.mounted) {
                                    Navigator.of(context).pushNamed('/conversation');
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatRoom room;
  final int index;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.room,
    required this.index,
    required this.onTap,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Unread blue dot on the far left (iMessage style)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasUnread ? const Color(0xFF007AFF) : Colors.transparent,
                ),
              ),
              // Avatar with premium gradient background
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: room.isGroup
                        ? [
                            const Color(0xFFBF5AF2), // Neon Purple
                            const Color(0xFF5E5CE6), // Deep Indigo
                          ]
                        : [
                            const Color(0xFF0A84FF), // Vibrant Blue
                            const Color(0xFF0DF5E3), // Teal Glow
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (room.isGroup
                              ? const Color(0xFFBF5AF2)
                              : const Color(0xFF0A84FF))
                          .withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (room.displayName ?? '?').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.displayName ?? 'Chat',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? const Color(0xFF007AFF)
                                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.lastMessage ?? 'No messages yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: hasUnread
                            ? (isDark ? Colors.white : const Color(0xFF1C1C1E)).withValues(alpha: 0.9)
                            : (isDark ? Colors.white : const Color(0xFF8E8E93)).withValues(alpha: 0.6),
                        fontWeight:
                            hasUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: (index * 40).ms, duration: 350.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

