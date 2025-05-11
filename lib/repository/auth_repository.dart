import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn()
    ));

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  //35:44

  AuthRepository({required GoogleSignIn googleSignIn, required Client client})
    : _googleSignIn = googleSignIn;


  void signInWithGoogle() async {

    try{
      final user = await _googleSignIn.signIn();
      if(user!=null)
      {
        final userAcc = UserModel(
          email: user.email,
           name: user.displayName!, 
           profilePic: user.photoUrl!, 
           uid: '', 
           token: '',
           id: ''
           );
      }
    }
    catch(e)
    {
      print(e);
    }
  }
}
