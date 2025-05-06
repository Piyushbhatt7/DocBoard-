import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final provider

  AuthRepository({required GoogleSignIn googleSignIn})
    : _googleSignIn = googleSignIn;

  void signInWithGoogle() async {

    try{
      final user = await _googleSignIn.signIn();
      if(user!=null)
      {
        print(user.email);
        print(user.displayName);
        print(user.photoUrl);
      }
    }
    catch(e)
    {
      print(e);
    }
  }
}
