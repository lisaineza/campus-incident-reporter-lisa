import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../models/status_update.dart';
import '../services/incident_repository.dart';
import '../services/storage_service.dart';

class ReportFormController extends ChangeNotifier {
  ReportFormController({
    required IncidentRepository repository,
    required StorageService storage,
    ImagePicker? picker,
  })  : _repository = repository,
        _storage = storage,
        _picker = picker ?? ImagePicker();

  final IncidentRepository _repository;
  final StorageService _storage;
  final ImagePicker _picker;

  IncidentCategory? _category;
  String? _location;
  File? _photo;
  bool _submitting = false;
  String? _error;

  IncidentCategory? get category => _category;
  String? get location => _location;
  File? get photo => _photo;
  bool get isSubmitting => _submitting;
  String? get error => _error;

  void selectCategory(IncidentCategory category) {
    _category = category;
    notifyListeners();
  }

  void selectLocation(String? location) {
    _location = location;
    notifyListeners();
  }

  Future<void> pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (picked == null) return;
      _photo = File(picked.path);
      _error = null;
      notifyListeners();
    } catch (_) {
      _error = 'Could not open the photo. Check the app has camera and gallery permission.';
      notifyListeners();
    }
  }

  void removePhoto() {
    _photo = null;
    notifyListeners();
  }

  Future<bool> submit({
    required AppUser reporter,
    required String title,
    required String description,
    String spot = '',
  }) async {
    final category = _category;
    final location = _location;
    if (category == null || location == null) {
      _error = 'Choose a category and a location.';
      notifyListeners();
      return false;
    }

    _submitting = true;
    _error = null;
    notifyListeners();

    String? uploadedPath;
    try {
      final id = _repository.newId();
      String? imageUrl;

      final photo = _photo;
      if (photo != null) {
        final uploaded = await _storage.uploadIncidentPhoto(
          uid: reporter.uid,
          incidentId: id,
          file: photo,
        );
        imageUrl = uploaded.url;
        uploadedPath = uploaded.path;
      }

      final now = DateTime.now();
      final trimmedSpot = spot.trim();
      await _repository.create(Incident(
        id: id,
        title: title.trim(),
        description: description.trim(),
        category: category,
        status: IncidentStatus.submitted,
        location: trimmedSpot.isEmpty ? location : '$location, $trimmedSpot',
        reporterId: reporter.uid,
        reporterName: reporter.name,
        imageUrl: imageUrl,
        imagePath: uploadedPath,
        createdAt: now,
        updatedAt: now,
        timeline: [
          StatusUpdate(
            status: IncidentStatus.submitted,
            at: now,
            byName: reporter.name,
          ),
        ],
      ));
      return true;
    } catch (_) {
      final orphan = uploadedPath;
      if (orphan != null) {
        try {
          await _storage.deleteByPath(orphan);
        } catch (_) {}
      }
      _error = 'Your report could not be submitted. Check your connection and try again.';
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
