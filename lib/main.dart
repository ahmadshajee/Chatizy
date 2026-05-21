import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/conversation_screen.dart';
import 'screens/starred_messages_screen.dart';
import 'screens/account_screen.dart';
import 'screens/chat_backup_screen.dart';
import 'screens/help_screen.dart';
import 'screens/privacy_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style for warm beige background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: ChatizyTheme.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ChatizyApp());
}

class ChatizyApp extends StatelessWidget {
  const ChatizyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Chatizy',
        debugShowCheckedModeBanner: false,
        theme: ChatizyTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/home': (context) => const HomeScreen(),
          '/conversation': (context) => const ConversationScreen(),
          '/starred': (context) => const StarredMessagesScreen(),
          '/account': (context) => const AccountScreen(),
          '/chat-backup': (context) => const ChatBackupScreen(),
          '/help': (context) => const HelpScreen(),
          '/privacy': (context) => const PrivacyScreen(),
        },
        // Auto-navigate to home if already authenticated
        builder: (context, child) {
          return _AuthGate(child: child!);
        },
      ),
    );
  }
}

/// Listens to auth state and redirects to login or home accordingly.
class _AuthGate extends StatefulWidget {
  final Widget child;
  const _AuthGate({required this.child});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final auth = context.read<AuthProvider>();
      if (auth.currentProfile != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
