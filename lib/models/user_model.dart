class AppUser {
  final String uid;
  final String email;
  final String name;
  final String nickname;
  final String profileImage;
  final DateTime created;
  final DateTime lastLogin;
  final String role;

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
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      nickname: json['nickname'],
      profileImage: json['profile_image'],
      created: DateTime.parse(json['created_at']),
      lastLogin: DateTime.parse(json['last_login']),
      role: json['role'],
    );
  }
}
