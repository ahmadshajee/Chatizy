import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

import 'chats_list_screen.dart';
import 'settings_screen.dart';
import 'admin_dashboard_screen.dart';
import 'super_admin_screen.dart';

/// Home shell with bottom navigation.
/// Dynamically shows/hides nav items based on user role.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.currentRole;

    // Build nav items and screens based on role
    final navItems = <_NavItem>[];
    final screens = <Widget>[];

    // Chats (Personal, Employee, Business Admin â€” NOT Super Admin)
    if (role != UserRole.superAdmin) {
      navItems.add(const _NavItem(
        icon: Icons.chat_outlined,
        activeIcon: Icons.chat,
        label: 'Chats',
      ));
      screens.add(const ChatsListScreen());
    }

    // Contacts (Personal, Employee, Business Admin â€” NOT Super Admin)
    if (role != UserRole.superAdmin) {
      navItems.add(const _NavItem(
        icon: Icons.contacts_outlined,
        activeIcon: Icons.contacts,
        label: 'Contacts',
      ));
      screens.add(_ContactsPlaceholder(role: role, domain: auth.currentProfile?.companyDomain));
    }

    // Admin Dashboard (Business Admin) or Super Admin Dashboard
    if (role == UserRole.businessAdmin) {
      navItems.add(const _NavItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        label: 'Admin',
      ));
      screens.add(const AdminDashboardScreen());
    } else if (role == UserRole.superAdmin) {
      navItems.add(const _NavItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        label: 'Admin',
      ));
      screens.add(const SuperAdminScreen());
    }

    // Settings (all roles)
    navItems.add(const _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ));
    screens.add(const SettingsScreen());

    // Ensure currentIndex is within range
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ChatizyTheme.surface.withValues(alpha: 0.8),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ChatizyTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'Chatizy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: ChatizyTheme.primary,
                  ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: ChatizyTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: ChatizyTheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: navItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                  ))
              .toList(),
        ),
      ),
      // FAB for new chat or add contact
      floatingActionButton:
          role != UserRole.superAdmin && (_currentIndex == 0 || _currentIndex == 1)
              ? FloatingActionButton(
                  backgroundColor: ChatizyTheme.primary,
                  onPressed: () {
                    if (_currentIndex == 0) {
                      _showNewChatDialog(context);
                    } else {
                      _showAddContactByEmailDialog(context);
                    }
                  },
                  child: Icon(
                    _currentIndex == 0 ? Icons.edit : Icons.person_add,
                    color: Colors.white,
                  ),
                )
              : null,
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final searchCtrl = TextEditingController();
    final chatProvider = context.read<ChatProvider>();
    List<Profile> results = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ChatizyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollCtrl) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ChatizyTheme.outlineVariant,
                  borderRadius: ChatizyTheme.radiusFull,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('New Chat',
                    style: Theme.of(ctx).textTheme.headlineSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: ChatizyTheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: ChatizyTheme.radiusMd,
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (q) async {
                    if (q.length >= 2) {
                      final r = await chatProvider.searchUsers(q);
                      setModalState(() => results = r);
                    } else {
                      setModalState(() => results = []);
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: results.length,
                  itemBuilder: (ctx, i) {
                    final user = results[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            ChatizyTheme.surfaceContainerHighest,
                        child: Text(
                          user.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: ChatizyTheme.onSurfaceVariant),
                        ),
                      ),
                      title: Text(user.displayName),
                      subtitle: Text(
                        user.email ?? user.companyDomain ?? '',
                        style: TextStyle(
                          color: ChatizyTheme.outline,
                          fontSize: 13,
                        ),
                      ),
                      trailing: user.isOnline
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ChatizyTheme.onlineGreen,
                              ),
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        final room = await chatProvider.startDirectChat(
                          user.id,
                          companyDomain: user.companyDomain,
                        );
                        if (room != null && mounted) {
                          await chatProvider.openConversation(room);
                          if (mounted) {
                            Navigator.of(context)
                                .pushNamed('/conversation');
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showAddContactByEmailDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final chatProvider = context.read<ChatProvider>();
    Profile? foundUser;
    bool isSearching = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ChatizyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.outlineVariant,
                    borderRadius: ChatizyTheme.radiusFull,
                  ),
                ),
                // Title with icon
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ChatizyTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: ChatizyTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Contact',
                            style: Theme.of(ctx).textTheme.headlineSmall),
                        Text('Find someone by their email address',
                            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                  color: ChatizyTheme.outline,
                                )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Email input
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter email address',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    filled: true,
                    fillColor: ChatizyTheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: ChatizyTheme.radiusMd,
                      borderSide: BorderSide.none,
                    ),
                    errorText: errorMessage,
                  ),
                  onChanged: (_) {
                    if (errorMessage != null) {
                      setModalState(() => errorMessage = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Search button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: isSearching
                        ? null
                        : () async {
                            final email = emailCtrl.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              setModalState(() =>
                                  errorMessage = 'Please enter a valid email address');
                              return;
                            }
                            setModalState(() {
                              isSearching = true;
                              errorMessage = null;
                              foundUser = null;
                            });
                            try {
                              final result =
                                  await chatProvider.searchByEmail(email);
                              setModalState(() {
                                isSearching = false;
                                foundUser = result;
                                if (result == null) {
                                  errorMessage =
                                      'No user found with this email address';
                                }
                              });
                            } catch (e) {
                              setModalState(() {
                                isSearching = false;
                                errorMessage = e.toString().replaceAll('Exception: ', '');
                              });
                            }
                          },
                    icon: isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(isSearching ? 'Searching...' : 'Find Contact'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ChatizyTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: ChatizyTheme.radiusMd,
                      ),
                    ),
                  ),
                ),
                // Found user card
                if (foundUser != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: ChatizyTheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: ChatizyTheme.radiusMd,
                      border: Border.all(
                        color: ChatizyTheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: ChatizyTheme.primaryContainer,
                        radius: 24,
                        child: Text(
                          foundUser!.fullName
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: ChatizyTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        foundUser!.displayName,
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        foundUser!.email ?? '',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: ChatizyTheme.outline,
                            ),
                      ),
                      trailing: FilledButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final userId = foundUser!.id;
                          final domain = foundUser!.companyDomain;
                          Navigator.pop(ctx);
                          try {
                            final room = await chatProvider.startDirectChat(
                              userId,
                              companyDomain: domain,
                            );
                            if (room != null) {
                              await chatProvider.openConversation(room);
                              navigator.pushNamed('/conversation');
                            } else {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('Failed to create chat. Please try again.')),
                              );
                            }
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: ChatizyTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Chat'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Contacts â€” shows company employees for business users,
/// or a search/contacts interface for personal users.
/// Supports single-tap actions and long-press multi-select.
class _ContactsPlaceholder extends StatefulWidget {
  final UserRole role;
  final String? domain;
  const _ContactsPlaceholder({required this.role, this.domain});

