import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_style.dart';
import '../../core/utils/date_format.dart';
import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../models/status_update.dart';
import '../../providers/auth_controller.dart';
import '../../providers/incidents_controller.dart';
import '../../routes.dart';
import '../../widgets/empty_state.dart';

class _FeedItem {
  const _FeedItem(this.incident, this.entry, this.headline);

  final Incident incident;
  final StatusUpdate entry;
  final String headline;
}

/// Students see status changes on their own reports. Staff see the newest
/// submissions that still need someone to pick them up.
class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  List<_FeedItem> _buildFeed(bool isStaff, IncidentsController incidents) {
    final items = <_FeedItem>[];
    if (isStaff) {
      for (final incident in incidents.all) {
        if (incident.status != IncidentStatus.submitted) continue;
        final entry = incident.entryFor(IncidentStatus.submitted) ??
            StatusUpdate(
              status: IncidentStatus.submitted,
              at: incident.createdAt,
              byName: incident.reporterName,
            );
        items.add(_FeedItem(incident, entry, 'New report: ${incident.title}'));
      }
    } else {
      for (final incident in incidents.mine) {
        for (final entry in incident.timeline) {
          if (entry.status == IncidentStatus.submitted) continue;
          items.add(_FeedItem(
            incident,
            entry,
            '${incident.title} is now ${entry.status.label}',
          ));
        }
      }
    }
    items.sort((a, b) => b.entry.at.compareTo(a.entry.at));
    return items.take(30).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthController>().isStaff;
    final feed = _buildFeed(isStaff, context.watch<IncidentsController>());

    return Scaffold(
      appBar: AppBar(title: Text(isStaff ? 'Needs attention' : 'Updates')),
      body: feed.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topCenter,
                child: EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: isStaff ? 'Queue is clear' : 'No updates yet',
                  message: isStaff
                      ? 'There are no new reports waiting for review.'
                      : 'You will see changes here when staff work on your reports.',
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: feed.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = feed[index];
                final style = StatusStyle.of(item.entry.status);
                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: style.background,
                      child: Icon(style.icon, color: style.foreground, size: 20),
                    ),
                    title: Text(
                      item.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      item.entry.hasNote
                          ? '${item.entry.note}\n${timeAgo(item.entry.at)}'
                          : '${item.incident.location} · ${timeAgo(item.entry.at)}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.incident,
                      arguments: item.incident.id,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
