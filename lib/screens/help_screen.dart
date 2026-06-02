import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../widgets/glass_widgets.dart';

/// Help screen with step-by-step usage guide.
/// Redesigned with premium Glass cards and staggered entry animations.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
          'Help Center',
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
            // Header
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0DF5E3), Color(0xFF0A84FF)],
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
                  Icons.help_outline_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            )
            .animate()
            .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'How can we help you?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            )
            .animate()
            .fade(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Learn how to get the most out of Chatizy',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            )
            .animate()
            .fade(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 36),

            // Help sections
            _HelpSection(
              icon: Icons.person_add_rounded,
              iconColor: const Color(0xFF0A84FF),
              title: 'Getting Started',
              index: 0,
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
              icon: Icons.contacts_rounded,
              iconColor: const Color(0xFF30D158),
              title: 'Adding Contacts',
              index: 1,
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
              icon: Icons.chat_bubble_rounded,
              iconColor: const Color(0xFF0DF5E3),
              title: 'Starting a Chat',
              index: 2,
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
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFFFD60A),
              title: 'Starring Messages',
              index: 3,
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
              icon: Icons.settings_rounded,
              iconColor: const Color(0xFF8E8E93),
              title: 'Account Settings',
              index: 4,
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
              icon: Icons.cloud_upload_rounded,
              iconColor: const Color(0xFFBF5AF2),
              title: 'Chat Backup & Restore',
              index: 5,
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
              icon: Icons.business_center_rounded,
              iconColor: const Color(0xFFFF453A),
              title: 'Business Features',
              index: 6,
              steps: const [
                'Business Admins can view employee activity in the Admin Dashboard.',
                'The dashboard shows online employees, message activity, and team stats.',
                'Business Admins can add new employees to their company domain.',
                'Employees within the same domain can see each other in Contacts.',
                'Super Admins manage all business domains from the Admin panel.',
              ],
            ),
            const SizedBox(height: 36),

            // Contact support card
            GlassCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color(0xFF0A84FF).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFF0A84FF).withValues(alpha: 0.25),
                width: 0.8,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        color: Color(0xFF0A84FF), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need more help?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Contact us at support@chatizy.com',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
            .fade(delay: 500.ms, duration: 400.ms),
            const SizedBox(height: 48),
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
  final int index;

  const _HelpSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.steps,
    required this.index,
  });

  @override
  State<_HelpSection> createState() => _HelpSectionState();
}

class _HelpSectionState extends State<_HelpSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.iconColor.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child:
                        Icon(widget.icon, color: widget.iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding:
                  const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: [
                  Divider(height: 16, color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < widget.steps.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: widget.iconColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: widget.iconColor,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                widget.steps[i],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
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
    )
    .animate()
    .fade(delay: (widget.index * 40).ms, duration: 350.ms)
    .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}
