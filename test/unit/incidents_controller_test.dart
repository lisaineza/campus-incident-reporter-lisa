import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/providers/incidents_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeIncidentRepository repository;
  late FakeStorageService storage;
  late IncidentsController controller;

  setUp(() {
    repository = FakeIncidentRepository();
    storage = FakeStorageService();
    controller = IncidentsController(repository, storage);
  });

  tearDown(() => controller.dispose());

  test('students start on their own reports', () async {
    controller.bindUser(student);
    expect(repository.watchedReporter, student.uid);
    expect(controller.scope, ReportScope.mine);
    expect(controller.isLoading, isTrue);

    final mine = buildIncident(id: 'mine');
    repository.mineController.add([mine]);
    repository.allController.add([mine, buildIncident(id: 'other', reporterId: 'x')]);
    await flush();

    expect(controller.isLoading, isFalse);
    expect(controller.visible.map((i) => i.id), ['mine']);
    expect(controller.summary.total, 1);

    controller.setScope(ReportScope.campus);
    expect(controller.visible, hasLength(2));
  });

  test('staff dashboards summarise the whole campus', () async {
    controller.bindUser(staffMember);
    expect(controller.scope, ReportScope.campus);

    repository.allController.add([
      buildIncident(id: '1'),
      buildIncident(id: '2', status: IncidentStatus.resolved),
    ]);
    repository.mineController.add([]);
    await flush();

    expect(controller.summary.total, 2);
    expect(controller.summary.resolved, 1);
  });

  test('filters narrow the visible list and can be cleared', () async {
    controller.bindUser(staffMember);
    repository.allController.add([
      buildIncident(id: '1'),
      buildIncident(id: '2', status: IncidentStatus.resolved),
    ]);
    await flush();

    controller.setStatusFilter(IncidentStatus.resolved);
    expect(controller.visible.map((i) => i.id), ['2']);
    expect(controller.hasActiveFilters, isTrue);

    controller.clearFilters();
    expect(controller.visible, hasLength(2));
    expect(controller.hasActiveFilters, isFalse);
  });

  test('students cannot change a status', () async {
    controller.bindUser(student);
    final error = await controller.updateStatus(
      buildIncident(),
      IncidentStatus.resolved,
      byName: student.name,
    );

    expect(error, isNotNull);
    expect(repository.statusCalls, isEmpty);
  });

  test('staff status changes reach the repository', () async {
    controller.bindUser(staffMember);
    final error = await controller.updateStatus(
      buildIncident(),
      IncidentStatus.inProgress,
      byName: staffMember.name,
      note: 'Plumber on the way',
    );

    expect(error, isNull);
    expect(repository.statusCalls.single.status, IncidentStatus.inProgress);
    expect(repository.statusCalls.single.note, 'Plumber on the way');
    expect(controller.isBusy('inc-1'), isFalse);
  });

  test('students can only withdraw their own untouched reports', () async {
    controller.bindUser(student);

    expect(controller.canDelete(buildIncident()), isTrue);
    expect(
      controller.canDelete(buildIncident(status: IncidentStatus.inProgress)),
      isFalse,
    );
    expect(controller.canDelete(buildIncident(reporterId: 'someone-else')), isFalse);

    expect(await controller.deleteIncident(buildIncident()), isNull);
    expect(repository.deleted, ['inc-1']);
  });

  test('signing out clears data', () async {
    controller.bindUser(student);
    repository.mineController.add([buildIncident()]);
    await flush();
    expect(controller.mine, isNotEmpty);

    controller.bindUser(null);
    expect(controller.mine, isEmpty);
    expect(controller.all, isEmpty);
  });
}
