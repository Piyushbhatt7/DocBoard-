import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  static const String _tokenKey = 'x-auth-token';

  Future<void> setToken(String token) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenKey, token);
    } catch (e) {
      print('Error setting token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return preferences.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}
