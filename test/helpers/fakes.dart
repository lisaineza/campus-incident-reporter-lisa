import 'dart:async';
import 'dart:io';

import 'package:campus_incident_reporter/models/app_user.dart';
import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/models/status_update.dart';
import 'package:campus_incident_reporter/services/auth_service.dart';
import 'package:campus_incident_reporter/services/incident_repository.dart';
import 'package:campus_incident_reporter/services/storage_service.dart';

const student = AppUser(
  uid: 'student-1',
  name: 'Amina Hassan',
  email: 'amina@alustudent.com',
  role: UserRole.student,
  department: 'Computer Science',
  campus: 'Kigali, Rwanda',
);

const staffMember = AppUser(
  uid: 'staff-1',
  name: 'Jean Mugisha',
  email: 'jean@alu.edu',
  role: UserRole.staff,
);

Incident buildIncident({
  String id = 'inc-1',
  String title = 'Water shortage',
  String description = 'No water supply on the second floor since morning.',
  IncidentCategory category = IncidentCategory.water,
  IncidentStatus status = IncidentStatus.submitted,
  String location = 'Student Residence',
  String reporterId = 'student-1',
  DateTime? createdAt,
}) {
  final created = createdAt ?? DateTime(2026, 10, 15, 10, 24);
  return Incident(
    id: id,
    title: title,
    description: description,
    category: category,
    status: status,
    location: location,
    reporterId: reporterId,
    reporterName: 'Amina Hassan',
    createdAt: created,
    updatedAt: created,
    timeline: [
      StatusUpdate(
        status: IncidentStatus.submitted,
        at: created,
        byName: 'Amina Hassan',
      ),
    ],
  );
}

class FakeAuthService implements AuthService {
  final uidController = StreamController<String?>.broadcast();
  final profileController = StreamController<AppUser?>.broadcast();

  int signInCalls = 0;
  AuthFailure? nextFailure;

  @override
  Stream<String?> uidChanges() => uidController.stream;

  @override
  Stream<AppUser?> watchProfile(String uid) => profileController.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    final failure = nextFailure;
    if (failure != null) throw failure;
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async => uidController.add(null);
}

class StatusUpdateCall {
  StatusUpdateCall(this.id, this.status, this.note);

  final String id;
  final IncidentStatus status;
  final String? note;
}

class FakeIncidentRepository implements IncidentRepository {
  final allController = StreamController<List<Incident>>.broadcast();
  final mineController = StreamController<List<Incident>>.broadcast();

  String? watchedReporter;
  final List<StatusUpdateCall> statusCalls = [];
  final List<String> deleted = [];
  final List<Incident> created = [];

  @override
  Stream<List<Incident>> watchAll() => allController.stream;

  @override
  Stream<List<Incident>> watchByReporter(String uid) {
    watchedReporter = uid;
    return mineController.stream;
  }

  @override
  Stream<Incident?> watchOne(String id) => const Stream.empty();

  @override
  String newId() => 'new-id';

  @override
  Future<void> create(Incident incident) async => created.add(incident);

  @override
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String byName,
    String? note,
  }) async {
    statusCalls.add(StatusUpdateCall(id, status, note));
  }

  @override
  Future<void> delete(String id) async => deleted.add(id);
}

class FakeStorageService implements StorageService {
  final List<String> deletedPaths = [];

  @override
  Future<UploadedPhoto> uploadIncidentPhoto({
    required String uid,
    required String incidentId,
    required File file,
  }) async {
    return UploadedPhoto(
      url: 'https://example.com/$incidentId.jpg',
      path: 'incidents/$uid/$incidentId.jpg',
    );
  }

  @override
  Future<void> deleteByPath(String path) async => deletedPaths.add(path);
}
