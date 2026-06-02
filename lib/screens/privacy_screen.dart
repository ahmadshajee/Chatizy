import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../widgets/glass_widgets.dart';

/// Privacy settings screen with toggles for visibility and read receipts.
/// Redesigned with premium Apple Glass UI, frosted cards, and modular animations.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _lastSeenVisibility = 'Everyone';
  String _profilePhotoVisibility = 'Everyone';
  String _statusVisibility = 'Everyone';
  bool _readReceipts = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Privacy Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ChatizyTheme.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'WHO CAN SEE MY INFO',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            )
            .animate()
            .fade(duration: 300.ms),
            const SizedBox(height: 10),

            // Info Group Card
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  _PrivacyOptionTile(
                    icon: Icons.schedule_rounded,
                    iconColor: const Color(0xFF0A84FF),
                    title: 'Last Seen',
                    value: _lastSeenVisibility,
                    onTap: () => _showVisibilityPicker(
                      context,
                      title: 'Last Seen',
                      currentValue: _lastSeenVisibility,
                      onChanged: (v) => setState(() => _lastSeenVisibility = v),
                    ),
                  ),
                  const Divider(height: 1, indent: 64, endIndent: 20),
                  _PrivacyOptionTile(
                    icon: Icons.photo_camera_rounded,
                    iconColor: const Color(0xFF30D158),
                    title: 'Profile Photo',
                    value: _profilePhotoVisibility,
                    onTap: () => _showVisibilityPicker(
                      context,
                      title: 'Profile Photo',
                      currentValue: _profilePhotoVisibility,
                      onChanged: (v) => setState(() => _profilePhotoVisibility = v),
                    ),
                  ),
                  const Divider(height: 1, indent: 64, endIndent: 20),
                  _PrivacyOptionTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF0DF5E3),
                    title: 'Status',
                    value: _statusVisibility,
                    onTap: () => _showVisibilityPicker(
                      context,
                      title: 'Status',
                      currentValue: _statusVisibility,
                      onChanged: (v) => setState(() => _statusVisibility = v),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fade(delay: 100.ms, duration: 400.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 32),

            Text(
              'MESSAGING',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            )
            .animate()
            .fade(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 10),

            // Read Receipts Switch Card
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              borderRadius: BorderRadius.circular(24),
              child: SwitchListTile(
                value: _readReceipts,
                onChanged: (v) => setState(() => _readReceipts = v),
                activeColor: const Color(0xFF30D158),
                activeTrackColor: const Color(0xFF30D158).withValues(alpha: 0.3),
                inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                secondary: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.done_all_rounded,
                        color: Color(0xFF0A84FF), size: 20),
                  ),
                ),
                title: Text(
                  'Read Receipts',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  'Show blue ticks when messages are read',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                ),
              ),
            )
            .animate()
            .fade(delay: 250.ms, duration: 400.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 24),

            // Info note
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF0DF5E3), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If you turn off read receipts, you won\'t be able to see read receipts from other users either.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fade(delay: 350.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  void _showVisibilityPicker(
    BuildContext context, {
    required String title,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) {
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
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1),
                width: 0.8,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                    const SizedBox(height: 8),
                    for (final option in ['Everyone', 'My Contacts', 'Nobody'])
                      RadioListTile<String>(
                        value: option,
                        groupValue: currentValue,
                        activeColor: const Color(0xFF0A84FF),
                        title: Text(
                          option,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                        ),
                        onChanged: (v) {
                          if (v != null) {
                            onChanged(v);
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PrivacyOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 20),
      onTap: onTap,
    );
  }
}
