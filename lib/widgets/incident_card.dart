import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_format.dart';
import '../models/incident.dart';
import '../routes.dart';
import 'incident_thumbnail.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, this.showReporter = false});

  final Incident incident;
  final bool showReporter;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.incident, arguments: incident.id),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              IncidentThumbnail(incident: incident),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showReporter
                          ? '${incident.location} · ${incident.reporterName}'
                          : incident.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            timeAgo(incident.createdAt),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(status: incident.status, compact: true),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
