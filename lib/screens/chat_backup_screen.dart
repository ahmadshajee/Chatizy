import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import '../widgets/glass_widgets.dart';

/// Chat backup and restore screen redesigned with Apple Glass UI.
/// Export chats as JSON and restore from a JSON file.
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
          'Chat Backup',
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
            const SizedBox(height: 20),
            // Backup illustration
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            )
            .animate()
            .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 28),
            Center(
              child: Text(
                'Secure Your Conversations',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            )
            .animate()
            .fade(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Export your chat history as a JSON file that you can\nrestore later if needed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            )
            .animate()
            .fade(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 36),

            // Last backup info
            if (_lastExportTime != null || _exportedCount != null)
              GlassCard(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF30D158).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFF30D158).withValues(alpha: 0.25),
                  width: 0.8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF30D158), size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Export Successfully Completed',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_exportedCount ?? 0} messages • ${_lastExportTime ?? ''}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(duration: 350.ms)
              .slideY(begin: 0.1, end: 0),

            // Backup button list items
            GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.download_rounded,
                          color: Color(0xFF0A84FF), size: 24),
                    ),
                    title: Text(
                      'Export Chats',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Download all your messages as JSON',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0A84FF),
                            ),
                          )
                        : Icon(Icons.chevron_right_rounded,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    onTap: _isExporting ? null : () => _exportChats(context),
                  ),
                  const Divider(height: 1, indent: 76, endIndent: 20),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF30D158).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.upload_file_rounded,
                          color: Color(0xFF30D158), size: 24),
                    ),
                    title: Text(
                      'Restore Chats',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Import messages from a backup file',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => GlassAlertDialog(
                          icon: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_sync, color: Color(0xFF0A84FF), size: 28),
                          ),
                          title: const Text('Restore Coming Soon'),
                          content: const Text(
                            'Restore requires a file_picker package installation. This feature will be available in the next release.',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            GlassButton(
                              width: 100,
                              height: 38,
                              isGlowing: true,
                              borderRadius: BorderRadius.circular(12),
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
            .animate()
            .fade(delay: 300.ms, duration: 400.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 32),

            // Info section
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF0A84FF), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Backups include message text, sender info, and timestamps. Media files and attachments are not included in the backup.',
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
            .fade(delay: 400.ms, duration: 400.ms),
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
            backgroundColor: const Color(0xFF30D158),
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
