import 'package:get_storage/get_storage.dart';

class StorageService {
  final _box = GetStorage();

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  // Token methods
  Future<void> saveToken(String token) async {
    await _box.write(_tokenKey, token);
  }

  String? getToken() {
    return _box.read(_tokenKey);
  }

  Future<void> removeToken() async {
    await _box.remove(_tokenKey);
  }

  bool get hasToken => getToken() != null;

  // User methods
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.write(_userKey, user);
  }

  Map<String, dynamic>? getUser() {
    return _box.read(_userKey);
  }

  Future<void> removeUser() async {
    await _box.remove(_userKey);
  }

  // Theme methods
  Future<void> saveThemeMode(String themeMode) async {
    await _box.write(_themeKey, themeMode);
  }

  String getThemeMode() {
    return _box.read(_themeKey) ?? 'light';
  }

  // Language methods
  Future<void> saveLanguage(String language) async {
    await _box.write(_languageKey, language);
  }

  String getLanguage() {
    return _box.read(_languageKey) ?? 'es';
  }

  // Clear all data
  Future<void> clearAll() async {
    await _box.erase();
  }

  // Generic methods
  Future<void> save(String key, dynamic value) async {
    await _box.write(key, value);
  }

  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  bool hasData(String key) {
    return _box.hasData(key);
  }
}