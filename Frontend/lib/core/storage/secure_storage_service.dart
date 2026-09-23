import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _keyToken = 'jwt_auth_token';
  static const String _keyBaseUrl = 'custom_base_url';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _keyUserId, value: id);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserEmail, value: email);
  }

  static Future<Map<String, String?>> getUserData() async {
    final id = await _storage.read(key: _keyUserId);
    final name = await _storage.read(key: _keyUserName);
    final email = await _storage.read(key: _keyUserEmail);
    return {'id': id, 'name': name, 'email': email};
  }

  static Future<void> clearAuth() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserEmail);
  }

  static Future<void> saveBaseUrl(String url) async {
    await _storage.write(key: _keyBaseUrl, value: url);
  }

  static Future<String?> getBaseUrl() async {
    return await _storage.read(key: _keyBaseUrl);
  }
}
