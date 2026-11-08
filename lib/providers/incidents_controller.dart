import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart';

import '../core/utils/incident_filters.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../services/incident_repository.dart';
import '../services/storage_service.dart';

enum ReportScope { mine, campus }

class IncidentsController extends ChangeNotifier {
  IncidentsController(this._repository, this._storage);

  final IncidentRepository _repository;
  final StorageService _storage;

  StreamSubscription<List<Incident>>? _allSub;
  StreamSubscription<List<Incident>>? _mineSub;

  String? _uid;
  bool _isStaff = false;

  List<Incident> _all = const [];
  List<Incident> _mine = const [];
  bool _loadingAll = true;
  bool _loadingMine = true;
  String? _error;

  String _query = '';
  IncidentStatus? _statusFilter;
  IncidentCategory? _categoryFilter;
  ReportScope _scope = ReportScope.mine;

  final Set<String> _busyIds = {};

  bool get isStaff => _isStaff;
  List<Incident> get all => _all;
  List<Incident> get mine => _mine;
  String? get error => _error;

  String get query => _query;
  IncidentStatus? get statusFilter => _statusFilter;
  IncidentCategory? get categoryFilter => _categoryFilter;
  ReportScope get scope => _scope;

  bool get hasActiveFilters =>
      _query.isNotEmpty || _statusFilter != null || _categoryFilter != null;

  List<Incident> get _scoped => _scope == ReportScope.mine ? _mine : _all;

  bool get isLoading =>
      _scope == ReportScope.mine ? _loadingMine : _loadingAll;

  /// Reports for the Reports tab after scope, search and filters are applied.
  List<Incident> get visible => filterIncidents(
        _scoped,
        query: _query,
        status: _statusFilter,
        category: _categoryFilter,
      );

  /// Students see a summary of their own reports; staff see the whole campus.
  List<Incident> get _dashboardSource => _isStaff ? _all : _mine;

  bool get dashboardLoading => _isStaff ? _loadingAll : _loadingMine;

  StatusCounts get summary => StatusCounts.from(_dashboardSource);

  StatusCounts get myCounts => StatusCounts.from(_mine);

  List<Incident> get recent => _dashboardSource.take(3).toList();

  bool isBusy(String incidentId) => _busyIds.contains(incidentId);

  /// Called whenever the signed-in user changes. Safe to call repeatedly.
  void bindUser(AppUser? user) {
    final uid = user?.uid;
    final staff = user?.isStaff ?? false;
    if (uid == _uid && staff == _isStaff) return;

    _uid = uid;
    _isStaff = staff;

    _allSub?.cancel();
    _mineSub?.cancel();
    _allSub = null;
    _mineSub = null;

    _all = const [];
    _mine = const [];
    _loadingAll = true;
    _loadingMine = true;
    _error = null;
    _query = '';
    _statusFilter = null;
    _categoryFilter = null;
    _scope = staff ? ReportScope.campus : ReportScope.mine;

    if (uid == null) return;

    _allSub = _repository.watchAll().listen((items) {
      _all = items;
      _loadingAll = false;
      notifyListeners();
    }, onError: _handleStreamError);

    _mineSub = _repository.watchByReporter(uid).listen((items) {
      _mine = items;
      _loadingMine = false;
      notifyListeners();
    }, onError: _handleStreamError);
  }

  void _handleStreamError(Object error) {
    _error = 'Could not load reports. Check your connection and try again.';
    _loadingAll = false;
    _loadingMine = false;
    notifyListeners();
  }

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setScope(ReportScope scope) {
    if (scope == _scope) return;
    _scope = scope;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _statusFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> updateStatus(
    Incident incident,
    IncidentStatus status, {
    required String byName,
    String? note,
  }) async {
    if (!_isStaff) return 'Only campus staff can update a report status.';
    if (status == incident.status) return 'The report is already ${status.label}.';

    _busyIds.add(incident.id);
    notifyListeners();
    try {
      await _repository.updateStatus(
        id: incident.id,
        status: status,
        byName: byName,
        note: note,
      );
      return null;
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied'
          ? 'You do not have permission to update this report.'
          : 'Update failed. Check your connection and try again.';
    } catch (_) {
      return 'Update failed. Check your connection and try again.';
    } finally {
      _busyIds.remove(incident.id);
      notifyListeners();
    }
  }

  bool canDelete(Incident incident) {
    if (_isStaff) return true;
    return incident.reporterId == _uid &&
        incident.status == IncidentStatus.submitted;
  }

  /// Returns an error message, or null on success.
  Future<String?> deleteIncident(Incident incident) async {
    if (!canDelete(incident)) return 'You can only withdraw reports that have not been picked up yet.';

    _busyIds.add(incident.id);
    notifyListeners();
    try {
      final path = incident.imagePath;
      if (path != null && incident.reporterId == _uid) {
        try {
          await _storage.deleteByPath(path);
        } catch (_) {
          // A leftover photo is not worth blocking the delete over.
        }
      }
      await _repository.delete(incident.id);
      return null;
    } catch (_) {
      return 'Could not delete the report. Please try again.';
    } finally {
      _busyIds.remove(incident.id);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _allSub?.cancel();
    _mineSub?.cancel();
    super.dispose();
  }
}
