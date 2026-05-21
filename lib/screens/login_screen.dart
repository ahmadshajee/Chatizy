import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

/// Login screen matching the Chatizy design mockup.
/// Warm beige background, centered logo, email/password with icons,
/// password visibility toggle, and navigation to registration.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ChatizyTheme.marginPage),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
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
                      Text(
                        'Chatizy',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: ChatizyTheme.stackSm),
                      Text(
                        'Log in to continue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: ChatizyTheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),

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

                      // Email field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.mail_outlined,
                              size: 20, color: ChatizyTheme.outlineVariant),
                          filled: true,
                          fillColor: ChatizyTheme.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: ChatizyTheme.radiusXxl,
                            borderSide: BorderSide(
                                color: ChatizyTheme.outlineVariant
                                    .withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: ChatizyTheme.radiusXxl,
                            borderSide: BorderSide(
                                color: ChatizyTheme.outlineVariant
                                    .withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined,
                              size: 20, color: ChatizyTheme.outlineVariant),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: ChatizyTheme.outlineVariant,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: ChatizyTheme.surfaceContainerLowest,
                          border: OutlineInputBorder(
                            borderRadius: ChatizyTheme.radiusXxl,
                            borderSide: BorderSide(
                                color: ChatizyTheme.outlineVariant
                                    .withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: ChatizyTheme.radiusXxl,
                            borderSide: BorderSide(
                                color: ChatizyTheme.outlineVariant
                                    .withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Log In'),
                        ),
                      ),
                      const SizedBox(height: ChatizyTheme.stackLg),

                      // Forgot password
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: ChatizyTheme.primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),

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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
