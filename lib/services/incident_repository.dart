import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/incident_status.dart';
import '../models/status_update.dart';

abstract class IncidentRepository {
  Stream<List<Incident>> watchAll();

  Stream<List<Incident>> watchByReporter(String uid);

  Stream<Incident?> watchOne(String id);

  /// Reserves a document id so a photo can be uploaded under it before the
  /// report itself is written.
  String newId();

  Future<void> create(Incident incident);

  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String byName,
    String? note,
  });

  Future<void> delete(String id);
}

class FirestoreIncidentRepository implements IncidentRepository {
  FirestoreIncidentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  static const _feedLimit = 200;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  List<Incident> _toList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Incident.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<List<Incident>> watchAll() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .limit(_feedLimit)
        .snapshots()
        .map(_toList);
  }

  @override
  Stream<List<Incident>> watchByReporter(String uid) {
    return _incidents
        .where('reporterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_toList);
  }

  @override
  Stream<Incident?> watchOne(String id) {
    return _incidents.doc(id).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : Incident.fromMap(snap.id, data);
    });
  }

  @override
  String newId() => _incidents.doc().id;

  @override
  Future<void> create(Incident incident) {
    return _incidents.doc(incident.id).set({
      ...incident.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String byName,
    String? note,
  }) {
    final trimmedNote = note?.trim();
    final entry = StatusUpdate(
      status: status,
      at: DateTime.now(),
      byName: byName,
      note: trimmedNote,
    );
    return _incidents.doc(id).update({
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
      'timeline': FieldValue.arrayUnion([entry.toMap()]),
      'staffNote':
          (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
    });
  }

  @override
  Future<void> delete(String id) => _incidents.doc(id).delete();
}
