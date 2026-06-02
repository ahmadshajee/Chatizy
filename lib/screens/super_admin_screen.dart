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
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final dialogTextCol = isDark ? Colors.white : const Color(0xFF1C1C1E);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => GlassAlertDialog(
            title: const Text('Add Business Admin'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  GlassTextField(
                    controller: nameCtrl,
                    hintText: 'Admin Full Name',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: domainCtrl,
                    hintText: 'Company Domain (e.g., nexus.com)',
                    prefixIcon: const Icon(Icons.business_outlined, size: 20),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: emailCtrl,
                    hintText: 'Admin Email',
                    prefixIcon: const Icon(Icons.mail_outline, size: 20),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: passCtrl,
                    obscureText: true,
                    hintText: 'Initial Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    errorText: errorText,
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
                  domainCtrl.dispose();
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
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                final pass = passCtrl.text;
                final domain = domainCtrl.text.trim();

                if (name.isEmpty || email.isEmpty || pass.isEmpty || domain.isEmpty) {
                  setDialogState(() {
                    errorText = 'All fields are required';
                  });
                  return;
                }

                final auth = context.read<AuthProvider>();
                final success = await auth.createBusinessAdmin(
                  email: email,
                  password: pass,
                  fullName: name,
                  companyDomain: domain,
                );

                nameCtrl.dispose();
                emailCtrl.dispose();
                passCtrl.dispose();
                domainCtrl.dispose();

                if (ctx.mounted) Navigator.pop(ctx);
                if (success && mounted) {
                  context.read<AdminProvider>().loadSuperDashboard();
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
                'Super Admin',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Enterprise management overview.',
                style: TextStyle(
                  fontSize: 15,
                  color: textCol.withValues(alpha: 0.6),
                ),
              ),
            ],
          ).animate().fade(duration: 350.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 16),

          // Privacy notice card
          GlassCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: const Color(0xFF0A84FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.25),
              width: 0.8,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF0A84FF),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Message content is not accessible. Only aggregate statistics are visible.',
                    style: TextStyle(
                      color: const Color(0xFF0A84FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fade(delay: 50.ms, duration: 350.ms)
          .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 20),

          // Summary stats
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.business_rounded,
                  label: 'Enterprises',
                  value: admin.businessAdmins.length.toString(),
                  color: const Color(0xFF0A84FF),
                  index: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.people_alt_rounded,
                  label: 'Total Employees',
                  value: admin.totalEmployeesAllDomains.toString(),
                  color: const Color(0xFF30D158),
                  index: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add Admin button
          GlassButton(
            onPressed: _showAddAdminDialog,
            isGlowing: true,
            height: 50,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add New Business Admin',
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
          .fade(delay: 250.ms, duration: 350.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 24),

          // Managed Enterprises section
          Text(
            'Managed Enterprises',
            style: Theme.of(context).textTheme.headlineSmall,
          )
          .animate()
          .fade(delay: 300.ms, duration: 300.ms),
          const SizedBox(height: 12),

          if (admin.isLoading && admin.businessAdmins.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: Color(0xFF0A84FF)),
              ),
            )
          else if (admin.businessAdmins.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(32),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : null,
              border: isDark ? Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.8,
              ) : null,
              child: Column(
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 48,
                    color: textCol.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No business admins yet',
                    style: TextStyle(
                      color: textCol,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your first enterprise admin above',
                    style: TextStyle(
                      color: textCol.withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fade(delay: 350.ms, duration: 400.ms)
          else
            ...admin.businessAdmins.asMap().entries.map(
              (entry) => _AdminCard(
                admin: entry.value,
                employeeCount: admin.employeeCountsByDomain[entry.value.companyDomain] ?? 0,
                index: entry.key,
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
  final int index;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: textCol.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    .fade(delay: (150 + index * 50).ms, duration: 400.ms)
    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}

class _AdminCard extends StatelessWidget {
  final Profile admin;
  final int employeeCount;
  final int index;

  const _AdminCard({
    required this.admin,
    required this.employeeCount,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.04) : null,
      border: isDark ? Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 0.8,
      ) : null,
      child: Row(
        children: [
          // Company initials avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getAvatarGradient(admin.companyDomain ?? 'Nexus'),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _getAvatarGradient(admin.companyDomain ?? 'Nexus')[0].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (admin.companyDomain ?? 'Nexus').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                  style: TextStyle(
                    color: textCol,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  admin.companyDomain ?? 'No domain',
                  style: const TextStyle(
                    color: Color(0xFF0A84FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A84FF), Color(0xFF5E5CE6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  employeeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'employees',
                style: TextStyle(
                  color: textCol.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fade(delay: (400 + index * 40).ms, duration: 350.ms)
    .slideX(begin: 0.05, end: 0, curve: Curves.easeOut);
  }
}