  @override
  State<_ContactsPlaceholder> createState() => _ContactsPlaceholderState();
}

class _ContactsPlaceholderState extends State<_ContactsPlaceholder> {
  // Multi-select state
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};
  List<Profile> _cachedContacts = [];

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  List<Profile> _getSelectedProfiles() {
    return _cachedContacts.where((c) => _selectedIds.contains(c.id)).toList();
  }

  // â”€â”€â”€ Single-tap: Contact Actions Bottom Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showContactActions(BuildContext context, Profile contact) {
    final chatProvider = context.read<ChatProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: ChatizyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ChatizyTheme.outlineVariant,
                  borderRadius: ChatizyTheme.radiusFull,
                ),
              ),
              // Contact header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ChatizyTheme.primaryContainer,
                      radius: 24,
                      child: Text(
                        contact.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.displayName,
                              style: Theme.of(ctx).textTheme.titleLarge),
                          if (contact.email != null)
                            Text(contact.email!,
                                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                      color: ChatizyTheme.outline,
                                    )),
                        ],
                      ),
                    ),
                    if (contact.isOnline)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ChatizyTheme.onlineGreen,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // 1. Chat
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.primary.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.chat_bubble_outline,
                      color: ChatizyTheme.primary, size: 20),
                ),
                title: const Text('Chat'),
                subtitle: Text('Start a conversation',
                    style: TextStyle(color: ChatizyTheme.outline, fontSize: 13)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final room = await chatProvider.startDirectChat(
                    contact.id,
                    companyDomain: contact.companyDomain,
                  );
                  if (room != null && context.mounted) {
                    await chatProvider.openConversation(room);
                    if (context.mounted) {
                      Navigator.of(context).pushNamed('/conversation');
                    }
                  }
                },
              ),

              // 2. Add Nickname
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.starYellow.withValues(alpha: 0.15),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: ChatizyTheme.starYellow, size: 20),
                ),
                title: const Text('Add Nickname'),
                subtitle: Text('Set a custom name for this contact',
                    style: TextStyle(color: ChatizyTheme.outline, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddNicknameDialog(context, contact);
                },
              ),

              // 3. Remove Contact
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.error.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.person_remove_outlined,
                      color: ChatizyTheme.error, size: 20),
                ),
                title: Text('Remove Contact',
                    style: TextStyle(color: ChatizyTheme.error)),
                subtitle: Text('Delete this contact and chat history',
                    style: TextStyle(color: ChatizyTheme.outline, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRemoveContactConfirmation1(context, contact);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ Add Nickname Dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showAddNicknameDialog(BuildContext context, Profile contact) {
    final controller = TextEditingController(text: contact.nickname ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        title: const Text('Add Nickname'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a nickname for ${contact.fullName}',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: ChatizyTheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter nickname',
                filled: true,
                fillColor: ChatizyTheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: ChatizyTheme.radiusMd,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final nickname = controller.text.trim();
              if (nickname.isNotEmpty && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nickname "$nickname" saved for ${contact.fullName}'),
                    backgroundColor: ChatizyTheme.onlineGreen,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: ChatizyTheme.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Remove Contact: Double Confirmation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showRemoveContactConfirmation1(BuildContext context, Profile contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ChatizyTheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_remove, color: ChatizyTheme.error, size: 28),
        ),
        title: const Text('Remove Contact?'),
        content: Text(
          'Are you sure you want to remove ${contact.displayName} from your contacts?\n\nThis will also delete your chat history with them.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRemoveContactConfirmation2(context, contact);
            },
            style: FilledButton.styleFrom(
              backgroundColor: ChatizyTheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showRemoveContactConfirmation2(BuildContext context, Profile contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ChatizyTheme.error.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning_amber_rounded,
              color: ChatizyTheme.error, size: 32),
        ),
        title: const Text('This cannot be undone!'),
        content: Text(
          'You are about to permanently remove ${contact.displayName} and ALL chat messages with them.\n\nAre you absolutely sure?',
          textAlign: TextAlign.center,
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: ChatizyTheme.onSurfaceVariant,
              ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ChatizyTheme.outlineVariant),
            ),
            child: const Text('No, keep contact'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final chatProvider = context.read<ChatProvider>();
              await chatProvider.removeContact(contact.id);
              if (context.mounted) {
                setState(() {}); // Refresh contact list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${contact.displayName} removed'),
                    backgroundColor: ChatizyTheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: ChatizyTheme.error,
            ),
            child: const Text('Yes, remove permanently'),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Multi-select Toolbar Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showMultiSelectActions(BuildContext context) {
    final selected = _getSelectedProfiles();
    if (selected.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: ChatizyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ChatizyTheme.outlineVariant,
                  borderRadius: ChatizyTheme.radiusFull,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '${selected.length} contact${selected.length > 1 ? 's' : ''} selected',
                  style: Theme.of(ctx).textTheme.headlineSmall,
                ),
              ),
              const Divider(height: 8),

              // Delete selected contacts
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.error.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: ChatizyTheme.error, size: 22),
                ),
                title: Text('Delete ${selected.length} Contact${selected.length > 1 ? 's' : ''}',
                    style: TextStyle(color: ChatizyTheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmBulkDelete(context, selected);
                },
              ),

              // Make a group
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.group_add,
                      color: ChatizyTheme.tertiary, size: 22),
                ),
                title: const Text('Make a Group'),
                subtitle: Text(
                  'Create a group chat with selected contacts',
                  style: TextStyle(color: ChatizyTheme.outline, fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateGroupDialog(context, selected);
                },
              ),

              // Broadcast message
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.primary.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.campaign_outlined,
                      color: ChatizyTheme.primary, size: 22),
                ),
                title: const Text('Broadcast Message'),
                subtitle: Text(
                  'Send the same message to all selected',
                  style: TextStyle(color: ChatizyTheme.outline, fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showBroadcastDialog(context, selected, isScheduled: false);
                },
              ),

              // Scheduled broadcast
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.onlineGreen.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.schedule_send,
                      color: ChatizyTheme.onlineGreen, size: 22),
                ),
                title: const Text('Scheduled Broadcast'),
                subtitle: Text(
                  'Send a message at a later time',
                  style: TextStyle(color: ChatizyTheme.outline, fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showBroadcastDialog(context, selected, isScheduled: true);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ Bulk Delete Confirmation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _confirmBulkDelete(BuildContext context, List<Profile> contacts) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ChatizyTheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_forever,
              color: ChatizyTheme.error, size: 28),
        ),
        title: Text('Delete ${contacts.length} Contact${contacts.length > 1 ? 's' : ''}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will permanently remove these contacts and all chat history:',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: ChatizyTheme.outline,
                  ),
            ),
            const SizedBox(height: 12),
            ...contacts.take(5).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 16, color: ChatizyTheme.outline),
                      const SizedBox(width: 6),
                      Text(c.displayName,
                          style: Theme.of(ctx).textTheme.bodyMedium),
                    ],
                  ),
                )),
            if (contacts.length > 5)
              Text('... and ${contacts.length - 5} more',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: ChatizyTheme.outline,
                      )),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final chatProvider = context.read<ChatProvider>();
              await chatProvider.removeContacts(contacts.map((c) => c.id).toList());
              _exitSelectionMode();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${contacts.length} contact${contacts.length > 1 ? 's' : ''} removed'),
                    backgroundColor: ChatizyTheme.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: ChatizyTheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Create Group Dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showCreateGroupDialog(BuildContext context, List<Profile> members) {
    final nameCtrl = TextEditingController();
    final auth = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Group name',
                prefixIcon: const Icon(Icons.group, size: 20),
                filled: true,
                fillColor:
                    ChatizyTheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: ChatizyTheme.radiusMd,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ChatizyTheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: ChatizyTheme.radiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${members.length} member${members.length > 1 ? 's' : ''}',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: ChatizyTheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: members
                        .map((m) => Chip(
                              label: Text(m.displayName,
                                  style: const TextStyle(fontSize: 12)),
                              avatar: CircleAvatar(
                                backgroundColor: ChatizyTheme.primaryContainer,
                                radius: 12,
                                child: Text(
                                  m.fullName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final chatProvider = context.read<ChatProvider>();
              final room = await chatProvider.createGroupChat(
                groupName: name,
                memberIds: members.map((m) => m.id).toList(),
                companyDomain: auth.currentProfile?.companyDomain,
              );
              _exitSelectionMode();
              if (room != null && context.mounted) {
                await chatProvider.openConversation(room);
                if (context.mounted) {
                  Navigator.of(context).pushNamed('/conversation');
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: ChatizyTheme.primary,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Broadcast / Scheduled Broadcast Dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showBroadcastDialog(BuildContext context, List<Profile> recipients,
      {required bool isScheduled}) {
    final msgCtrl = TextEditingController();
    final auth = context.read<AuthProvider>();
    DateTime? scheduledTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: ChatizyTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
          title: Row(
            children: [
              Icon(
                isScheduled ? Icons.schedule_send : Icons.campaign,
                color: isScheduled
                    ? ChatizyTheme.onlineGreen
                    : ChatizyTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(isScheduled ? 'Scheduled Broadcast' : 'Broadcast Message'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recipients preview
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ChatizyTheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, size: 18, color: ChatizyTheme.outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'To: ${recipients.map((r) => r.displayName).join(", ")}',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                color: ChatizyTheme.outline,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Message input
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Type your broadcast message...',
                    filled: true,
                    fillColor: ChatizyTheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: ChatizyTheme.radiusMd,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // Schedule picker for scheduled broadcasts
                if (isScheduled) ...[
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now().add(const Duration(hours: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && ctx.mounted) {
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() {
                            scheduledTime = DateTime(
                              date.year, date.month, date.day,
                              time.hour, time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ChatizyTheme.onlineGreen.withValues(alpha: 0.08),
                        borderRadius: ChatizyTheme.radiusMd,
                        border: Border.all(
                          color: ChatizyTheme.onlineGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event,
                              color: ChatizyTheme.onlineGreen, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            scheduledTime != null
                                ? '${scheduledTime!.day}/${scheduledTime!.month}/${scheduledTime!.year} at ${scheduledTime!.hour}:${scheduledTime!.minute.toString().padLeft(2, '0')}'
                                : 'Pick date & time',
                            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                  color: ChatizyTheme.onlineGreen,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final msg = msgCtrl.text.trim();
                if (msg.isEmpty) return;
                if (isScheduled && scheduledTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a date and time')),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final chatProvider = context.read<ChatProvider>();

                if (isScheduled) {
                  _exitSelectionMode();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Broadcast scheduled for ${scheduledTime!.day}/${scheduledTime!.month} at ${scheduledTime!.hour}:${scheduledTime!.minute.toString().padLeft(2, '0')} to ${recipients.length} contacts',
                        ),
                        backgroundColor: ChatizyTheme.onlineGreen,
                      ),
                    );
                  }
                } else {
                  final count = await chatProvider.broadcastMessage(
                    recipientIds: recipients.map((r) => r.id).toList(),
                    content: msg,
                    senderName:
                        auth.currentProfile?.displayName ?? 'Unknown',
                    senderDomain: auth.currentProfile?.companyDomain,
                  );
                  _exitSelectionMode();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Broadcast sent to $count contacts'),
                        backgroundColor: ChatizyTheme.onlineGreen,
                      ),
                    );
                  }
                }
              },
              icon: Icon(isScheduled ? Icons.schedule_send : Icons.send),
              label: Text(isScheduled ? 'Schedule' : 'Send Now'),
              style: FilledButton.styleFrom(
                backgroundColor: isScheduled
                    ? ChatizyTheme.onlineGreen
                    : ChatizyTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row â€” title + selection mode toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(
              ChatizyTheme.marginPage, 8, ChatizyTheme.marginPage, 0),
          child: _isSelectionMode
              ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: ChatizyTheme.onSurface),
                      onPressed: _exitSelectionMode,
                    ),
                    Text(
                      '${_selectedIds.length} selected',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selectedIds.length == _cachedContacts.length) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds.addAll(
                                _cachedContacts.map((c) => c.id));
                          }
                        });
                      },
                      child: Text(
                        _selectedIds.length == _cachedContacts.length
                            ? 'Deselect All'
                            : 'Select All',
                        style: const TextStyle(color: ChatizyTheme.primary),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('Contacts',
                      style: Theme.of(context).textTheme.displayLarge),
                ),
        ),

        // Add New Contact card (only in normal mode for personal users)
        if (!_isSelectionMode && widget.role == UserRole.personal) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ChatizyTheme.marginPage),
            child: InkWell(
              onTap: () => _HomeScreenState._showAddContactByEmailDialog(context),
              borderRadius: ChatizyTheme.radiusMd,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ChatizyTheme.primary.withValues(alpha: 0.15),
                      ChatizyTheme.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: ChatizyTheme.radiusMd,
                  border: Border.all(
                    color: ChatizyTheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ChatizyTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Contact',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: ChatizyTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Find and connect with friends using their email',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ChatizyTheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: ChatizyTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Contact list
        Expanded(
          child: FutureBuilder<List<Profile>>(
            future: widget.domain != null &&
                    (widget.role == UserRole.employee ||
                        widget.role == UserRole.businessAdmin)
                ? chatProvider.getCompanyEmployees(widget.domain!)
                : chatProvider.getPersonalContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: ChatizyTheme.primary),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading contacts',
                      style: TextStyle(color: ChatizyTheme.outline)),
                );
              }
              final contacts = snapshot.data ?? [];
              _cachedContacts = contacts;

              if (contacts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts_outlined,
                          size: 64,
                          color: ChatizyTheme.outlineVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        widget.domain != null
                            ? 'No company contacts yet'
                            : 'Your contact list is empty',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: ChatizyTheme.outline),
                      ),
                      if (widget.role == UserRole.personal) ...[
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            _HomeScreenState._showAddContactByEmailDialog(context);
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Contact by Email'),
                          style: FilledButton.styleFrom(
                            backgroundColor: ChatizyTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: ChatizyTheme.radiusMd,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: contacts.length,
                      itemBuilder: (context, i) {
                        final c = contacts[i];
                        final isSelected = _selectedIds.contains(c.id);

                        return InkWell(
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelection(c.id);
                            } else {
                              _showContactActions(context, c);
                            }
                          },
                          onLongPress: () {
                            if (!_isSelectionMode) {
                              setState(() {
                                _isSelectionMode = true;
                                _selectedIds.add(c.id);
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color: isSelected
                                ? ChatizyTheme.primary.withValues(alpha: 0.08)
                                : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: ChatizyTheme.marginPage,
                                vertical: 10),
                            child: Row(
                              children: [
                                // Selection checkbox or nothing
                                if (_isSelectionMode)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? ChatizyTheme.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? ChatizyTheme.primary
                                              : ChatizyTheme.outlineVariant,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 14)
                                          : null,
                                    ),
                                  ),

                                // Avatar with online dot
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          ChatizyTheme.surfaceContainerHighest,
                                      radius: 22,
                                      child: Text(
                                        c.fullName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: ChatizyTheme.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (c.isOnline)
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
                                const SizedBox(width: 14),

                                // Name & email
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      if (c.email != null)
                                        Text(
                                          c.email!,
                                          style: TextStyle(
                                              color: ChatizyTheme.outline,
                                              fontSize: 13),
                                        )
                                      else if (c.employeeId != null)
                                        Text(c.employeeId!,
                                            style: TextStyle(
                                                color: ChatizyTheme.outline,
                                                fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Multi-select action bar at bottom
                  if (_isSelectionMode && _selectedIds.isNotEmpty)
                    Container(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: MediaQuery.of(context).padding.bottom + 12,
                      ),
                      decoration: BoxDecoration(
                        color: ChatizyTheme.surfaceContainerLowest,
                        border: Border(
                          top: BorderSide(
                            color: ChatizyTheme.outlineVariant
                                .withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _ActionIconButton(
                            icon: Icons.delete_outline,
                            color: ChatizyTheme.error,
                            label: 'Delete',
                            onTap: () => _confirmBulkDelete(
                                context, _getSelectedProfiles()),
                          ),
                          _ActionIconButton(
                            icon: Icons.group_add,
                            color: ChatizyTheme.tertiary,
                            label: 'Group',
                            onTap: () => _showCreateGroupDialog(
                                context, _getSelectedProfiles()),
                          ),
                          _ActionIconButton(
                            icon: Icons.campaign_outlined,
                            color: ChatizyTheme.primary,
                            label: 'Broadcast',
                            onTap: () => _showBroadcastDialog(
                                context, _getSelectedProfiles(),
                                isScheduled: false),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () =>
                                _showMultiSelectActions(context),
                            icon: const Icon(Icons.more_horiz, size: 18),
                            label: const Text('More'),
                            style: FilledButton.styleFrom(
                              backgroundColor: ChatizyTheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Small icon button for the multi-select action bar.
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: ChatizyTheme.radiusMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(fontSize: 10, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
