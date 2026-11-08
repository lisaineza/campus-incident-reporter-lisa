import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/app_logo.dart';
import '../shell/home_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    switch (auth.status) {
      case SessionStatus.unknown:
        return const _LoadingView();
      case SessionStatus.signedOut:
        return const LoginScreen();
      case SessionStatus.signedIn:
        if (auth.user == null) {
          return _LoadingView(
            message: 'Setting up your account...',
            onSignOut: auth.signOut,
          );
        }
        return const HomeShell();
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({this.message, this.onSignOut});

  final String? message;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 72),
            const SizedBox(height: 28),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
            if (onSignOut != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onSignOut, child: const Text('Sign out')),
            ],
          ],
        ),
      ),
    );
  }
}
