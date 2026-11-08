import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/incident_status.dart';
import '../../providers/incidents_controller.dart';
import '../../routes.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/reports_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _openReports({IncidentStatus? status}) {
    final incidents = context.read<IncidentsController>();
    incidents.clearFilters();
    if (status != null) incidents.setStatusFilter(status);
    setState(() => _index = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSeeAll: () => _openReports(),
            onOpenStatus: (status) => _openReports(status: status),
          ),
          const ReportsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onSelect: (i) => setState(() => _index = i),
        onReport: () => Navigator.of(context).pushNamed(AppRoutes.report),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.onSelect,
    required this.onReport,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _NavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                active: index == 0,
                onTap: () => onSelect(0),
              ),
              _NavItem(
                label: 'Reports',
                icon: Icons.description_outlined,
                activeIcon: Icons.description_rounded,
                active: index == 1,
                onTap: () => onSelect(1),
              ),
              Expanded(child: _ReportButton(onTap: onReport)),
              _NavItem(
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                active: index == 2,
                onTap: () => onSelect(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Report an issue',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 2),
            const Text(
              'Report',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
