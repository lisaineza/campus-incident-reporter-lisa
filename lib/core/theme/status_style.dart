import 'package:flutter/material.dart';

import '../../models/incident_status.dart';
import 'app_colors.dart';

class StatusStyle {
  const StatusStyle(this.background, this.foreground, this.icon);

  final Color background;
  final Color foreground;
  final IconData icon;

  static StatusStyle of(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.submitted:
        return const StatusStyle(
          AppColors.warningSoft,
          AppColors.warning,
          Icons.mark_email_unread_outlined,
        );
      case IncidentStatus.inProgress:
        return const StatusStyle(
          AppColors.primarySoft,
          AppColors.primary,
          Icons.autorenew_rounded,
        );
      case IncidentStatus.resolved:
        return const StatusStyle(
          AppColors.successSoft,
          AppColors.success,
          Icons.check_circle_outline_rounded,
        );
    }
  }
}
