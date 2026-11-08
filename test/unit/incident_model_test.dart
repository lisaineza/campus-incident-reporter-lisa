import 'package:campus_incident_reporter/models/app_user.dart';
import 'package:campus_incident_reporter/models/incident.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/models/status_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('Incident', () {
    test('survives a round trip through a Firestore map', () {
      final original = buildIncident(status: IncidentStatus.inProgress);
      final map = original.toMap();

      expect(map['status'], 'in_progress');
      expect(map['category'], 'water');
      expect(map['createdAt'], isA<Timestamp>());

      final restored = Incident.fromMap(original.id, map);
      expect(restored.title, original.title);
      expect(restored.status, IncidentStatus.inProgress);
      expect(restored.category, IncidentCategory.water);
      expect(restored.createdAt, original.createdAt);
      expect(restored.timeline, hasLength(1));
    });

    test('tolerates missing and unknown fields', () {
      final incident = Incident.fromMap('x', {
        'title': 'Something',
        'status': 'archived',
        'category': 'unknown',
        'createdAt': null,
      });

      expect(incident.status, IncidentStatus.submitted);
      expect(incident.category, IncidentCategory.facilities);
      expect(incident.reporterName, 'Unknown');
      expect(incident.timeline, isEmpty);
      expect(incident.hasPhoto, isFalse);
    });

    test('entryFor returns the latest entry for a status', () {
      final base = buildIncident();
      final first = DateTime(2026, 10, 16, 9);
      final second = DateTime(2026, 10, 16, 14, 30);
      final incident = Incident.fromMap(base.id, {
        ...base.toMap(),
        'timeline': [
          ...base.timeline.map((e) => e.toMap()),
          StatusUpdate(status: IncidentStatus.inProgress, at: first, byName: 'A').toMap(),
          StatusUpdate(status: IncidentStatus.inProgress, at: second, byName: 'B').toMap(),
        ],
      });

      expect(incident.entryFor(IncidentStatus.inProgress)?.at, second);
      expect(incident.entryFor(IncidentStatus.resolved), isNull);
    });
  });

  test('StatusUpdate only writes a note when there is one', () {
    final withoutNote = StatusUpdate(
      status: IncidentStatus.resolved,
      at: DateTime(2026, 10, 17),
      byName: 'Staff',
      note: '   ',
    ).toMap();
    expect(withoutNote.containsKey('note'), isFalse);
  });

  group('AppUser', () {
    test('derives initials and first name', () {
      expect(student.initials, 'AH');
      expect(student.firstName, 'Amina');
      expect(
        const AppUser(uid: '1', name: 'Lisa', email: '', role: UserRole.student).initials,
        'L',
      );
    });

    test('defaults unknown roles to student', () {
      final user = AppUser.fromMap('1', {'name': 'X', 'role': 'admin'});
      expect(user.role, UserRole.student);
      expect(user.isStaff, isFalse);
    });
  });
}
