import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import 'user.dart';

/// Thrown when a coordinator signs in on the phone app, which is for patrol officers only.
class NotOfficerException implements Exception {
  const NotOfficerException();
}

/// Repository: everything about signing in and out. It talks to the API; the ViewModel talks to it.
class AuthRepository {
  AuthRepository({required this.api, required this.tokens});

  final ApiClient api;
  final TokenStorage tokens;

  // The same paths the dashboard's sign-in page uses
  static const loginPath = '/api/v1/auth/login';
  static const mePath = '/users/me';

  Future<User> signIn(String email, String password) async {
    final tokenPair = await api.post(loginPath, body: {'email': email, 'password': password}) as Map<String, dynamic>;
    final access = tokenPair['access_token'] as String;

    // Check who signed in before saving anything on the phone
    final me = User.fromJson(await api.get(mePath, token: access) as Map<String, dynamic>);
    if (!me.isOfficer) throw const NotOfficerException();

    await tokens.save(access: access, refresh: tokenPair['refresh_token'] as String);
    return me;
  }

  Future<bool> hasSavedSession() async => (await tokens.readAccess()) != null;

  Future<void> signOut() => tokens.clear();
}
