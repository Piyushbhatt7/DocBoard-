import 'package:google_docs/models/error_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

class DocumentRepository {

  final Client _client;
      
  DocumentRepository({
    required Client client
    }) : _client = client;

    Future<ErrorModel> createDocument() async {

       try {
      // First try to sign in silently // 3:10
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      
      // If silent sign-in fails, show the popup
      if (user == null) {
        user = await _googleSignIn.signIn();
      }

      if (user != null) {
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName ?? '',
          profilePic: user.photoUrl ?? '',
          uid: '',
          token: '',
        );

        var res = await _client.post(
          Uri.parse('$host/api/signup'),
          body: jsonEncode(userAcc.toJson()),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            error = ErrorModel(error: null, data: newUser);
            await _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
      } catch (e) {
        error = ErrorModel(
          error: e.toString(),
          data: null,
        );
      }
      return error;
    }

}