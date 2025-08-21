import 'package:build_up/models/user_model.dart';
import 'package:build_up/root/guest_screen.dart';
import 'package:build_up/root/root_screen.dart';
import 'package:build_up/screens/home_screen.dart';
import 'package:build_up/utils/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameCtrl = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final sb = Supabase.instance.client;
      final uid = sb.auth.currentUser!.id;
      final googleName =
          sb.auth.currentUser?.userMetadata?['full_name'] as String?;
      // UPDATE (RLS 정책 필요)
      final updateMap = {
        'name': googleName,
        'nickname': _nicknameCtrl.text.trim(),
        'last_login': DateTime.now().toIso8601String(),
      };

      final row = await sb
          .from('users')
          .update(updateMap)
          .eq('uid', uid)
          .select(
            'uid,email,name,nickname,last_login,profile_image,created_at,role',
          )
          .single();

      // Riverpod 상태 갱신
      ref.read(authProvider.notifier).setUser(AppUser.fromJson(row));

      if (!mounted) return;
      // 프로필 완료 → Root로
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const RootScreen()));
    } on PostgrestException catch (e) {
      // 유니크 충돌(nickname 중복) 등 처리
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 실패: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sb = Supabase.instance.client;
    final googleName =
        sb.auth.currentUser?.userMetadata?['full_name'] as String?;
    // 표시용 프리필(닉네임 기본값 추천)
    _nicknameCtrl.text = _nicknameCtrl.text.isEmpty
        ? (googleName ?? sb.auth.currentUser?.email?.split('@').first ?? '')
        : _nicknameCtrl.text;

    return Scaffold(
      appBar: AppBar(title: const Text('프로필 완료')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nicknameCtrl,
                decoration: const InputDecoration(labelText: '닉네임'),
                maxLength: 20,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return '닉네임을 입력해주세요';
                  if (s.length < 2) return '닉네임은 2자 이상이어야 합니다';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
