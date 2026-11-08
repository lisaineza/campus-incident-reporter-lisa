import 'package:flutter/material.dart';

import '../core/theme/status_style.dart';
import '../models/incident_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final IncidentStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: style.foreground,
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11.5 : 13,
        ),
      ),
    );
  }
}
