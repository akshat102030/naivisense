class Validators {
  Validators._();

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) return 'Enter a valid 10-digit Indian mobile number';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? v, [String label = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? age(String? v) {
    if (v == null || v.isEmpty) return 'Age is required';
    final n = int.tryParse(v);
    if (n == null || n < 1 || n > 18) return 'Enter a valid age (1–18)';
    return null;
  }
}
