import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF6C47FF);
  static const primaryDark = Color(0xFF5134E0);
  static const primaryLight = Color(0xFF8E6CFF);
  static const primarySoft = Color(0xFFF1EEFF);

  static const background = Color(0xFFF7F7FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE7E7EF);

  static const textPrimary = Color(0xFF16161D);
  static const textSecondary = Color(0xFF6E6E80);
  static const textMuted = Color(0xFF9F9FB0);

  static const success = Color(0xFF2E9E5B);
  static const successSoft = Color(0xFFE6F6EC);
  static const warning = Color(0xFFC98A00);
  static const warningSoft = Color(0xFFFFF4D6);
  static const info = Color(0xFF2F80ED);
  static const infoSoft = Color(0xFFEAF3FF);
  static const danger = Color(0xFFE5484D);
  static const dangerSoft = Color(0xFFFFEEF0);

  static const heroGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
