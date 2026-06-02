import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/profile.dart';
import '../widgets/glass_widgets.dart';

/// Helper to get a beautiful linear gradient for avatars based on the name.
List<Color> _getAvatarGradient(String name) {
  if (name.isEmpty) return [const Color(0xFF0A84FF), const Color(0xFF5E5CE6)];
  final char = name.substring(0, 1).toUpperCase();
  final code = char.codeUnitAt(0);
  if (code % 4 == 0) {
    return [const Color(0xFF0A84FF), const Color(0xFF0DF5E3)]; // Cyan to Blue
  } else if (code % 4 == 1) {
    return [const Color(0xFF5E5CE6), const Color(0xFFBF5AF2)]; // Indigo to Purple
  } else if (code % 4 == 2) {
    return [const Color(0xFFFF2D55), const Color(0xFFFF453A)]; // Pink to Red
  } else {
    return [const Color(0xFF30D158), const Color(0xFF0DF5E3)]; // Green to Cyan
  }
}

/// Business Admin Dashboard matching the Chatizy design mockup.
/// Shows stat cards, active personnel list with online indicators,
/// and recent activity feed (metadata only, no message content).
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final domain = auth.currentProfile?.companyDomain;
      if (domain != null) {
        context.read<AdminProvider>().loadBusinessDashboard(domain);
      }
    });
  }

  void _showAddEmployeeDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nicknameCtrl = TextEditingController();
    final auth = context.read<AuthProvider>();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final dialogTextCol = isDark ? Colors.white : const Color(0xFF1C1C1E);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => GlassAlertDialog(
            title: const Text('Add New Employee'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  GlassTextField(
                    controller: nameCtrl,
                    hintText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: emailCtrl,
                    hintText: 'Email @${auth.currentProfile?.companyDomain ?? ""}',
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: passCtrl,
                    obscureText: true,
                    hintText: 'Initial Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: nicknameCtrl,
                    hintText: 'Nickname (optional)',
                    prefixIcon: const Icon(Icons.alternate_email, size: 20),
                    errorText: errorText,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Employee ID will be auto-generated',
                    style: TextStyle(
                      fontSize: 11,
                      color: dialogTextCol.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  nameCtrl.dispose();
                  emailCtrl.dispose();
                  passCtrl.dispose();
                  nicknameCtrl.dispose();
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: dialogTextCol.withValues(alpha: 0.6)),
                ),
              ),
            GlassButton(
              width: 100,
              height: 36,
              isGlowing: true,
              borderRadius: BorderRadius.circular(18),
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final name = nameCtrl.text.trim();
                final pass = passCtrl.text;
                if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                  setDialogState(() {
                    errorText = 'All required fields must be filled';
                  });
                  return;
                }

                // Check email domain match
                final domain = auth.currentProfile?.companyDomain ?? '';
                if (!email.endsWith('@$domain')) {
                  setDialogState(() {
                    errorText = 'Email must end with @$domain';
                  });
                  return;
                }

                final success = await auth.createEmployee(
                  email: email,
                  password: pass,
                  fullName: name,
                  companyDomain: domain,
                  nickname: nicknameCtrl.text.trim().isEmpty
                      ? null
                      : nicknameCtrl.text.trim(),
                );

                nameCtrl.dispose();
                emailCtrl.dispose();
                passCtrl.dispose();
                nicknameCtrl.dispose();

                if (ctx.mounted) Navigator.pop(ctx);
                if (success && mounted) {
                  final domain = auth.currentProfile?.companyDomain;
                  if (domain != null) {
                    context.read<AdminProvider>().loadBusinessDashboard(domain);
                  }
                }
              },
              child: const Text(
                'Create',
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
  );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatizyTheme.marginPage,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Overview of system activity and personnel.',
                style: TextStyle(
                  fontSize: 15,
                  color: textCol.withValues(alpha: 0.6),
                ),
              ),
            ],
          ).animate().fade(duration: 350.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 20),

          // Add Employee button
          GlassButton(
            onPressed: _showAddEmployeeDialog,
            isGlowing: true,
            height: 50,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add New Employee',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fade(delay: 100.ms, duration: 350.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 20),

          // Stat cards grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.group_rounded,
                iconColor: const Color(0xFF0A84FF),
                label: 'TOTAL USERS',
                value: admin.totalEmployees.toString(),
                index: 0,
              ),
              _StatCard(
                icon: Icons.wifi_rounded,
                iconColor: const Color(0xFF30D158),
                label: 'ONLINE NOW',
                value: admin.onlineCount.toString(),
                index: 1,
              ),
              _StatCard(
                icon: Icons.chat_bubble_rounded,
                iconColor: const Color(0xFFBF5AF2),
                label: 'MESSAGES',
                value: admin.todayMessages > 999
                    ? '${(admin.todayMessages / 1000).toStringAsFixed(1)}k'
                    : admin.todayMessages.toString(),
                index: 2,
              ),
              _StatCard(
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFFFF453A),
                label: 'ALERTS',
                value: '0',
                index: 3,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Active Personnel
          GlassCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : null,
            border: isDark ? Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.8,
            ) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Personnel',
                      style: TextStyle(
                        color: textCol,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF0A84FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                if (admin.isLoading && admin.employees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF0A84FF)),
                    ),
                  )
                else if (admin.employees.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No employees yet',
                        style: TextStyle(color: textCol.withValues(alpha: 0.4)),
                      ),
                    ),
                  )
                else
                  ...admin.employees.take(5).toList().asMap().entries.map(
                        (entry) => _EmployeeRow(
                          employee: entry.value,
                          index: entry.key,
                        ),
                      ),
              ],
            ),
          )
          .animate()
          .fade(delay: 350.ms, duration: 450.ms)
          .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 20),

          // Recent Activity
          GlassCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : null,
            border: isDark ? Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.8,
            ) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: textCol,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Divider(height: 16),
                if (admin.recentActivity.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No recent activity',
                        style: TextStyle(color: textCol.withValues(alpha: 0.4)),
                      ),
                    ),
                  )
                else
                  ...admin.recentActivity.take(10).toList().asMap().entries.map(
                        (entry) => _ActivityItem(
                          activity: entry.value,
                          index: entry.key,
                        ),
                      ),
              ],
            ),
          )
          .animate()
          .fade(delay: 500.ms, duration: 450.ms)
          .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final int index;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : null,
      borderRadius: BorderRadius.circular(20),
      border: isDark ? Border.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 0.8,
      ) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: textCol.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textCol,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    )
    .animate()
    .fade(delay: (200 + index * 50).ms, duration: 400.ms)
    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}

