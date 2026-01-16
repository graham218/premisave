import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // For web, by default it uses localStorage which persists across sessions
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    // Android configuration
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // iOS configuration
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    // Web configuration - localStorage is default and persists
    webOptions: const WebOptions(
      publicKey: 'premisave_auth',
    ),
  );

  // Rest of the class remains the same...
  static Future<void> saveToken(String token) async {
    final expiryDate = DateTime.now().add(const Duration(days: 30)).toIso8601String();
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'token_expiry', value: expiryDate);
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'token');
    final expiryStr = await _storage.read(key: 'token_expiry');

    if (token == null || expiryStr == null) return null;

    try {
      final expiryDate = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiryDate)) {
        await clear();
        return null;
      }
    } catch (e) {
      print('Error parsing expiry date: $e');
      return token;
    }

    return token;
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static Future<bool> shouldRefreshToken() async {
    final expiryStr = await _storage.read(key: 'token_expiry');
    if (expiryStr == null) return false;

    try {
      final expiryDate = DateTime.parse(expiryStr);
      final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
      return daysUntilExpiry < 7;
    } catch (e) {
      return false;
    }
  }

  static Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _storage.read(key: 'token_expiry');
    if (expiryStr == null) return null;

    try {
      return DateTime.parse(expiryStr);
    } catch (e) {
      return null;
    }
  }
}