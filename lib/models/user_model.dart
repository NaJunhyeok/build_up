class AppUser {
  final String email;
  final String name;
  final String phone;
  final String nickname;
  final DateTime lastLogin;

  AppUser({
    required this.email,
    required this.name,
    required this.phone,
    required this.nickname,
    required this.lastLogin,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      nickname: json['nickname'],
      lastLogin: DateTime.parse(json['last_login']),
    );
  }
}
