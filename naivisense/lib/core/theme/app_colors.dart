import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBlue   = Color(0xFF4A90E2);
  static const Color mintGreen     = Color(0xFF4CD7A2);
  static const Color warmYellow    = Color(0xFFFFD56B);
  static const Color softCoral     = Color(0xFFFF7B7B);

  static const Color background    = Color(0xFFF8FAFC);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color card          = Color(0xFFF4F6F9);
  static const Color textPrimary   = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider       = Color(0xFFE5E7EB);

  static const Color success = mintGreen;
  static const Color warning = warmYellow;
  static const Color error   = softCoral;

  static const LinearGradient therapistGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF2C6FBF)],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );
  static const LinearGradient parentGradient = LinearGradient(
    colors: [Color(0xFF4CD7A2), Color(0xFF2AAD7E)],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );
  static const LinearGradient centerHeadGradient = LinearGradient(
    colors: [Color(0xFF9B59B6), Color(0xFF6C3483)],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );
}
