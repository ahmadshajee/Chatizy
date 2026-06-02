import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/profile.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/glass_widgets.dart';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarTitleColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: null,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: GlassBottomNavBar(
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
      // FAB for new chat or add contact
      floatingActionButton:
          role != UserRole.superAdmin && (_currentIndex == 0 || _currentIndex == 1)
              ? Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFFBF5AF2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: RawMaterialButton(
                    shape: const CircleBorder(),
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
                  ),
                )
              : null,
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final searchCtrl = TextEditingController();
    final chatProvider = context.read<ChatProvider>();
    List<Profile> results = [];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (ctx, scrollCtrl) => Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'New Chat',
                      style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassTextField(
                      controller: searchCtrl,
                      hintText: 'Search by name or email...',
                      prefixIcon: const Icon(Icons.search, size: 20),
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
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      itemCount: results.length,
                      itemBuilder: (ctx, i) {
                        final user = results[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                            child: Text(
                              user.fullName.substring(0, 1).toUpperCase(),
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                            ),
                          ),
                          title: Text(
                            user.displayName,
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            user.email ?? user.companyDomain ?? '',
                            style: TextStyle(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
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
                            final navigator = Navigator.of(context);
                            Navigator.pop(ctx);
                            final room = await chatProvider.startDirectChat(
                              user.id,
                              companyDomain: user.companyDomain,
                            );
                            if (room != null) {
                              await chatProvider.openConversation(room);
                              navigator.pushNamed('/conversation');
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Contact',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                  ),
                                ),
                                Text(
                                  'Find someone by their email address',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GlassTextField(
                        controller: emailCtrl,
                        hintText: 'Enter email address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        errorText: errorMessage,
                        onChanged: (_) {
                          if (errorMessage != null) {
                            setModalState(() => errorMessage = null);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      GlassButton(
                        isGlowing: true,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSearching)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(Icons.search, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              isSearching ? 'Searching...' : 'Find Contact',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (foundUser != null) ...[
                        const SizedBox(height: 20),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF0A84FF).withValues(alpha: 0.2),
                                radius: 24,
                                child: Text(
                                  foundUser!.fullName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF0A84FF),
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
                                    Text(
                                      foundUser!.displayName,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      foundUser!.email ?? '',
                                      style: TextStyle(
                                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GlassButton(
                                width: 80,
                                height: 38,
                                isGlowing: true,
                                borderRadius: BorderRadius.circular(12),
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
                                child: const Text(
                                  'Chat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Contact header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF0A84FF).withValues(alpha: 0.2),
                            radius: 24,
                            child: Text(
                              contact.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF0A84FF),
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
                                Text(
                                  contact.displayName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                  ),
                                ),
                                if (contact.email != null)
                                  Text(
                                    contact.email!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                                    ),
                                  ),
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
                    Divider(height: 16, color: isDark ? Colors.white10 : Colors.black12),

                    // 1. Chat
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chat_bubble_outline,
                            color: Color(0xFF0A84FF), size: 20),
                      ),
                      title: Text('Chat', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontWeight: FontWeight.w600)),
                      subtitle: Text('Start a conversation',
                          style: TextStyle(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5), fontSize: 12)),
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        Navigator.pop(ctx);
                        final room = await chatProvider.startDirectChat(
                          contact.id,
                          companyDomain: contact.companyDomain,
                        );
                        if (room != null) {
                          await chatProvider.openConversation(room);
                          navigator.pushNamed('/conversation');
                        }
                      },
                    ),

                    // 2. Add Nickname
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD60A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: Color(0xFFFFD60A), size: 20),
                      ),
                      title: Text('Add Nickname', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontWeight: FontWeight.w600)),
                      subtitle: Text('Set a custom name for this contact',
                          style: TextStyle(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5), fontSize: 12)),
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
                          color: const Color(0xFFFF453A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_remove_outlined,
                            color: Color(0xFFFF453A), size: 20),
                      ),
                      title: const Text('Remove Contact',
                          style: TextStyle(color: Color(0xFFFF453A), fontWeight: FontWeight.w600)),
                      subtitle: Text('Delete this contact and chat history',
                          style: TextStyle(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5), fontSize: 12)),
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
          ),
        ),
      ),
    );
  }

  void _showAddNicknameDialog(BuildContext context, Profile contact) {
    final controller = TextEditingController(text: contact.nickname ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: const Text('Add Nickname'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a nickname for ${contact.fullName}',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: controller,
              hintText: 'Enter nickname',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93))),
          ),
          const SizedBox(width: 8),
          GlassButton(
            width: 100,
            height: 38,
            isGlowing: true,
            borderRadius: BorderRadius.circular(12),
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
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Remove Contact: Double Confirmation ────────────────────────────

  void _showRemoveContactConfirmation1(BuildContext context, Profile contact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFF453A).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_remove, color: Color(0xFFFF453A), size: 28),
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
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93))),
          ),
          const SizedBox(width: 8),
          GlassButton(
            width: 110,
            height: 38,
            borderRadius: BorderRadius.circular(12),
            onPressed: () {
              Navigator.pop(ctx);
              _showRemoveContactConfirmation2(context, contact);
            },
            child: const Text('Remove', style: TextStyle(color: Color(0xFFFF453A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRemoveContactConfirmation2(BuildContext context, Profile contact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFF453A).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFF453A), size: 32),
        ),
        title: const Text('This cannot be undone!'),
        content: Text(
          'You are about to permanently remove ${contact.displayName} and ALL chat messages with them.\n\nAre you absolutely sure?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No, keep', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93))),
          ),
          const SizedBox(width: 8),
          GlassButton(
            width: 190,
            height: 38,
            borderRadius: BorderRadius.circular(12),
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
            child: const Text('Yes, remove permanently', style: TextStyle(color: Color(0xFFFF453A), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Multi-select Toolbar Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showMultiSelectActions(BuildContext context) {
    final selected = _getSelectedProfiles();
    if (selected.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${selected.length} contact${selected.length > 1 ? 's' : ''} selected',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    Divider(height: 8, color: isDark ? Colors.white10 : Colors.black12),

                    // Delete selected contacts
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF453A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Color(0xFFFF453A), size: 22),
                      ),
                      title: Text('Delete ${selected.length} Contact${selected.length > 1 ? 's' : ''}',
                          style: const TextStyle(color: Color(0xFFFF453A), fontWeight: FontWeight.w600)),
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
                          color: const Color(0xFFBF5AF2).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.group_add,
                            color: Color(0xFFBF5AF2), size: 22),
                      ),
                      title: Text('Make a Group', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Create a group chat with selected contacts',
                        style: TextStyle(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5), fontSize: 12),
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
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.campaign_outlined,
                            color: Color(0xFF0A84FF), size: 22),
                      ),
                      title: Text('Broadcast Message', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Send the same message to all selected',
                        style: TextStyle(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5), fontSize: 12),
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
                          color: const Color(0xFF30D158).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.schedule_send,
                            color: Color(0xFF30D158), size: 22),
                      ),
                      title: Text('Scheduled Broadcast', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Send a message at a later time',
                        style: TextStyle(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5), fontSize: 12),
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
          ),
        ),
      ),
    );
  }

  // ─── Bulk Delete Confirmation ───────────────────────────────────────

  void _confirmBulkDelete(BuildContext context, List<Profile> contacts) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFF453A).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_forever,
              color: Color(0xFFFF453A), size: 28),
        ),
        title: Text('Delete ${contacts.length} Contact${contacts.length > 1 ? 's' : ''}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will permanently remove these contacts and all chat history:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ...contacts.take(5).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 16, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5)),
                      const SizedBox(width: 6),
                      Text(c.displayName,
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontSize: 14)),
                    ],
                  ),
                )),
            if (contacts.length > 5)
              Text('... and ${contacts.length - 5} more',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                    fontSize: 12,
                  )),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93))),
          ),
          const SizedBox(width: 8),
          GlassButton(
            width: 120,
            height: 38,
            borderRadius: BorderRadius.circular(12),
            onPressed: () async {
              Navigator.pop(ctx);
              final chatProvider = context.read<ChatProvider>();
              await chatProvider.removeContacts(contacts.map((c) => c.id).toList());
              _exitSelectionMode();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${contacts.length} contacts removed'),
                    backgroundColor: ChatizyTheme.error,
                  ),
                );
              }
            },
            child: const Text('Delete All', style: TextStyle(color: Color(0xFFFF453A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, List<Profile> members) {
    final nameCtrl = TextEditingController();
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassTextField(
              controller: nameCtrl,
              hintText: 'Group name',
              prefixIcon: const Icon(Icons.group, size: 20),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${members.length} member${members.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: members
                      .map((m) => Chip(
                            backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                            side: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)),
                            label: Text(m.displayName,
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
                            avatar: CircleAvatar(
                              backgroundColor: const Color(0xFF0A84FF).withValues(alpha: 0.2),
                              radius: 12,
                              child: Text(
                                m.fullName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF0A84FF), fontWeight: FontWeight.bold),
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
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93))),
          ),
          const SizedBox(width: 8),
          GlassButton(
            width: 100,
            height: 38,
            isGlowing: true,
            borderRadius: BorderRadius.circular(12),
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
            child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Broadcast / Scheduled Broadcast Dialog ──────────────────────────

  void _showBroadcastDialog(BuildContext context, List<Profile> recipients,
      {required bool isScheduled}) {
    final msgCtrl = TextEditingController();
    final auth = context.read<AuthProvider>();
    DateTime? scheduledTime;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => GlassAlertDialog(
          title: Row(
            children: [
              Icon(
                isScheduled ? Icons.schedule_send : Icons.campaign,
                color: isScheduled
                    ? const Color(0xFF30D158)
                    : const Color(0xFF0A84FF),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isScheduled ? 'Scheduled Broadcast' : 'Broadcast Message',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recipients preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 18, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'To: ${recipients.map((r) => r.displayName).join(", ")}',
                          style: TextStyle(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                            fontSize: 12,
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
                Container(
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: msgCtrl,
                    maxLines: 4,
                    minLines: 2,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Type your broadcast message...',
                      hintStyle: TextStyle(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                        color: const Color(0xFF30D158).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF30D158).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event,
                              color: Color(0xFF30D158), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            scheduledTime != null
                                ? '${scheduledTime!.day}/${scheduledTime!.month}/${scheduledTime!.year} at ${scheduledTime!.hour}:${scheduledTime!.minute.toString().padLeft(2, '0')}'
                                : 'Pick date & time',
                            style: const TextStyle(
                              color: Color(0xFF30D158),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93))),
            ),
            const SizedBox(width: 8),
            GlassButton(
              width: 130,
              height: 38,
              isGlowing: true,
              borderRadius: BorderRadius.circular(12),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isScheduled ? Icons.schedule_send : Icons.send, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    isScheduled ? 'Schedule' : 'Send Now',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
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
