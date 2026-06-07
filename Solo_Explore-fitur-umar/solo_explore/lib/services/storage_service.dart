import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  String? getToken() {
    return _prefs?.getString('auth_token');
  }

  Future<void> deleteToken() async {
    await _prefs?.remove('auth_token');
  }

  Future<void> clearToken() async {
    await deleteToken();
  }

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString('user_data', json.encode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs?.getString('user_data');
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Generic storage
  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
}
