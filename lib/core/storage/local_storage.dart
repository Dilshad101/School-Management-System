// Manages local data storage and retrieval.
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPref._internal();

  static final SharedPref _instance = SharedPref._internal();
  factory SharedPref() => _instance;

  static SharedPreferences? _prefs;
  static const String _tokenKey = 'token';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String? getToken() => _prefs?.getString(_tokenKey);
  Future<void> setToken(String token) async =>
      await _prefs?.setString(_tokenKey, token);

  bool isUserLoggedIn() => _prefs?.getBool(_isLoggedInKey) ?? false;
  Future<void> setUserLoggedIn(bool value) async =>
      await _prefs?.setBool(_isLoggedInKey, value);

  String? getString(String key) => _prefs?.getString(key);
  Future<void> setString(String key, String value) async =>
      await _prefs?.setString(key, value);

  bool? getBool(String key) => _prefs?.getBool(key);
  Future<void> setBool(String key, bool value) async =>
      await _prefs?.setBool(key, value);

  Future<void> remove(String key) async => await _prefs?.remove(key);

  Future<void> clear() async => await _prefs?.clear();
}
