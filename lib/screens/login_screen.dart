import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_widgets.dart';

/// Login screen redesigned with a premium Apple Glass UI.
/// Frosted glass card, glass text fields, glowing primary button, and staggered animation.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      return;
    }

    final success = await auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with glowing border
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFFBF5AF2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A84FF).withValues(alpha: 0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    )
                    .animate()
                    .fade(duration: 500.ms)
                    .scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: ChatizyTheme.stackLg),
                    
                    Text(
                      'Chatizy',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    )
                    .animate()
                    .fade(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: ChatizyTheme.stackSm),
                    Text(
                      'Log in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
                          ),
                    )
                    .animate()
                    .fade(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: 32),

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

                    // Email field
                    GlassTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.mail_outlined, size: 20),
                    )
                    .animate()
                    .fade(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: 16),

                    // Password field
                    GlassTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    )
                    .animate()
                    .fade(delay: 500.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: 28),

                    // Login button
                    GlassButton(
                      onPressed: auth.isLoading ? null : _handleLogin,
                      isGlowing: true,
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    )
                    .animate()
                    .fade(delay: 600.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    
                    const SizedBox(height: 20),

                    // Forgot password
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ChatizyTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                    .animate()
                    .fade(delay: 700.ms, duration: 400.ms),
                    
                    const SizedBox(height: 8),

                    // Create account link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/register'),
                          child: Text(
                            'Create Account',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: ChatizyTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fade(delay: 800.ms, duration: 400.ms),
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
