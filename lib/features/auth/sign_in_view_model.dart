import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import 'auth_repository.dart';
import 'user.dart';

/// ViewModel: holds what the Sign In screen shows (busy, error, password hidden)
/// and does the work when the button is pressed. It has no widgets in it.
class SignInViewModel extends ChangeNotifier {
  SignInViewModel(this._auth);

  final AuthRepository _auth;

  // The same message for every wrong email or password, so nobody can tell which emails have accounts
  static const signInFailed = 'We could not sign you in. Check your email and password and try again';

  bool _busy = false;
  String? _error;
  bool _passwordHidden = true;
  User? _user;

  bool get busy => _busy;
  String? get error => _error;
  bool get passwordHidden => _passwordHidden;
  User? get user => _user;

  void togglePasswordVisibility() {
    _passwordHidden = !_passwordHidden;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    return null;
  }

  /// Returns true when the officer is signed in and the app can open the home screen.
  Future<bool> signIn(String email, String password) async {
    if (_busy) return false;

    if (apiBaseUrl.isEmpty) {
      _error = 'The app has no server address. Run it with --dart-define=API_URL=...';
      notifyListeners();
      return false;
    }

    _busy = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _auth.signIn(email.trim(), password);
      return true;
    } on NotOfficerException {
      _error = 'This app is for patrol officers. Coordinators sign in on the Vesper website.';
    } on ApiException catch (problem) {
      _error = _messageFor(problem);
    } finally {
      _busy = false;
      notifyListeners();
    }
    return false;
  }

  String _messageFor(ApiException problem) {
    if (problem.isOffline) return problem.message;
    if (problem.statusCode == 429) return 'Too many attempts. Wait a few minutes and try again.';
    return signInFailed;
  }
}
