import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../widgets/glass_widgets.dart';

/// Account settings screen with profile picture, status, password change,
/// and email display redesign using the Apple Glass UI aesthetic.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _authService = AuthService();
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.currentProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0A84FF), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Account',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: ChatizyTheme.marginPage, vertical: 24),
        child: Column(
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Avatar Container with prominent glowing gradient ring
                      Container(
                        width: 106,
                        height: 106,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A84FF), Color(0xFFBF5AF2), Color(0xFF0DF5E3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
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
                                    (profile?.fullName ?? 'U')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF0A84FF),
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showAvatarOptions(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF007AFF), Color(0xFFBF5AF2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: const Color(0xFF070B19),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 32),

            // Profile info groups
            Column(
              children: [
                // Status
                _AccountSection(
                  icon: Icons.info_outline,
                  iconColor: const Color(0xFF0A84FF),
                  title: 'Status',
                  subtitle: profile?.statusText ?? 'Hey there! I\'m using Chatizy',
                  onTap: () => _showEditDialog(
                    context,
                    title: 'Update Status',
                    initialValue:
                        profile?.statusText ?? 'Hey there! I\'m using Chatizy',
                    onSave: (value) async {
                      await _authService.updateProfile(statusText: value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status updated')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Full Name
                _AccountSection(
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFFBF5AF2),
                  title: 'Name',
                  subtitle: profile?.fullName ?? 'Unknown',
                  onTap: () => _showEditDialog(
                    context,
                    title: 'Update Name',
                    initialValue: profile?.fullName ?? '',
                    onSave: (value) async {
                      await _authService.updateProfile(fullName: value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Name updated')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Nickname
                _AccountSection(
                  icon: Icons.alternate_email,
                  iconColor: const Color(0xFF0DF5E3),
                  title: 'Nickname',
                  subtitle: profile?.nickname ?? 'Not set',
                  onTap: () => _showEditDialog(
                    context,
                    title: 'Update Nickname',
                    initialValue: profile?.nickname ?? '',
                    onSave: (value) async {
                      await _authService.updateProfile(nickname: value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nickname updated')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Email (read-only)
                _AccountSection(
                  icon: Icons.email_outlined,
                  iconColor: const Color(0xFF30D158),
                  title: 'Email',
                  subtitle: profile?.email ?? '',
                  isReadOnly: true,
                ),
                const SizedBox(height: 12),

                // Change Password
                _AccountSection(
                  icon: Icons.lock_outline,
                  iconColor: const Color(0xFFFFCC00),
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ],
            ).animate().fade(delay: 150.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 12),

            // ── Theme Mode Section ──
            _ThemeModeSection()
                .animate()
                .fade(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 24),

            // Delete Account
            GlassCard(
              borderRadius: BorderRadius.circular(20),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.6),
              border: Border.all(
                color: const Color(0xFFFF453A).withValues(alpha: 0.15),
                width: 0.8,
              ),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(Icons.delete_forever, color: Color(0xFFFF453A), size: 20),
                ),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Color(0xFFFF453A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Permanently delete your account and data',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => GlassAlertDialog(
                      title: const Text('Delete Account?'),
                      content: const Text(
                          'This action cannot be undone. All your chat history and account data will be permanently deleted.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93)),
                          ),
                        ),
                        GlassButton(
                          width: 100,
                          height: 36,
                          borderRadius: BorderRadius.circular(18),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ).animate().fade(delay: 250.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => BackdropFilter(
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8, top: 8),
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library, color: Color(0xFF0A84FF)),
                    title: Text('Choose from Gallery', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Photo picker requires image_picker package')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Color(0xFFFF453A)),
                    title: Text('Remove Photo', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _authService.updateProfile(avatarUrl: '');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo removed')),
                        );
                      }
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

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Future<void> Function(String value) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;
 
    showDialog(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: GlassTextField(
            controller: controller,
            hintText: 'Enter value...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93)),
            ),
          ),
          GlassButton(
            width: 100,
            height: 36,
            borderRadius: BorderRadius.circular(18),
            onPressed: () async {
              Navigator.pop(ctx);
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await onSave(value);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    String? error;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => GlassAlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              GlassTextField(
                controller: newPasswordCtrl,
                obscureText: true,
                hintText: 'New Password',
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: confirmPasswordCtrl,
                obscureText: true,
                hintText: 'Confirm Password',
                errorText: error,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF8E8E93)),
              ),
            ),
            GlassButton(
              width: 100,
              height: 36,
              borderRadius: BorderRadius.circular(18),
              onPressed: _isUpdating
                  ? null
                  : () async {
                      if (newPasswordCtrl.text.length < 6) {
                        setDialogState(() =>
                            error = 'Password must be at least 6 characters');
                        return;
                      }
                      if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
                        setDialogState(() => error = 'Passwords do not match');
                        return;
                      }
                      setState(() => _isUpdating = true);
                      try {
                        await _authService
                            .updatePassword(newPasswordCtrl.text);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password updated successfully')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => error =
                            e.toString().replaceAll('Exception: ', ''));
                      }
                      setState(() => _isUpdating = false);
                    },
              child: Text(
                _isUpdating ? 'Updating...' : 'Update',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isReadOnly;

  const _AccountSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.45),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: isReadOnly
            ? null
            : Icon(Icons.chevron_right, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3), size: 20),
        onTap: onTap,
      ),
    );
  }
}

/// A premium theme-mode picker with a segmented-control appearance.
class _ThemeModeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors adapt depending on current brightness
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFD1D1D6).withValues(alpha: 0.5);
    final labelColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : const Color(0xFF636366);
    final titleColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      backgroundColor: cardBg,
      border: Border.all(color: borderColor, width: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F0A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF9F0A).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(Icons.brightness_6_rounded,
                      color: Color(0xFFFF9F0A), size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _modeLabel(themeProv.themeMode),
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Segmented control
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFD1D1D6).withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  _SegmentButton(
                    icon: Icons.light_mode_rounded,
                    label: 'Light',
                    isSelected: themeProv.themeMode == ThemeMode.light,
                    onTap: () => themeProv.setThemeMode(ThemeMode.light),
                  ),
                  _SegmentButton(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark',
                    isSelected: themeProv.themeMode == ThemeMode.dark,
                    onTap: () => themeProv.setThemeMode(ThemeMode.dark),
                  ),
                  _SegmentButton(
                    icon: Icons.phone_android_rounded,
                    label: 'System',
                    isSelected: themeProv.themeMode == ThemeMode.system,
                    onTap: () => themeProv.setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _modeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}

/// A single pill/button inside the segmented control.
class _SegmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white;
    final selectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : const Color(0xFFD1D1D6).withValues(alpha: 0.4);
    final selectedTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final unselectedTextColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF8E8E93);
    final accentColor = const Color(0xFF0A84FF);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: isSelected
                ? Border.all(color: selectedBorder, width: 0.8)
                : null,
            boxShadow: isSelected && isDark
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? accentColor : unselectedTextColor,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
