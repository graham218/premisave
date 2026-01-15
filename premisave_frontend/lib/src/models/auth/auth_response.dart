class AuthResponse {
  final String token;
  final String role;
  final String redirectUrl;

  AuthResponse({
    required this.token,
    required this.role,
    required this.redirectUrl,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      role: json['role'] ?? 'CLIENT',
      redirectUrl: json['redirectUrl'] ?? '/dashboard/client',
    );
  }
}