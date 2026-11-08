import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_filters.dart';
import '../../models/app_user.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_controller.dart';
import '../../providers/incidents_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/user_avatar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _syncSearchField(String query) {
    if (_search.text == query) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _search.text != query) _search.text = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink();

    final incidents = context.watch<IncidentsController>();
    _syncSearchField(incidents.query);
    final visible = incidents.visible;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.isStaff ? 'All Reports' : 'My Reports',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              if (!user.isStaff) _ScopeToggle(incidents: incidents),
            ],
          ),
          const SizedBox(height: 16),
          if (user.isStaff)
            _StatsStrip(counts: incidents.summary)
          else
            _ProfileSummary(user: user, counts: incidents.myCounts),
          const SizedBox(height: 18),
          TextField(
            controller: _search,
            onChanged: incidents.setQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by title, place or category',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: incidents.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _search.clear();
                        incidents.setQuery('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterPill(
                  label: 'All',
                  selected: incidents.statusFilter == null,
                  onTap: () => incidents.setStatusFilter(null),
                ),
                for (final status in IncidentStatus.values)
                  FilterPill(
                    label: status.label,
                    selected: incidents.statusFilter == status,
                    onTap: () => incidents.setStatusFilter(
                        incidents.statusFilter == status ? null : status),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterPill(
                  label: 'Any category',
                  icon: Icons.tune_rounded,
                  selected: incidents.categoryFilter == null,
                  onTap: () => incidents.setCategoryFilter(null),
                ),
                for (final category in IncidentCategory.values)
                  FilterPill(
                    label: category.label,
                    icon: category.icon,
                    selected: incidents.categoryFilter == category,
                    onTap: () => incidents.setCategoryFilter(
                        incidents.categoryFilter == category ? null : category),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  visible.length == 1 ? '1 report' : '${visible.length} reports',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              if (incidents.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    _search.clear();
                    incidents.clearFilters();
                  },
                  child: const Text('Clear filters'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (incidents.error != null)
            ErrorBanner(message: incidents.error!)
          else if (incidents.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (visible.isEmpty)
            EmptyState(
              icon: incidents.hasActiveFilters
                  ? Icons.search_off_rounded
                  : Icons.inbox_outlined,
              title: incidents.hasActiveFilters
                  ? 'No matching reports'
                  : 'No reports here yet',
              message: incidents.hasActiveFilters
                  ? 'Try a different search or clear the filters.'
                  : incidents.scope == ReportScope.mine
                      ? 'Tap the + button to report your first issue.'
                      : 'Reports from across campus will appear here.',
            )
          else
            for (final incident in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IncidentCard(
                  incident: incident,
                  showReporter: incidents.scope == ReportScope.campus,
                ),
              ),
        ],
      ),
    );
  }
}

class _ScopeToggle extends StatelessWidget {
  const _ScopeToggle({required this.incidents});

  final IncidentsController incidents;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReportScope>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      segments: const [
        ButtonSegment(value: ReportScope.mine, label: Text('Mine')),
        ButtonSegment(value: ReportScope.campus, label: Text('Campus')),
      ],
      selected: {incidents.scope},
      onSelectionChanged: (selection) => incidents.setScope(selection.first),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.user, required this.counts});

  final AppUser user;
  final StatusCounts counts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(user: user, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        RoleBadge(role: user.role),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (user.department.isNotEmpty)
                      _MetaLine(icon: Icons.school_outlined, text: user.department),
                    if (user.campus.isNotEmpty)
                      _MetaLine(icon: Icons.place_outlined, text: user.campus),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatsStrip(counts: counts, compact: true),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.counts, this.compact = false});

  final StatusCounts counts;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cells = [
      (counts.total, 'Total Reports', AppColors.primary, AppColors.primarySoft),
      (counts.inProgress, 'In Progress', AppColors.info, AppColors.infoSoft),
      (counts.resolved, 'Resolved', AppColors.success, AppColors.successSoft),
    ];
    return Row(
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16),
              decoration: BoxDecoration(
                color: cells[i].$4,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    '${cells[i].$1}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cells[i].$3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cells[i].$2,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