class _EmployeeRow extends StatelessWidget {
  final Profile employee;
  final int index;

  const _EmployeeRow({
    required this.employee,
    required this.index,
  });

  String _formatLastSeen(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Offline (${diff.inHours}h)';
    return 'Offline (${diff.inDays}d)';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Avatar with online status badge on corner
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _getAvatarGradient(employee.fullName),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getAvatarGradient(employee.fullName)[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    employee.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (employee.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF30D158),
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF070B19) : Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF30D158).withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.displayName,
                  style: TextStyle(
                    color: textCol,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (employee.employeeId != null)
                  Text(
                    employee.employeeId!,
                    style: TextStyle(
                      color: textCol.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatLastSeen(employee.lastSeen),
            style: TextStyle(
              color: textCol.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    )
    .animate()
    .fade(delay: (400 + index * 50).ms, duration: 300.ms)
    .slideX(begin: 0.05, end: 0, curve: Curves.easeOut);
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final int index;

  const _ActivityItem({
    required this.activity,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1C1C1E);

    final senderName = activity['sender_name'] as String? ?? 'Unknown';
    final createdAt =
        DateTime.tryParse(activity['created_at'] as String? ?? '') ??
            DateTime.now();
    final diff = DateTime.now().difference(createdAt);
    String timeStr;
    if (diff.inMinutes < 1) {
      timeStr = 'Just now';
    } else if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes} mins ago';
    } else {
      timeStr = '${diff.inHours}h ago';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$senderName sent a message',
                  style: TextStyle(
                    color: textCol,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: textCol.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fade(delay: (550 + index * 40).ms, duration: 300.ms)
    .slideX(begin: 0.05, end: 0, curve: Curves.easeOut);
  }
}
