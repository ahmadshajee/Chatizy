import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_widgets.dart';

/// Settings screen matching the premium Apple Glass UI design.
/// iOS-style grouped list with frosted glass panels, profile card,
/// custom icons, and interactive micro-animations.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          ChatizyTheme.marginPage, 16, ChatizyTheme.marginPage, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
          ).animate().fade(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 16),

          // Profile card — taps into Account screen
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/account'),
            child: GlassCard(
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with glowing gradient border
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A84FF), Color(0xFFBF5AF2), Color(0xFF0DF5E3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
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
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? 'User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRoleLabel(profile?.role),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (profile?.companyDomain != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                              border: Border.all(
                                color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              profile!.companyDomain!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A84FF),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                ],
              ),
            ),
          ).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 20),

          // Starred Messages
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.star,
              iconBg: const Color(0xFFFFCC00), // Apple Gold
              label: 'Starred Messages',
              onTap: () => Navigator.of(context).pushNamed('/starred'),
            ),
          ]).animate().fade(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Account & Privacy
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.key,
              iconBg: const Color(0xFF0A84FF), // Apple Blue
              label: 'Account',
              onTap: () => Navigator.of(context).pushNamed('/account'),
            ),
            _SettingsItem(
              icon: Icons.lock,
              iconBg: const Color(0xFF30D158), // Apple Green
              label: 'Privacy',
              onTap: () => Navigator.of(context).pushNamed('/privacy'),
            ),
          ]).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Chats (backup & restore)
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.chat_bubble,
              iconBg: const Color(0xFF5E5CE6), // Indigo
              label: 'Chats Backup',
              onTap: () => Navigator.of(context).pushNamed('/chat-backup'),
            ),
          ]).animate().fade(delay: 250.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Help
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.help,
              iconBg: const Color(0xFFBF5AF2), // Purple
              label: 'Help & Support',
              onTap: () => Navigator.of(context).pushNamed('/help'),
            ),
          ]).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Sign out
          _SettingsGroup(items: [
            _SettingsItem(
              icon: Icons.logout,
              iconBg: const Color(0xFFFF453A), // Apple Red
              label: 'Sign Out',
              textColor: const Color(0xFFFF453A),
              onTap: () => _confirmSignOut(context),
            ),
          ]).animate().fade(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),

          // Version info
          Center(
            child: Text(
              'Chatizy v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fade(delay: 400.ms, duration: 400.ms),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out from Chatizy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          GlassButton(
            width: 100,
            height: 36,
            borderRadius: BorderRadius.circular(18),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
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
    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
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
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: iconBg.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: iconBg, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (textColor == null)
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}

