import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_style.dart';
import '../../core/utils/date_format.dart';
import '../../models/incident.dart';
import '../../providers/auth_controller.dart';
import '../../providers/incidents_controller.dart';
import '../../services/incident_repository.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_thumbnail.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import 'photo_viewer_screen.dart';
import 'status_update_panel.dart';

class IncidentDetailsScreen extends StatefulWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  late final Stream<Incident?> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<IncidentRepository>().watchOne(widget.incidentId);
  }

  Future<void> _confirmDelete(Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text(
            'The report and its photo will be removed. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error =
        await context.read<IncidentsController>().deleteIncident(incident);
    if (!mounted) return;
    if (error == null) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted.')));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final incidents = context.watch<IncidentsController>();

    return StreamBuilder<Incident?>(
      stream: _stream,
      builder: (context, snapshot) {
        final incident = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Incident Details'),
            actions: [
              if (incident != null && incidents.canDelete(incident))
                PopupMenuButton<String>(
                  onSelected: (_) => unawaited(_confirmDelete(incident)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        user?.isStaff == true ? 'Delete report' : 'Withdraw report',
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(snapshot, incident, isStaff: user?.isStaff ?? false),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<Incident?> snapshot,
    Incident? incident, {
    required bool isStaff,
  }) {
    if (snapshot.hasError) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load this report',
          message: 'Check your connection and try again.',
        ),
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting && incident == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (incident == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Report not found',
          message: 'It may have been withdrawn or removed.',
        ),
      );
    }

    final staffNotes =
        incident.timeline.where((entry) => entry.hasNote).toList().reversed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _OverviewCard(incident: incident),
        const SizedBox(height: 24),
        const _SectionTitle('Status Timeline'),
        const SizedBox(height: 14),
        StatusTimeline(incident: incident),
        const SizedBox(height: 26),
        const _SectionTitle('Description'),
        const SizedBox(height: 8),
        Text(
          incident.description,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 20),
        _DetailRow(
          icon: incident.category.icon,
          label: 'Category',
          value: incident.category.label,
        ),
        _DetailRow(
          icon: Icons.place_outlined,
          label: 'Location',
          value: incident.location,
        ),
        _DetailRow(
          icon: Icons.update_rounded,
          label: 'Last updated',
          value: timeAgo(incident.updatedAt),
        ),
        if (incident.hasPhoto) ...[
          const SizedBox(height: 22),
          const _SectionTitle('Attached Photo'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PhotoViewerScreen(url: incident.imageUrl!),
            )),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                incident.imageUrl!,
                height: 210,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: AppColors.primarySoft,
                  alignment: Alignment.center,
                  child: const Text('Photo unavailable'),
                ),
              ),
            ),
          ),
        ],
        if (staffNotes.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionTitle('Updates from staff'),
          const SizedBox(height: 10),
          for (final entry in staffNotes)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  left: BorderSide(
                    color: StatusStyle.of(entry.status).foreground,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.note!, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 6),
                  Text(
                    '${entry.byName} · ${entry.status.label} · ${timeAgo(entry.at)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
        if (isStaff) ...[
          const SizedBox(height: 24),
          StatusUpdatePanel(incident: incident),
        ],
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IncidentThumbnail(incident: incident, size: 84),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.location,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    StatusChip(status: incident.status, compact: true),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _MetaLine(
            icon: Icons.calendar_today_outlined,
            text: 'Submitted on ${fullDateTime(incident.createdAt)}',
          ),
          const SizedBox(height: 6),
          _MetaLine(
            icon: Icons.person_outline_rounded,
            text: 'Reported by ${incident.reporterName}',
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
