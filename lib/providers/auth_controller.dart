import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum SessionStatus { unknown, signedOut, signedIn }

class AuthController extends ChangeNotifier {
  AuthController(this._service) {
    _uidSub = _service.uidChanges().listen(_onUidChanged);
  }

  final AuthService _service;
  StreamSubscription<String?>? _uidSub;
  StreamSubscription<AppUser?>? _profileSub;

  SessionStatus _status = SessionStatus.unknown;
  AppUser? _user;
  bool _busy = false;
  String? _error;

  SessionStatus get status => _status;
  AppUser? get user => _user;
  bool get isBusy => _busy;
  String? get error => _error;
  bool get isStaff => _user?.isStaff ?? false;

  void _onUidChanged(String? uid) {
    _profileSub?.cancel();
    _profileSub = null;
    _user = null;

    if (uid == null) {
      _status = SessionStatus.signedOut;
      notifyListeners();
      return;
    }

    _status = SessionStatus.signedIn;
    notifyListeners();

    _profileSub = _service.watchProfile(uid).listen(
      (profile) {
        _user = profile;
        notifyListeners();
      },
      onError: (Object _) {
        // The listener can briefly fail while signing out; the uid stream
        // will clean things up right after.
      },
    );
  }

  Future<bool> signIn(String email, String password) {
    return _run(() => _service.signIn(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String department,
  }) {
    return _run(() => _service.register(
          name: name,
          email: email,
          password: password,
          department: department,
        ));
  }

  Future<bool> sendPasswordReset(String email) {
    return _run(() => _service.sendPasswordReset(email));
  }

  Future<void> signOut() => _service.signOut();

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _uidSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
