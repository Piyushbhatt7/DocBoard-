import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn()
    ));

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  //35:44

  AuthRepository({
    required GoogleSignIn googleSignIn, 
    required Client client
    })
    : _googleSignIn = googleSignIn,
    _client = client;


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
      

      _client.post(Uri.parse('$host/api/signup'),
      body: userAcc.toJson(),
      headers: {
        'Content-Type': 'application/json'
      }
      );
    }
    }
    catch(e)
    {
      print(e);
    }
  }
}
