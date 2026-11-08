import 'package:flutter/material.dart';

enum IncidentCategory {
  facilities('facilities', 'Facilities', Icons.apartment_rounded),
  water('water', 'Water', Icons.water_drop_outlined),
  electricity('electricity', 'Electricity', Icons.bolt_rounded),
  safety('safety', 'Safety', Icons.shield_outlined),
  sanitation('sanitation', 'Sanitation', Icons.delete_outline_rounded),
  furniture('furniture', 'Furniture', Icons.chair_outlined);

  const IncidentCategory(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static IncidentCategory fromValue(String? value) {
    return IncidentCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => IncidentCategory.facilities,
    );
  }
}
