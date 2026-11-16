/// The account behind the current access token.
class AuthUser {
  const AuthUser({required this.userEmail});

  final String userEmail;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      AuthUser(userEmail: (json['userEmail'] as String?) ?? '');
}
