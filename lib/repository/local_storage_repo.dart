import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepo {

  void setToken() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('x-auth-token', token);
  }
}