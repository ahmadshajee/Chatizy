import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/profile.dart';

/// Super Admin Dashboard — Developer/Super Admin exclusive view.
/// Shows all managed Business Admin accounts with employee counts.
/// Cannot see any message content (privacy lock enforced by design).
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSuperDashboard();
    });
  }

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final domainCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatizyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: ChatizyTheme.radiusXl),
        title: const Text('Add Business Admin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Admin Full Name',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: domainCtrl,
                decoration: const InputDecoration(
                  hintText: 'Company Domain (e.g., nexus.com)',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  hintText: 'Admin Email',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              final auth = context.read<AuthProvider>();
              final success = await auth.createBusinessAdmin(
                email: emailCtrl.text.trim(),
                password: passCtrl.text,
                fullName: nameCtrl.text.trim(),
                companyDomain: domainCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (success && mounted) {
                context.read<AdminProvider>().loadSuperDashboard();
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
          Text('Super Admin',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 4),
          Text(
            'Enterprise management overview.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: ChatizyTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // Privacy notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ChatizyTheme.primaryFixed.withValues(alpha: 0.5),
              borderRadius: ChatizyTheme.radiusMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    color: ChatizyTheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Message content is not accessible. Only aggregate statistics are visible.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ChatizyTheme.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Summary stats
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.business,
                  label: 'Enterprises',
                  value: admin.businessAdmins.length.toString(),
                  color: ChatizyTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.people,
                  label: 'Total Employees',
                  value: admin.totalEmployeesAllDomains.toString(),
                  color: ChatizyTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add Admin button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddAdminDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add New Business Admin'),
            ),
          ),
          const SizedBox(height: 20),

          // Admin cards
          Text('Managed Enterprises',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),

          if (admin.isLoading && admin.businessAdmins.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child:
                    CircularProgressIndicator(color: ChatizyTheme.primary),
              ),
            )
          else if (admin.businessAdmins.isEmpty)
            Container(
              decoration: ChatizyTheme.glassPanel,
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.business_center_outlined,
                      size: 48,
                      color:
                          ChatizyTheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    'No business admins yet',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: ChatizyTheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your first enterprise admin above',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: ChatizyTheme.outline),
                  ),
                ],
              ),
            )
          else
            ...admin.businessAdmins.map(
              (bAdmin) => _AdminCard(
                admin: bAdmin,
                employeeCount:
                    admin.employeeCountsByDomain[bAdmin.companyDomain] ?? 0,
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ChatizyTheme.glassPanelRounded,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.5,
                      color: ChatizyTheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final Profile admin;
  final int employeeCount;

  const _AdminCard({required this.admin, required this.employeeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ChatizyTheme.glassPanel,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Company icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ChatizyTheme.primaryFixed,
              borderRadius: ChatizyTheme.radiusMd,
            ),
            child: Center(
              child: Text(
                (admin.companyDomain ?? 'U').substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: ChatizyTheme.primary,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  admin.companyDomain ?? 'No domain',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ChatizyTheme.primary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                employeeCount.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: ChatizyTheme.primary,
                    ),
              ),
              Text(
                'employees',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ChatizyTheme.outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
