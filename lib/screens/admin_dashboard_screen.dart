import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/profile.dart';

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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        title: const Text('Add New Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  hintText: 'Email @${auth.currentProfile?.companyDomain ?? ""}',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Initial Password',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nicknameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nickname (optional)',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Employee ID will be auto-generated',
                style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                      color: ChatizyTheme.outline,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await auth.createEmployee(
                email: emailCtrl.text.trim(),
                password: passCtrl.text,
                fullName: nameCtrl.text.trim(),
                companyDomain: auth.currentProfile?.companyDomain ?? '',
                nickname: nicknameCtrl.text.trim().isEmpty
                    ? null
                    : nicknameCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && mounted) {
                final domain = auth.currentProfile?.companyDomain;
                if (domain != null) {
                  context.read<AdminProvider>().loadBusinessDashboard(domain);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ChatizyTheme.marginPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin Dashboard',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Overview of system activity and personnel.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: ChatizyTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add Employee button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddEmployeeDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add New Employee'),
            ),
          ),
          const SizedBox(height: 20),

          // Stat cards grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                icon: Icons.group,
                iconColor: ChatizyTheme.primary,
                label: 'TOTAL USERS',
                value: admin.totalEmployees.toString(),
              ),
              _StatCard(
                icon: Icons.fiber_manual_record,
                iconColor: ChatizyTheme.secondary,
                label: 'ONLINE NOW',
                value: admin.onlineCount.toString(),
              ),
              _StatCard(
                icon: Icons.chat,
                iconColor: ChatizyTheme.tertiary,
                label: 'MESSAGES',
                value: admin.todayMessages > 999
                    ? '${(admin.todayMessages / 1000).toStringAsFixed(1)}k'
                    : admin.todayMessages.toString(),
              ),
              _StatCard(
                icon: Icons.warning_amber,
                iconColor: ChatizyTheme.error,
                label: 'ALERTS',
                value: '0',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Active Personnel
          Container(
            decoration: ChatizyTheme.glassPanel,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Personnel',
                          style: Theme.of(context).textTheme.headlineSmall),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 0.5,
                    color:
                        ChatizyTheme.outlineVariant.withValues(alpha: 0.3)),
                if (admin.isLoading && admin.employees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: ChatizyTheme.primary),
                    ),
                  )
                else if (admin.employees.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No employees yet',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: ChatizyTheme.outline),
                      ),
                    ),
                  )
                else
                  ...admin.employees.take(5).map(
                        (emp) => _EmployeeRow(employee: emp),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recent Activity
          Container(
            decoration: ChatizyTheme.glassPanel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Recent Activity',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                Divider(
                    height: 0.5,
                    color:
                        ChatizyTheme.outlineVariant.withValues(alpha: 0.3)),
                if (admin.recentActivity.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No recent activity',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: ChatizyTheme.outline),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: admin.recentActivity
                          .take(10)
                          .map((activity) => _ActivityItem(activity: activity))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
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

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ChatizyTheme.glassPanelRounded,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.8,
                        color: ChatizyTheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  final Profile employee;
  const _EmployeeRow({required this.employee});

  String _formatLastSeen(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Offline (${diff.inHours}h)';
    return 'Offline (${diff.inDays}d)';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Opacity(
        opacity: employee.isOnline ? 1.0 : 0.6,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ChatizyTheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  employee.fullName.substring(0, 1).toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        color: ChatizyTheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        employee.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (employee.isOnline) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ChatizyTheme.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (employee.employeeId != null)
                    Text(
                      employee.employeeId!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Text(
              employee.isOnline
                  ? _formatLastSeen(employee.lastSeen)
                  : _formatLastSeen(employee.lastSeen),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ChatizyTheme.primaryContainer,
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$senderName sent a message',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: ChatizyTheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
