import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

/// Settings screen matching the Chatizy design mockup.
/// iOS-style grouped list with glassmorphism panels, profile card,
/// and role indicator.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          ChatizyTheme.marginPage, 8, ChatizyTheme.marginPage, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card — taps into Account screen
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/account'),
            child: Container(
              decoration: ChatizyTheme.glassPanelRounded,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ChatizyTheme.surfaceContainerHighest,
                      border: Border.all(
                        color: ChatizyTheme.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      image: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(profile.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty
                        ? Center(
                            child: Text(
                              (profile?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                              style:
                                  Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        color: ChatizyTheme.onSurfaceVariant,
                                      ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? 'User',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getRoleLabel(profile?.role),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ChatizyTheme.onSurfaceVariant,
                                  ),
                        ),
                        if (profile?.companyDomain != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile!.companyDomain!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: ChatizyTheme.primary,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: ChatizyTheme.outlineVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: ChatizyTheme.stackLg),

          // Starred Messages
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.star,
              iconBg: ChatizyTheme.starYellow,
              label: 'Starred Messages',
              onTap: () => Navigator.of(context).pushNamed('/starred'),
            ),
          ]),
          const SizedBox(height: ChatizyTheme.stackLg),

          // Account & Privacy
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.key,
              iconBg: ChatizyTheme.primary,
              label: 'Account',
              onTap: () => Navigator.of(context).pushNamed('/account'),
            ),
            _SettingsItem(
              icon: Icons.lock,
              iconBg: ChatizyTheme.onlineGreen,
              label: 'Privacy',
              onTap: () => Navigator.of(context).pushNamed('/privacy'),
            ),
          ]),
          const SizedBox(height: ChatizyTheme.stackLg),

          // Chats (backup & restore)
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.chat_bubble,
              iconBg: ChatizyTheme.privacyGreen,
              label: 'Chats',
              onTap: () => Navigator.of(context).pushNamed('/chat-backup'),
            ),
          ]),
          const SizedBox(height: ChatizyTheme.stackLg),

          // Help
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.help,
              iconBg: ChatizyTheme.helpBlue,
              label: 'Help',
              onTap: () => Navigator.of(context).pushNamed('/help'),
            ),
          ]),
          const SizedBox(height: ChatizyTheme.stackLg),

          // Sign out
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.logout,
              iconBg: ChatizyTheme.error,
              label: 'Sign Out',
              textColor: ChatizyTheme.error,
              onTap: () => _confirmSignOut(context),
            ),
          ]),
          const SizedBox(height: 32),

          // Version info
          Center(
            child: Text(
              'Chatizy v1.0.0',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ChatizyTheme.outline,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(dynamic role) {
    if (role == null) return 'Available';
    switch (role.toString()) {
      case 'UserRole.superAdmin':
        return 'Super Admin';
      case 'UserRole.businessAdmin':
        return 'Business Admin';
      case 'UserRole.employee':
        return 'Employee';
      default:
        return 'Personal';
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Sign Out',
                style: TextStyle(color: ChatizyTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ChatizyTheme.glassPanelRounded,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: ChatizyTheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final Color? textColor;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.label,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: ChatizyTheme.radiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: ChatizyTheme.radiusMd,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
              ),
            ),
            if (textColor == null)
              const Icon(Icons.chevron_right,
                  color: ChatizyTheme.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
