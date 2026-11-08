import 'package:campus_incident_reporter/core/utils/incident_filters.dart';
import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  final incidents = [
    buildIncident(id: '1'),
    buildIncident(
      id: '2',
      title: 'Broken classroom projector',
      description: 'The projector in room 204 does not turn on.',
      category: IncidentCategory.electricity,
      status: IncidentStatus.inProgress,
      location: 'Block B, Room 204',
    ),
    buildIncident(
      id: '3',
      title: 'Overflowing bin',
      description: 'Bins near the serving area have not been emptied.',
      category: IncidentCategory.sanitation,
      status: IncidentStatus.resolved,
      location: 'Cafeteria',
    ),
  ];

  List<String> ids(Iterable<dynamic> items) =>
      items.map((i) => i.id as String).toList();

  test('returns everything when no filter is set', () {
    expect(ids(filterIncidents(incidents)), ['1', '2', '3']);
  });

  test('search matches title, description, location and category', () {
    expect(ids(filterIncidents(incidents, query: 'PROJECTOR')), ['2']);
    expect(ids(filterIncidents(incidents, query: 'serving area')), ['3']);
    expect(ids(filterIncidents(incidents, query: 'block b')), ['2']);
    expect(ids(filterIncidents(incidents, query: 'sanitation')), ['3']);
    expect(filterIncidents(incidents, query: 'library'), isEmpty);
  });

  test('status and category filters combine with search', () {
    expect(ids(filterIncidents(incidents, status: IncidentStatus.resolved)), ['3']);
    expect(
      ids(filterIncidents(incidents, category: IncidentCategory.water)),
      ['1'],
    );
    expect(
      filterIncidents(
        incidents,
        query: 'projector',
        status: IncidentStatus.resolved,
      ),
      isEmpty,
    );
  });

  test('StatusCounts tallies each status', () {
    final counts = StatusCounts.from(incidents);
    expect(counts.total, 3);
    expect(counts.submitted, 1);
    expect(counts.inProgress, 1);
    expect(counts.resolved, 1);
  });
}
