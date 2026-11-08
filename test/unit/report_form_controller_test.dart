import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/providers/report_form_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeIncidentRepository repository;
  late ReportFormController form;

  setUp(() {
    repository = FakeIncidentRepository();
    form = ReportFormController(
      repository: repository,
      storage: FakeStorageService(),
    );
  });

  test('refuses to submit without a category and location', () async {
    final ok = await form.submit(
      reporter: student,
      title: 'Broken chair',
      description: 'The chair in the library is broken.',
    );

    expect(ok, isFalse);
    expect(form.error, isNotNull);
    expect(repository.created, isEmpty);
  });

  test('creates a submitted report with a single timeline entry', () async {
    form.selectCategory(IncidentCategory.furniture);
    form.selectLocation('Library');

    final ok = await form.submit(
      reporter: student,
      title: '  Broken chair  ',
      description: 'The chair near the window has a cracked leg.',
      spot: 'Second floor',
    );

    expect(ok, isTrue);
    expect(form.isSubmitting, isFalse);

    final created = repository.created.single;
    expect(created.id, 'new-id');
    expect(created.title, 'Broken chair');
    expect(created.location, 'Library, Second floor');
    expect(created.status, IncidentStatus.submitted);
    expect(created.reporterId, student.uid);
    expect(created.timeline, hasLength(1));
    expect(created.hasPhoto, isFalse);
  });
}
