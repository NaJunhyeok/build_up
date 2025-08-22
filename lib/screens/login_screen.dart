import 'package:build_up/root/guest_screen.dart';
import 'package:build_up/root/root_screen.dart';
import 'package:build_up/screens/home_screen.dart';
import 'package:build_up/utils/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    Future<void> _handleGoogle() async {
      // 로딩 중복 방지 등 필요하면 여기에 가드 추가
      final ok = await ref.read(authProvider.notifier).loginWithGoogle();

      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google 로그인 완료')));
        // 필요 시 메인 화면으로 이동
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (_) => const RootScreen()),
        //   (_) => false,
        // );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google 로그인 실패')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _handleGoogle,
                child: Text(
                  "구글 로그인",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              ElevatedButton(
                onPressed: () async {},
                child: Text(
                  "카카오 로그인",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).guestLogin();
                },
                child: Text(
                  "게스트 로그인",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
