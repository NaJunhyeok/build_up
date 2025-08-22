import 'package:build_up/root/root_screen.dart';
import 'package:build_up/screens/complate_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // 👇 dotenv 먼저 초기화
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.get("db_url"),
    anonKey: dotenv.get("db_api_key"),
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const LoginScreen(key: ValueKey('login'));
    }
    if (user.isGuest) return const RootScreen();

    final needsProfile = (user.nickname ?? '').trim().isEmpty; // null-safe
    if (needsProfile) {
      return const CompleteProfileScreen(key: ValueKey('complete'));
    }

    return RootScreen(key: ValueKey('root_${user.uid}'));
  }
}
