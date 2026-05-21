import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

/// Registration screen with role-branched flow.
/// Toggle between "Personal" and "Business Employee" modes.
/// Business mode auto-parses email domain and shows Employee ID + Nickname fields.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isBusinessMode = false;
  String? _parsedDomain;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _emailController.addListener(_parseDomain);
  }

  void _parseDomain() {
    final email = _emailController.text.trim();
    if (_isBusinessMode && email.contains('@')) {
      final domain = email.split('@').last;
      if (domain.isNotEmpty && domain.contains('.')) {
        setState(() => _parsedDomain = domain);
        return;
      }
    }
    setState(() => _parsedDomain = null);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      return;
    }

    bool success;
    if (_isBusinessMode) {
      if (_parsedDomain == null) return;
      success = await auth.signUpEmployee(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        companyDomain: _parsedDomain!,
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
      );
    } else {
      success = await auth.signUpPersonal(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ChatizyTheme.marginPage),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: ChatizyTheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: ChatizyTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: ChatizyTheme.stackMd),
                    Text('Chatizy',
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: ChatizyTheme.stackSm),
                    Text(
                      'Connect effortlessly.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: ChatizyTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),

                    // Account type toggle
                    Container(
                      decoration: BoxDecoration(
                        color: ChatizyTheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: ChatizyTheme.radiusFull,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _isBusinessMode = false;
                                _parseDomain();
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isBusinessMode
                                      ? ChatizyTheme.primary
                                      : Colors.transparent,
                                  borderRadius: ChatizyTheme.radiusFull,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Personal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: !_isBusinessMode
                                            ? Colors.white
                                            : ChatizyTheme.onSurfaceVariant,
                                        fontSize: 15,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _isBusinessMode = true;
                                _parseDomain();
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isBusinessMode
                                      ? ChatizyTheme.primary
                                      : Colors.transparent,
                                  borderRadius: ChatizyTheme.radiusFull,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Business Employee',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: _isBusinessMode
                                            ? Colors.white
                                            : ChatizyTheme.onSurfaceVariant,
                                        fontSize: 15,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error message
                    if (auth.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ChatizyTheme.errorContainer,
                          borderRadius: ChatizyTheme.radiusMd,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: ChatizyTheme.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: ChatizyTheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Form fields in grouped iOS-style container
                    Container(
                      decoration: BoxDecoration(
                        color: ChatizyTheme.surfaceContainerLowest,
                        borderRadius: ChatizyTheme.radiusMd,
                        border: Border.all(
                          color: ChatizyTheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Full Name
                          TextField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Full Name',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                          Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: 16,
                            color: ChatizyTheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                          // Email
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: _isBusinessMode
                                  ? 'Company Email'
                                  : 'Email',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                          Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: 16,
                            color: ChatizyTheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                          // Password
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: _isBusinessMode
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onSubmitted:
                                _isBusinessMode ? null : (_) => _handleSignUp(),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: ChatizyTheme.outlineVariant,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          // Business-only fields
                          if (_isBusinessMode) ...[
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              indent: 16,
                              color: ChatizyTheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                            TextField(
                              controller: _nicknameController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleSignUp(),
                              decoration: const InputDecoration(
                                hintText: 'Nickname (optional)',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Parsed domain chip (business mode)
                    if (_isBusinessMode && _parsedDomain != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ChatizyTheme.primaryFixed,
                          borderRadius: ChatizyTheme.radiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.domain,
                                size: 16, color: ChatizyTheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Domain: $_parsedDomain',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: ChatizyTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Employee ID note
                    if (_isBusinessMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Employee ID will be auto-generated',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: ChatizyTheme.outline,
                            ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSignUp,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: ChatizyTheme.stackLg),

                    // Login link
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Log In if you already have an account',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: ChatizyTheme.primary,
                                ),
                      ),
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
