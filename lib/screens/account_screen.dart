import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

/// Account settings screen with profile picture, status, password change,
/// and email display.
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
          'Account',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ChatizyTheme.marginPage),
        child: Column(
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ChatizyTheme.surfaceContainerHighest,
                          border: Border.all(
                            color: ChatizyTheme.outlineVariant
                                .withValues(alpha: 0.3),
                            width: 2,
                          ),
                          image: profile?.avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(profile!.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profile?.avatarUrl == null
                            ? Center(
                                child: Text(
                                  (profile?.fullName ?? 'U')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        color: ChatizyTheme.onSurfaceVariant,
                                      ),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showAvatarOptions(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ChatizyTheme.primary,
                              border: Border.all(
                                color: ChatizyTheme.surface,
                                width: 3,
                              ),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ChatizyTheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Status
            _AccountSection(
              icon: Icons.info_outline,
              iconColor: ChatizyTheme.helpBlue,
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
              iconColor: ChatizyTheme.primary,
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
              iconColor: ChatizyTheme.tertiary,
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
              iconColor: ChatizyTheme.onlineGreen,
              title: 'Email',
              subtitle: profile?.email ?? '',
              isReadOnly: true,
            ),
            const SizedBox(height: 12),

            // Change Password
            _AccountSection(
              icon: Icons.lock_outline,
              iconColor: ChatizyTheme.starYellow,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () => _showChangePasswordDialog(context),
            ),
            const SizedBox(height: 32),

            // Delete Account
            Container(
              decoration: ChatizyTheme.glassPanelRounded,
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.error.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child:
                      const Icon(Icons.delete_forever, color: ChatizyTheme.error, size: 20),
                ),
                title: Text(
                  'Delete Account',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: ChatizyTheme.error),
                ),
                subtitle: Text(
                  'Permanently delete your account and data',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ChatizyTheme.outline,
                      ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: ChatizyTheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                          borderRadius: ChatizyTheme.radiusXl),
                      title: const Text('Delete Account?'),
                      content: const Text(
                          'This action cannot be undone. All your data will be permanently deleted.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Delete',
                              style: TextStyle(color: ChatizyTheme.error)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ChatizyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ChatizyTheme.outlineVariant,
                  borderRadius: ChatizyTheme.radiusFull,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: ChatizyTheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  // Gallery picker would go here — requires image_picker package
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Photo picker requires image_picker package')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: ChatizyTheme.error),
                title: const Text('Remove Photo'),
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
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Future<void> Function(String value) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape:
            RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: ChatizyTheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: ChatizyTheme.radiusMd,
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await onSave(value);
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

  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: ChatizyTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
              borderRadius: ChatizyTheme.radiusXl),
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  filled: true,
                  fillColor: ChatizyTheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: ChatizyTheme.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: ChatizyTheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: ChatizyTheme.radiusMd,
                    borderSide: BorderSide.none,
                  ),
                  errorText: error,
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
              style: FilledButton.styleFrom(
                backgroundColor: ChatizyTheme.primary,
              ),
              child: Text(_isUpdating ? 'Updating...' : 'Update'),
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
    return Container(
      decoration: ChatizyTheme.glassPanelRounded,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: ChatizyTheme.radiusMd,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ChatizyTheme.outline,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: isReadOnly
            ? null
            : const Icon(Icons.chevron_right,
                color: ChatizyTheme.outlineVariant, size: 20),
        onTap: onTap,
      ),
    );
  }
}
