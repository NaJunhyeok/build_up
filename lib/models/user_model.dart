class AppUser {
  final String uid;
  final String? email;
  final String? name;
  final String? nickname;
  final String? profileImage;
  final DateTime? created;
  final DateTime? lastLogin;
  final String? role;
  final bool isGuest;

  bool get isAdmin => role == 'admin';

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.nickname,
    required this.profileImage,
    required this.created,
    required this.lastLogin,
    required this.role,
    this.isGuest = false,
  });

  factory AppUser.guest() => AppUser(
    uid: 'guest',
    name: '게스트',
    nickname: null,
    email: '',
    profileImage: '',
    created: null,
    lastLogin: null,
    role: '',
    isGuest: true,
  );

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final uid = json['uid'];
    if (uid == null) throw StateError('users.uid is null');

    DateTime? lastLogin;
    final raw = json['last_login'];
    if (raw is String && raw.isNotEmpty) {
      lastLogin = DateTime.tryParse(raw);
    }
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      nickname: json['nickname'],
      profileImage: json['profile_image'],
      created: DateTime.parse(json['created_at']),
      lastLogin: DateTime.parse(json['last_login']),
      role: json['role'],
      isGuest: false,
    );
  }
}
