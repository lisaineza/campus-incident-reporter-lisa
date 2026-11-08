enum IncidentStatus {
  submitted('submitted', 'Submitted'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  const IncidentStatus(this.value, this.label);

  final String value;
  final String label;

  static IncidentStatus fromValue(String? value) {
    return IncidentStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => IncidentStatus.submitted,
    );
  }
}
