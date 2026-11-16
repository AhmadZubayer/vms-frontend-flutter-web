import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (Ref ref) => TokenStorage(),
);

/// Keeps the access token between app launches.
class TokenStorage {
  TokenStorage();

  static const String _tokenKey = 'vms.accessToken';

  String? _cached;
  bool _loaded = false;

  Future<String?> read() async {
    if (_loaded) {
      return _cached;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _cached = prefs.getString(_tokenKey);
    _loaded = true;
    return _cached;
  }

  Future<void> write(String token) async {
    _cached = token;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
