import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_status.dart';

DateTime readDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  // A serverTimestamp that hasn't synced yet arrives as null.
  return DateTime.now();
}

class StatusUpdate {
  const StatusUpdate({
    required this.status,
    required this.at,
    required this.byName,
    this.note,
  });

  final IncidentStatus status;
  final DateTime at;
  final String byName;
  final String? note;

  bool get hasNote => note != null && note!.trim().isNotEmpty;

  factory StatusUpdate.fromMap(Map<String, dynamic> map) {
    return StatusUpdate(
      status: IncidentStatus.fromValue(map['status'] as String?),
      at: readDate(map['at']),
      byName: map['byName'] as String? ?? '',
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.value,
      'at': Timestamp.fromDate(at),
      'byName': byName,
      if (hasNote) 'note': note!.trim(),
    };
  }
}
