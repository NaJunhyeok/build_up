// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart'; // authProvider 경로에 맞게 수정

final darkModeProvider = StateProvider<bool>((ref) => false); // 예시용

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader('프로필'),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('내 정보'),
            subtitle: const Text('이름, 닉네임, 연락처'),
            onTap: () {
              // TODO: 프로필 편집 화면으로 이동
            },
          ),
          const Divider(height: 1),

          const _SectionHeader('계정'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('비밀번호 변경'),
            onTap: () {
              // TODO: 비밀번호 변경 화면
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('개인정보/보안'),
            onTap: () {
              // TODO: 보안 설정 화면
            },
          ),
          const Divider(height: 1),

          const _SectionHeader('알림'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('푸시 알림'),
            value: true,
            onChanged: (v) {
              // TODO: 알림 설정 저장
            },
          ),
          const Divider(height: 1),

          const _SectionHeader('디스플레이'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('다크 모드'),
            value: isDark,
            onChanged: (v) => ref.read(darkModeProvider.notifier).state = v,
          ),
          const Divider(height: 1),

          const _SectionHeader('앱 정보'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('버전'),
            subtitle: const Text('1.0.0'), // TODO: package_info_plus로 실제 버전 표기
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('이용약관'),
            onTap: () {
              // TODO: 약관 화면
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('개인정보 처리방침'),
            onTap: () {
              // TODO: 정책 화면
            },
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말 로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('취소'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('로그아웃'),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그아웃 되었습니다.')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeLayoutInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class EdgeLayoutInsets extends EdgeInsets {
  const EdgeLayoutInsets.symmetric({
    required double horizontal,
    required double vertical,
  }) : super.symmetric(horizontal: horizontal, vertical: vertical);
}
