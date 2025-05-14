import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  Future<void> setToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('x-auth-token');
  }
}
