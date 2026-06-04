import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<void> _write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
