import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_style.dart';
import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_controller.dart';
import '../../providers/incidents_controller.dart';
import '../../widgets/primary_button.dart';

/// Only rendered for staff accounts. The Firestore rules enforce the same
/// restriction on the server, so hiding this is a UX choice, not the guard.
class StatusUpdatePanel extends StatefulWidget {
  const StatusUpdatePanel({super.key, required this.incident});

  final Incident incident;

  @override
  State<StatusUpdatePanel> createState() => _StatusUpdatePanelState();
}

class _StatusUpdatePanelState extends State<StatusUpdatePanel> {
  final _note = TextEditingController();
  IncidentStatus? _selected;

  @override
  void didUpdateWidget(covariant StatusUpdatePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incident.status != widget.incident.status) {
      _selected = null;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final target = _selected;
    final user = context.read<AuthController>().user;
    if (target == null || user == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<IncidentsController>().updateStatus(
          widget.incident,
          target,
          byName: user.name,
          note: _note.text,
        );
    if (!mounted) return;

    if (error == null) {
      _note.clear();
      setState(() => _selected = null);
      messenger.showSnackBar(
        SnackBar(content: Text('Status updated to ${target.label}.')),
      );
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<IncidentsController>().isBusy(widget.incident.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Staff actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Move this report forward. Your note is shown to the student.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in IncidentStatus.values)
                ChoiceChip(
                  label: Text(status.label),
                  avatar: Icon(
                    StatusStyle.of(status).icon,
                    size: 16,
                    color: _selected == status
                        ? Colors.white
                        : StatusStyle.of(status).foreground,
                  ),
                  showCheckmark: false,
                  selected: _selected == status,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _selected == status ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: status == widget.incident.status || busy
                      ? null
                      : (_) => setState(() => _selected = status),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _note,
            enabled: !busy,
            minLines: 2,
            maxLines: 4,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Add a note, e.g. "Plumber scheduled for 2 PM today"',
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: _selected == null
                ? 'Choose a new status'
                : 'Mark as ${_selected!.label}',
            icon: Icons.check_rounded,
            loading: busy,
            onPressed: _selected == null ? null : _submit,
          ),
        ],
      ),
    );
  }
}
