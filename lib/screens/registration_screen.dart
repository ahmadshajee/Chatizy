import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_widgets.dart';

/// Registration screen redesigned with a premium Apple Glass UI.
/// Frosted glass form card, glass text fields, segment toggle, and entrance animations.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isBusinessMode = false;
  String? _parsedDomain;

  @override
  void initState() {
    super.initState();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ChatizyTheme.marginPage),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glowing border
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFFBF5AF2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A84FF).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                    .animate()
                    .fade(duration: 400.ms)
                    .scale(delay: 50.ms, duration: 300.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: ChatizyTheme.stackMd),
                    
                    Text('Chatizy',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ))
                    .animate()
                    .fade(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: ChatizyTheme.stackSm),
                    Text(
                      'Connect effortlessly.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                          ),
                    )
                    .animate()
                    .fade(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: 24),

                    // Account type toggle
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: ChatizyTheme.radiusFull,
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                          width: 0.8,
                        ),
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
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !_isBusinessMode
                                      ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: ChatizyTheme.radiusFull,
                                  border: !_isBusinessMode
                                      ? Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15), width: 0.5)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Personal',
                                  style: TextStyle(
                                    color: !_isBusinessMode
                                        ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
                                        : (isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF8E8E93)),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
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
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isBusinessMode
                                      ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: ChatizyTheme.radiusFull,
                                  border: _isBusinessMode
                                      ? Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15), width: 0.5)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Business',
                                  style: TextStyle(
                                    color: _isBusinessMode
                                        ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
                                        : (isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF8E8E93)),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fade(delay: 200.ms, duration: 400.ms),
                    
                    const SizedBox(height: 20),

                    // Error message
                    if (auth.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ChatizyTheme.errorContainer.withValues(alpha: 0.6),
                          borderRadius: ChatizyTheme.radiusMd,
                          border: Border.all(
                            color: ChatizyTheme.error.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
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
                                    ?.copyWith(color: ChatizyTheme.error, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .shake(duration: 400.ms),
                      const SizedBox(height: 16),
                    ],

                    // Input Fields Grouped in a column (no double spacing)
                    Column(
                      children: [
                        // Full Name
                        GlassTextField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                        ),
                        const SizedBox(height: 12),
                        // Email
                        GlassTextField(
                          controller: _emailController,
                          hintText: _isBusinessMode ? 'Company Email' : 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.mail_outlined, size: 20),
                        ),
                        const SizedBox(height: 12),
                        // Password
                        GlassTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: _obscurePassword,
                          textInputAction: _isBusinessMode
                              ? TextInputAction.next
                              : TextInputAction.done,
                          onSubmitted:
                              _isBusinessMode ? null : (_) => _handleSignUp(),
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        // Business-only fields
                        if (_isBusinessMode) ...[
                          const SizedBox(height: 12),
                          GlassTextField(
                            controller: _nicknameController,
                            hintText: 'Nickname (optional)',
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleSignUp(),
                            prefixIcon: const Icon(Icons.alternate_email, size: 20),
                          )
                          .animate()
                          .fade(duration: 250.ms)
                          .slideY(begin: 0.1, end: 0),
                        ],
                      ],
                    )
                    .animate()
                    .fade(delay: 250.ms, duration: 400.ms),

                    // Parsed domain chip (business mode)
                    if (_isBusinessMode && _parsedDomain != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ChatizyTheme.primary.withValues(alpha: 0.2),
                          borderRadius: ChatizyTheme.radiusFull,
                          border: Border.all(color: ChatizyTheme.primary.withValues(alpha: 0.4), width: 0.5),
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
                                    color: isDark ? Colors.white : ChatizyTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .scale(duration: 200.ms),
                    ],
 
                    // Employee ID note
                    if (_isBusinessMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Employee ID will be auto-generated',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                            ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Sign up button
                    GlassButton(
                      onPressed: auth.isLoading ? null : _handleSignUp,
                      isGlowing: true,
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    )
                    .animate()
                    .fade(delay: 300.ms, duration: 400.ms),
                    
                    const SizedBox(height: 24),

                    // Login link
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Log In if you already have an account',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ChatizyTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                    .animate()
                    .fade(delay: 350.ms, duration: 400.ms),
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
