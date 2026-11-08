import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/auth_controller.dart';
import '../../providers/incidents_controller.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = context.read<AuthController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink();
    final counts = context.watch<IncidentsController>().myCounts;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Center(child: UserAvatar(user: user, size: 92)),
          const SizedBox(height: 14),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Center(child: RoleBadge(role: user.role)),
          const SizedBox(height: 26),
          _Card(
            children: [
              _InfoTile(
                icon: Icons.school_outlined,
                label: 'Department',
                value: user.department.isEmpty ? 'Not set' : user.department,
              ),
              const Divider(),
              _InfoTile(
                icon: Icons.place_outlined,
                label: 'Campus',
                value: user.campus.isEmpty ? 'Not set' : user.campus,
              ),
              const Divider(),
              _InfoTile(
                icon: Icons.description_outlined,
                label: 'Reports submitted',
                value: '${counts.total}  ·  ${counts.resolved} resolved',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Card(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What your account can do',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    for (final line in _permissionsFor(user))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.check_circle_rounded,
                                  size: 16, color: AppColors.success),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(line,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.35)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _permissionsFor(AppUser user) {
    if (user.isStaff) {
      return const [
        'View every report submitted on campus',
        'Move reports between Submitted, In Progress and Resolved',
        'Leave notes that students can see',
        'Remove duplicate or invalid reports',
      ];
    }
    return const [
      'Report issues with a photo, category and location',
      'Browse and search reports from across campus',
      'Follow the status of your reports in real time',
      'Withdraw a report before staff pick it up',
    ];
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
