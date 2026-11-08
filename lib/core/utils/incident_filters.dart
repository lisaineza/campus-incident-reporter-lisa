import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';

List<Incident> filterIncidents(
  Iterable<Incident> source, {
  String query = '',
  IncidentStatus? status,
  IncidentCategory? category,
}) {
  final q = query.trim().toLowerCase();
  return source.where((incident) {
    if (status != null && incident.status != status) return false;
    if (category != null && incident.category != category) return false;
    if (q.isEmpty) return true;
    return incident.title.toLowerCase().contains(q) ||
        incident.description.toLowerCase().contains(q) ||
        incident.location.toLowerCase().contains(q) ||
        incident.category.label.toLowerCase().contains(q);
  }).toList();
}

class StatusCounts {
  const StatusCounts({
    this.total = 0,
    this.submitted = 0,
    this.inProgress = 0,
    this.resolved = 0,
  });

  final int total;
  final int submitted;
  final int inProgress;
  final int resolved;

  factory StatusCounts.from(Iterable<Incident> incidents) {
    var submitted = 0, inProgress = 0, resolved = 0;
    for (final i in incidents) {
      switch (i.status) {
        case IncidentStatus.submitted:
          submitted++;
        case IncidentStatus.inProgress:
          inProgress++;
        case IncidentStatus.resolved:
          resolved++;
      }
    }
    return StatusCounts(
      total: submitted + inProgress + resolved,
      submitted: submitted,
      inProgress: inProgress,
      resolved: resolved,
    );
  }
}
