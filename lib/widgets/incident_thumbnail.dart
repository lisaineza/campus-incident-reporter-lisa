import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/incident.dart';

class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({super.key, required this.incident, this.size = 76});

  final Incident incident;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      color: AppColors.primarySoft,
      child: Icon(
        incident.category.icon,
        color: AppColors.primary,
        size: size * 0.42,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: incident.hasPhoto
          ? Image.network(
              incident.imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  color: AppColors.primarySoft,
                );
              },
            )
          : fallback,
    );
  }
}
