import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text("환영합니다")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("이메일: ${user?.email ?? ''}"),
            Text("닉네임: ${user?.nickname ?? ''}"),
            Text("마지막 로그인: ${user?.lastLogin.toLocal()}"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              child: Text("로그아웃"),
            ),
          ],
        ),
      ),
    );
  }
}
