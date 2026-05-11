import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secure.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _secure.read(key: key);
  }

  Future<void> _deleteAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _secure.deleteAll();
    }
  }

  Future<void> saveTokens({required String access, required String refresh}) =>
      Future.wait([
        _write(AppConstants.keyAccessToken, access),
        _write(AppConstants.keyRefreshToken, refresh),
      ]);

  Future<String?> getAccessToken()  => _read(AppConstants.keyAccessToken);
  Future<String?> getRefreshToken() => _read(AppConstants.keyRefreshToken);

  Future<void> saveRole(String role) => _write(AppConstants.keyUserRole, role);
  Future<String?> getRole()          => _read(AppConstants.keyUserRole);

  Future<void> saveUserId(String id) => _write(AppConstants.keyUserId, id);
  Future<String?> getUserId()        => _read(AppConstants.keyUserId);

  Future<void> clearAll() => _deleteAll();
}
