import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_category.dart';
import 'incident_status.dart';
import 'status_update.dart';

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.imagePath,
    this.staffNote,
    this.timeline = const [],
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final IncidentStatus status;
  final String location;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? imagePath;
  final String? staffNote;
  final List<StatusUpdate> timeline;

  bool get hasPhoto => imageUrl != null && imageUrl!.isNotEmpty;

  /// The most recent timeline entry for [target], if the incident ever reached it.
  StatusUpdate? entryFor(IncidentStatus target) {
    for (final entry in timeline.reversed) {
      if (entry.status == target) return entry;
    }
    return null;
  }

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    final rawTimeline = data['timeline'];
    return Incident(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: IncidentCategory.fromValue(data['category'] as String?),
      status: IncidentStatus.fromValue(data['status'] as String?),
      location: data['location'] as String? ?? '',
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? 'Unknown',
      imageUrl: data['imageUrl'] as String?,
      imagePath: data['imagePath'] as String?,
      staffNote: data['staffNote'] as String?,
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt'] ?? data['createdAt']),
      timeline: rawTimeline is List
          ? rawTimeline
              .whereType<Map>()
              .map((e) => StatusUpdate.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.value,
      'status': status.value,
      'location': location,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'staffNote': staffNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'timeline': timeline.map((e) => e.toMap()).toList(),
    };
  }
}
