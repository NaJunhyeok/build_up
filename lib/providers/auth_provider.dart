import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final supabase = Supabase.instance.client;

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null) {
    _bindSupabaseAuthState();
    _bootstrapFromCurrentSession();
  }

  void _bindSupabaseAuthState() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (data.event == AuthChangeEvent.signedIn && session?.user != null) {
        await _loadProfile(session!.user.id);
      }
      if (data.event == AuthChangeEvent.signedOut) {
        state = null;
      }
    });
  }

  Future<void> _bootstrapFromCurrentSession() async {
    final user = supabase.auth.currentUser;
    if (user != null) await _loadProfile(user.id);
  }

  Future<void> _loadProfile(String uid) async {
    final row = await supabase
        .from('users')
        .select(
          'uid,email,name,nickname,last_login,profile_image,created_at,role',
        )
        .eq('uid', uid)
        .maybeSingle();
    state = row != null ? AppUser.fromJson(row) : null;
  }

  Future<bool> loginWithGoogle() async {
    final supabase = Supabase.instance.client;

    try {
      // 1) v7 초기화: 싱글턴 + initialize
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(
        // clientId: dotenv.maybeGet('google_ios_client_id'),
        serverClientId: dotenv.get('google_web_client_id'),
      ); // v7 문서의 initialize/instance 사용. :contentReference[oaicite:4]{index=4}

      // 2) 조용한 로그인 시도 → 실패 시 대화형 로그인(authenticate)
      GoogleSignInAccount? account = await signIn
          .attemptLightweightAuthentication(); // optional silent auth :contentReference[oaicite:5]{index=5}
      account ??= (signIn.supportsAuthenticate()
          ? await signIn
                .authenticate() // 대화형 로그인 시작 :contentReference[oaicite:6]{index=6}
          : null);

      // (웹은 google_sign_in의 authenticate가 불가하니 Supabase OAuth로 처리)
      if (account == null) {
        if (kIsWeb) {
          await supabase.auth.signInWithOAuth(OAuthProvider.google);
          return supabase.auth.currentUser != null;
        }
        return false;
      }

      // 3) v7 토큰: authentication.idToken 만 제공
      final idToken = account
          .authentication
          .idToken; // sync property, not Future :contentReference[oaicite:7]{index=7}
      if (idToken == null) return false;

      // (참고) 특정 Google API를 쓰려면 필요 시 액세스 토큰 발급
      // final authz = await account.authorizationClient
      //     .authorizationForScopes(['email']); // accessToken 제공 :contentReference[oaicite:8]{index=8}
      // final accessToken = authz?.accessToken;

      // 4) Supabase에 idToken 전달 (accessToken 없어도 동작)
      final res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        // accessToken: accessToken, // 선택
      );
      final spUser = res.user;
      if (spUser == null) return false;

      final googleName =
          account.displayName ?? spUser.userMetadata?['full_name'];

      // 5) users 테이블 upsert/갱신
      final nowIso = DateTime.now().toIso8601String();
      await _loadProfile(spUser.id);
      return true;
    } catch (e) {
      print('Google 로그인 에러: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      // 로그아웃 에러는 크게 치명적이지 않으므로 로깅만
      print('Supabase 로그아웃 에러: $e');
    }
    // 상태 초기화
    state = null;
  }

  void setUser(AppUser user) => state = user;
}
