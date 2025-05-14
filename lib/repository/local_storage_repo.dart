import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepo {

  void setToken(String token) async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('x-auth-token', token);
  }

  void getToken() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.getString('x-auth-token');
  }
}