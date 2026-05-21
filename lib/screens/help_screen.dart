import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Help screen with step-by-step usage guide.
/// Expandable accordion sections for different app features.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
          'Help',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ChatizyTheme.marginPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ChatizyTheme.helpBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline,
                  size: 40,
                  color: ChatizyTheme.helpBlue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'How to use Chatizy',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Everything you need to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ChatizyTheme.outline,
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Help sections
            _HelpSection(
              icon: Icons.person_add,
              iconColor: ChatizyTheme.primary,
              title: 'Getting Started',
              steps: const [
                'Open the app and tap "Sign Up" on the login page.',
                'Choose "Personal" for personal use, or "Business Employee" if your company uses Chatizy.',
                'Fill in your name, email, and password.',
                'For Business accounts, enter your company domain and employee ID.',
                'Tap "Sign Up" to create your account.',
              ],
            ),
            const SizedBox(height: 12),

            _HelpSection(
              icon: Icons.contacts,
              iconColor: ChatizyTheme.onlineGreen,
              title: 'Adding Contacts',
              steps: const [
                'Go to the Contacts tab at the bottom.',
                'Tap "Add New Contact" or the + button.',
                'Enter the email address of the person you want to add.',
                'Tap "Find Contact" to search.',
                'When found, tap "Chat" to start a conversation.',
                'The contact will appear in both Contacts and Chats.',
              ],
            ),
            const SizedBox(height: 12),

            _HelpSection(
              icon: Icons.chat_bubble_outline,
              iconColor: ChatizyTheme.helpBlue,
              title: 'Starting a Chat',
              steps: const [
                'Go to the Chats tab.',
                'Tap the ✏️ (edit) button in the bottom right.',
                'Search for a user by name or email.',
                'Tap on a user to start a conversation.',
                'Type your message and tap the send button.',
                'You\'ll see grey checkmarks (✓✓) when sent, and blue when read.',
              ],
            ),
            const SizedBox(height: 12),

            _HelpSection(
              icon: Icons.star_border,
              iconColor: ChatizyTheme.starYellow,
              title: 'Starring Messages',
              steps: const [
                'Open a conversation.',
                'Long-press on any message you want to bookmark.',
                'Tap "Star Message" from the menu.',
                'View all starred messages from Settings → Starred Messages.',
                'To unstar, long-press the message again and tap "Unstar".',
              ],
            ),
            const SizedBox(height: 12),

            _HelpSection(
              icon: Icons.settings,
              iconColor: ChatizyTheme.outline,
              title: 'Account Settings',
              steps: const [
                'Go to Settings → Account.',
                'Tap the camera icon to change your profile picture.',
                'Update your Status (visible to contacts).',
                'Change your Name or Nickname.',
                'Update your password from "Change Password".',
              ],
            ),
            const SizedBox(height: 12),

            _HelpSection(
              icon: Icons.cloud_upload_outlined,
              iconColor: ChatizyTheme.tertiary,
              title: 'Chat Backup & Restore',
              steps: const [
                'Go to Settings → Chats.',
                'Tap "Export Chats" to download all messages as JSON.',
                'Your backup includes message text, sender info, and timestamps.',
                'To restore, tap "Restore Chats" and select your backup file.',
                'Media files (images, audio) are not included in backups.',
              ],
            ),
            const SizedBox(height: 12),

            _HelpSection(
              icon: Icons.business,
              iconColor: ChatizyTheme.secondary,
              title: 'Business Features',
              steps: const [
                'Business Admins can view employee activity in the Admin Dashboard.',
                'The dashboard shows online employees, message activity, and team stats.',
                'Business Admins can add new employees to their company domain.',
                'Employees within the same domain can see each other in Contacts.',
                'Super Admins manage all business domains from the Admin panel.',
              ],
            ),
            const SizedBox(height: 32),

            // Contact support
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ChatizyTheme.primary.withValues(alpha: 0.06),
                borderRadius: ChatizyTheme.radiusMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent,
                      color: ChatizyTheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need more help?',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Contact us at support@chatizy.com',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: ChatizyTheme.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HelpSection extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> steps;

  const _HelpSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.steps,
  });

  @override
  State<_HelpSection> createState() => _HelpSectionState();
}

class _HelpSectionState extends State<_HelpSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ChatizyTheme.glassPanelRounded,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.1),
                      borderRadius: ChatizyTheme.radiusMd,
                    ),
                    child:
                        Icon(widget.icon, color: widget.iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right,
                        color: ChatizyTheme.outlineVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  for (int i = 0; i < widget.steps.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: widget.iconColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.iconColor,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                widget.steps[i],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: ChatizyTheme.onSurface),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
