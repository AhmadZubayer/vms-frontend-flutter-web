import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_user.dart';

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => AuthRepository(
        ref.watch(apiClientProvider),
        ref.watch(tokenStorageProvider),
      ),
    );

/// Sign-in, sign-out, and reading the signed-in account.
class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  /// Exchanges credentials for an access token and answers with the account.
  Future<AuthUser> signIn({
    required String userEmail,
    required String password,
  }) async {
    final dynamic payload = await _api.post(
      '/api/auth/login',
      body: <String, String>{'userEmail': userEmail, 'password': password},
    );

    final String token = ((payload as Map)['accessToken'] as String?) ?? '';
    await _tokens.write(token);

    return currentUser();
  }

  Future<AuthUser> currentUser() async {
    final dynamic payload = await _api.get('/api/auth/me');
    return AuthUser.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  /// Signs the token out on the server, then forgets it locally either way.
  Future<void> signOut() async {
    try {
      await _api.post('/api/auth/logout');
    } finally {
      await _tokens.clear();
    }
  }

  Future<String?> storedToken() => _tokens.read();

  Future<void> forgetToken() => _tokens.clear();
}
