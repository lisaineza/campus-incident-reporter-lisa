import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_format.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    const steps = IncidentStatus.values;
    final currentIndex = incident.status.index;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: _TimelineStep(
              status: steps[i],
              reached: i <= currentIndex,
              isCurrent: i == currentIndex,
              leftLine: i == 0 ? null : i <= currentIndex,
              rightLine: i == steps.length - 1 ? null : i + 1 <= currentIndex,
              date: incident.entryFor(steps[i])?.at,
            ),
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.reached,
    required this.isCurrent,
    required this.leftLine,
    required this.rightLine,
    required this.date,
  });

  final IncidentStatus status;
  final bool reached;
  final bool isCurrent;
  final bool? leftLine;
  final bool? rightLine;
  final DateTime? date;

  Widget _line(bool? active) {
    if (active == null) return const SizedBox.shrink();
    return Container(
      height: 2.5,
      color: active ? AppColors.primary : AppColors.border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inProgressNow = isCurrent && status != IncidentStatus.resolved &&
        status != IncidentStatus.submitted;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _line(leftLine)),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: reached ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                reached
                    ? (inProgressNow ? Icons.more_horiz_rounded : Icons.check_rounded)
                    : Icons.circle,
                size: reached ? 18 : 8,
                color: reached ? Colors.white : AppColors.border,
              ),
            ),
            Expanded(child: _line(rightLine)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          status.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: reached ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          date == null ? 'Pending' : shortDateTime(date!),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
