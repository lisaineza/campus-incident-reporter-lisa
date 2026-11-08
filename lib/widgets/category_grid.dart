import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/incident_category.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final IncidentCategory? selected;
  final ValueChanged<IncidentCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        for (final category in IncidentCategory.values)
          _CategoryTile(
            category: category,
            selected: category == selected,
            onTap: () => onSelected(category),
          ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final IncidentCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                color: selected ? Colors.white : AppColors.primary,
              ),
              const SizedBox(height: 6),
              Text(
                category.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
