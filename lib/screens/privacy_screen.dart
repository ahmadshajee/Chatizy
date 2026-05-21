import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Privacy settings screen with toggles for visibility and read receipts.
/// Settings are stored locally for MVP.
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
          'Privacy',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ChatizyTheme.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who can see my info',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ChatizyTheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // Last Seen
            _PrivacyOption(
              icon: Icons.schedule,
              iconColor: ChatizyTheme.primary,
              title: 'Last Seen',
              value: _lastSeenVisibility,
              onTap: () => _showVisibilityPicker(
                context,
                title: 'Last Seen',
                currentValue: _lastSeenVisibility,
                onChanged: (v) => setState(() => _lastSeenVisibility = v),
              ),
            ),
            const SizedBox(height: 12),

            // Profile Photo
            _PrivacyOption(
              icon: Icons.photo_camera,
              iconColor: ChatizyTheme.onlineGreen,
              title: 'Profile Photo',
              value: _profilePhotoVisibility,
              onTap: () => _showVisibilityPicker(
                context,
                title: 'Profile Photo',
                currentValue: _profilePhotoVisibility,
                onChanged: (v) => setState(() => _profilePhotoVisibility = v),
              ),
            ),
            const SizedBox(height: 12),

            // Status
            _PrivacyOption(
              icon: Icons.info_outline,
              iconColor: ChatizyTheme.helpBlue,
              title: 'Status',
              value: _statusVisibility,
              onTap: () => _showVisibilityPicker(
                context,
                title: 'Status',
                currentValue: _statusVisibility,
                onChanged: (v) => setState(() => _statusVisibility = v),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Messaging',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ChatizyTheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // Read Receipts
            Container(
              decoration: ChatizyTheme.glassPanelRounded,
              child: SwitchListTile(
                value: _readReceipts,
                onChanged: (v) => setState(() => _readReceipts = v),
                activeColor: ChatizyTheme.primary,
                secondary: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.primary.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.done_all,
                      color: ChatizyTheme.primary, size: 20),
                ),
                title: const Text('Read Receipts'),
                subtitle: Text(
                  'Show blue ticks when messages are read',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ChatizyTheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ChatizyTheme.helpBlue.withValues(alpha: 0.06),
                borderRadius: ChatizyTheme.radiusMd,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: ChatizyTheme.helpBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If you turn off read receipts, you won\'t be able to see read receipts from others either.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ChatizyTheme.outline,
                          ),
                    ),
                  ),
                ],
              ),
            ),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title,
                    style: Theme.of(ctx).textTheme.headlineSmall),
              ),
              for (final option in ['Everyone', 'My Contacts', 'Nobody'])
                RadioListTile<String>(
                  value: option,
                  groupValue: currentValue,
                  activeColor: ChatizyTheme.primary,
                  title: Text(option),
                  onChanged: (v) {
                    if (v != null) {
                      onChanged(v);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
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
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: ChatizyTheme.outline),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: ChatizyTheme.outlineVariant, size: 20),
        onTap: onTap,
      ),
    );
  }
}
