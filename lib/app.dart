import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_controller.dart';
import 'providers/incidents_controller.dart';
import 'routes.dart';
import 'screens/auth/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/incident_repository.dart';
import 'services/storage_service.dart';

class CampusReporterApp extends StatelessWidget {
  const CampusReporterApp({
    super.key,
    this.authService,
    this.incidentRepository,
    this.storageService,
  });

  // Optional overrides so tests can run the app against fakes.
  final AuthService? authService;
  final IncidentRepository? incidentRepository;
  final StorageService? storageService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => authService ?? FirebaseAuthService(),
        ),
        Provider<IncidentRepository>(
          create: (_) => incidentRepository ?? FirestoreIncidentRepository(),
        ),
        Provider<StorageService>(
          create: (_) => storageService ?? CloudinaryStorageService(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(context.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider<AuthController, IncidentsController>(
          create: (context) => IncidentsController(
            context.read<IncidentRepository>(),
            context.read<StorageService>(),
          ),
          update: (_, auth, incidents) => incidents!..bindUser(auth.user),
        ),
      ],
      child: MaterialApp(
        title: 'Campus Reporter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
