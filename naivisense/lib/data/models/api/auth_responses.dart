import '../user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
        accessToken:  (j['access_token'] ?? j['accessToken']) as String,
        refreshToken: (j['refresh_token'] ?? j['refreshToken']) as String,
        user:         UserModel.fromJson(j['user'] as Map<String, dynamic>),
      );
}
