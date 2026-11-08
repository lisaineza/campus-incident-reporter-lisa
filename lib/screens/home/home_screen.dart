import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_controller.dart';
import '../../providers/incidents_controller.dart';
import '../../routes.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/summary_stat_card.dart';
import '../../widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onSeeAll,
    required this.onOpenStatus,
  });

  final VoidCallback onSeeAll;
  final ValueChanged<IncidentStatus> onOpenStatus;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink();

    final incidents = context.watch<IncidentsController>();
    final counts = incidents.summary;
    final recent = incidents.recent;

    final hasFreshUpdates = user.isStaff
        ? counts.submitted > 0
        : incidents.mine.any((i) =>
            i.status != IncidentStatus.submitted &&
            DateTime.now().difference(i.updatedAt).inDays < 3);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _Greeting(user: user, hasUpdates: hasFreshUpdates),
          const SizedBox(height: 22),
          if (user.isStaff)
            _StaffHero(
              pending: counts.submitted,
              onTap: () => onOpenStatus(IncidentStatus.submitted),
            )
          else
            _ReportHero(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.report),
            ),
          const SizedBox(height: 28),
          SectionHeader(
            title: user.isStaff ? 'Campus Summary' : 'Report Summary',
            actionLabel: 'See all',
            onAction: onSeeAll,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SummaryStatCard(
                  value: counts.total,
                  label: user.isStaff ? 'All Reports' : 'My Reports',
                  icon: Icons.description_rounded,
                  color: AppColors.primary,
                  background: AppColors.primarySoft,
                  onTap: onSeeAll,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryStatCard(
                  value: counts.inProgress,
                  label: 'In Progress',
                  icon: Icons.schedule_rounded,
                  color: AppColors.info,
                  background: AppColors.infoSoft,
                  onTap: () => onOpenStatus(IncidentStatus.inProgress),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryStatCard(
                  value: counts.resolved,
                  label: 'Resolved',
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  background: AppColors.successSoft,
                  onTap: () => onOpenStatus(IncidentStatus.resolved),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SummaryStatCard(
                  value: counts.submitted,
                  label: 'Submitted',
                  icon: Icons.priority_high_rounded,
                  color: AppColors.danger,
                  background: AppColors.dangerSoft,
                  onTap: () => onOpenStatus(IncidentStatus.submitted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: user.isStaff ? 'Latest Reports' : 'Recent Reports',
            actionLabel: 'See all',
            onAction: onSeeAll,
          ),
          const SizedBox(height: 12),
          if (incidents.error != null)
            ErrorBanner(message: incidents.error!)
          else if (incidents.dashboardLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recent.isEmpty)
            EmptyState(
              icon: Icons.inbox_outlined,
              title: user.isStaff ? 'No reports yet' : 'Nothing reported yet',
              message: user.isStaff
                  ? 'New reports from students will show up here.'
                  : 'When you report an issue, you can follow its progress here.',
            )
          else
            for (final incident in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IncidentCard(
                  incident: incident,
                  showReporter: user.isStaff,
                ),
              ),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user, required this.hasUpdates});

  final AppUser user;
  final bool hasUpdates;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hello, ${user.firstName} \u{1F44B}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
              ),
            ),
            Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Updates',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.updates),
                icon: Badge(
                  isLabelVisible: hasUpdates,
                  smallSize: 9,
                  backgroundColor: AppColors.danger,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
              ),
            ),
            const SizedBox(width: 10),
            UserAvatar(user: user, size: 50),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          user.isStaff ? 'Keep the campus running.' : 'Help make our campus safer.',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          user.isStaff
              ? 'Review new reports and keep students in the loop.'
              : 'Report issues and track their resolution.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.illustration,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;
  final IconData illustration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: 6,
            child: Icon(
              illustration,
              size: 132,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 70),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 14.5,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child:
                                Icon(buttonIcon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              buttonLabel,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.5,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HeroCard(
      title: 'See an issue\non campus?',
      subtitle: 'Report it and help improve our learning environment.',
      buttonLabel: 'Report an Issue',
      buttonIcon: Icons.add_rounded,
      illustration: Icons.account_balance_rounded,
      onTap: onTap,
    );
  }
}

class _StaffHero extends StatelessWidget {
  const _StaffHero({required this.pending, required this.onTap});

  final int pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = switch (pending) {
      0 => 'All caught up',
      1 => '1 report is\nwaiting for review',
      _ => '$pending reports are\nwaiting for review',
    };
    return _HeroCard(
      title: title,
      subtitle: pending == 0
          ? 'No new submissions right now. Check back soon.'
          : 'Pick them up so students know their issue is being handled.',
      buttonLabel: 'Open review queue',
      buttonIcon: Icons.fact_check_outlined,
      illustration: Icons.engineering_rounded,
      onTap: onTap,
    );
  }
}
