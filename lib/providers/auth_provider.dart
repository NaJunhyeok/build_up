import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

final supabase = Supabase.instance.client;

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null);

  Future<bool> login(String email, String pw) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('pw', pw)
        .limit(1)
        .maybeSingle();

    if (response == null) return false;

    // 로그인 성공: 상태 저장
    final user = AppUser.fromJson(response);
    state = user;

    // 로그인 시간 갱신
    await supabase
        .from('users')
        .update({'last_login': DateTime.now().toUtc().toIso8601String()})
        .eq('email', email);

    return true;
  }

  void logout() {
    state = null;
  }
}
