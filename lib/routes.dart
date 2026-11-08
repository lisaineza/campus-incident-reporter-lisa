import 'package:flutter/material.dart';

import 'screens/auth/register_screen.dart';
import 'screens/details/incident_details_screen.dart';
import 'screens/report/report_incident_screen.dart';
import 'screens/updates/updates_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const register = '/register';
  static const report = '/report';
  static const incident = '/incident';
  static const updates = '/updates';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case report:
        return MaterialPageRoute(
          builder: (_) => const ReportIncidentScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case incident:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => IncidentDetailsScreen(incidentId: id),
          settings: settings,
        );
      case updates:
        return MaterialPageRoute(
          builder: (_) => const UpdatesScreen(),
          settings: settings,
        );
    }
    return null;
  }
}
