import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/app_user.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final staff = role == UserRole.staff;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: staff ? AppColors.successSoft : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          color: staff ? AppColors.success : AppColors.primary,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
