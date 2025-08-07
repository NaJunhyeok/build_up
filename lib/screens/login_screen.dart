import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: pwCtrl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(authProvider.notifier)
                    .login(emailCtrl.text.trim(), pwCtrl.text.trim());

                if (!success) {
                  setState(() => error = "이메일 또는 비밀번호가 틀렸습니다");
                } else {
                  setState(() => error = null);
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                }
              },
              child: Text("로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
