class LoginRequest {
  final String phone;
  final String password;

  const LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {'phone': phone, 'password': password};
}

class RegisterRequest {
  final String name;
  final String phone;
  final String password;
  final String role;
  final String? centerId;

  const RegisterRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
    this.centerId,
  });

  Map<String, dynamic> toJson() => {
        'name':      name,
        'phone':     phone,
        'password':  password,
        'role':      role,
        if (centerId != null) 'center_id': centerId,
      };
}
