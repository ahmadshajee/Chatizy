import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';

/// Chat backup and restore screen.
/// Export chats as JSON (download) and restore from a JSON file.
class ChatBackupScreen extends StatefulWidget {
  const ChatBackupScreen({super.key});

  @override
  State<ChatBackupScreen> createState() => _ChatBackupScreenState();
}

class _ChatBackupScreenState extends State<ChatBackupScreen> {
  bool _isExporting = false;
  int? _exportedCount;
  String? _lastExportTime;

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
          'Chat Backup',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ChatizyTheme.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup illustration
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ChatizyTheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 56,
                  color: ChatizyTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Keep your messages safe',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Export your chat history as a JSON file that you can\nrestore later if needed.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ChatizyTheme.outline,
                    ),
              ),
            ),
            const SizedBox(height: 32),

            // Last backup info
            if (_lastExportTime != null || _exportedCount != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ChatizyTheme.onlineGreen.withValues(alpha: 0.08),
                  borderRadius: ChatizyTheme.radiusMd,
                  border: Border.all(
                    color: ChatizyTheme.onlineGreen.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: ChatizyTheme.onlineGreen, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Export',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: ChatizyTheme.outline),
                        ),
                        Text(
                          '${_exportedCount ?? 0} messages • ${_lastExportTime ?? ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Backup button
            Container(
              decoration: ChatizyTheme.glassPanelRounded,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.primary.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.download,
                      color: ChatizyTheme.primary, size: 22),
                ),
                title: const Text('Export Chats'),
                subtitle: Text(
                  'Download all your messages as JSON',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ChatizyTheme.outline),
                ),
                trailing: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ChatizyTheme.primary,
                        ),
                      )
                    : const Icon(Icons.chevron_right,
                        color: ChatizyTheme.outlineVariant),
                onTap: _isExporting ? null : () => _exportChats(context),
              ),
            ),
            const SizedBox(height: 12),

            // Restore button
            Container(
              decoration: ChatizyTheme.glassPanelRounded,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ChatizyTheme.onlineGreen.withValues(alpha: 0.1),
                    borderRadius: ChatizyTheme.radiusMd,
                  ),
                  child: const Icon(Icons.upload,
                      color: ChatizyTheme.onlineGreen, size: 22),
                ),
                title: const Text('Restore Chats'),
                subtitle: Text(
                  'Import messages from a backup file',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ChatizyTheme.outline),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: ChatizyTheme.outlineVariant),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Restore requires file_picker package. Coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Info section
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
                      'Backups include message text, sender info, and timestamps. Media files are not included in the backup.',
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

  Future<void> _exportChats(BuildContext context) async {
    setState(() => _isExporting = true);

    try {
      final chatProvider = context.read<ChatProvider>();
      final messages = await chatProvider.exportMessages();

      setState(() {
        _isExporting = false;
        _exportedCount = messages.length;
        _lastExportTime = DateFormat('MMM d, h:mm a').format(DateTime.now());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${messages.length} messages successfully'),
            backgroundColor: ChatizyTheme.onlineGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: ChatizyTheme.error,
          ),
        );
      }
    }
  }
}
