import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/models/user_model.dart';
import 'package:google_docs/repository/local_storage_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(), 
    client: Client(), 
    localStorageRepo: LocalStorageRepo(),
    ));

final userProvider = StateProvider<UserModel?>((ref) => null); // 1:47

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepo _localStorageRepo;
  //35:44

  AuthRepository({
    required GoogleSignIn googleSignIn, 
    required Client client,
    required LocalStorageRepo localStorageRepo, 
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepo = localStorageRepo;



 Future<ErrorModel> signInWithGoogle() async {
  ErrorModel error = ErrorModel(error: 'Some unexpected error occurred', data: null);

  try {
    GoogleSignInAccount? user = await _googleSignIn.signInSilently();

    // ✅ Fallback to full sign-in if silent fails
    user ??= await _googleSignIn.signIn();

    if (user != null) {
      final userAcc = UserModel(
        email: user.email,
        name: user.displayName ?? 'No Name',
        profilePic: user.photoUrl ?? '',
        uid: '',
        token: '',
      );

      var res = await _client.post(
        Uri.parse('$host/api/signup'),
        body: jsonEncode(userAcc.toJson()), // ✅ jsonEncode to avoid sending Map
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
          _localStorageRepo.setToken(newUser.token);
          break;
        default:
          error = ErrorModel(error: 'Signup failed. Status code: ${res.statusCode}', data: null);
      }
    }
  } catch (e) {
    print(e);
    error = ErrorModel(error: e.toString(), data: null);
  }

  return error;
}


//  Future<ErrorModel> signInWithGoogle() async {
//   ErrorModel error = ErrorModel(error: 'Some unexpected error occurred', data: null);

//   try {
//     GoogleSignInAccount? user = await _googleSignIn.signInSilently();

//     // ✅ Fallback to full sign-in if silent fails
//     user ??= await _googleSignIn.signIn();

//     if (user != null) {
//       final userAcc = UserModel(
//         email: user.email,
//         name: user.displayName ?? 'No Name',
//         profilePic: user.photoUrl ?? '',
//         uid: '',
//         token: '',
//       );

//       var res = await _client.post(
//         Uri.parse('$host/api/signup'),
//         body: jsonEncode(userAcc.toJson()), // ✅ jsonEncode to avoid sending Map
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       switch (res.statusCode) {
//         case 200:
//           final newUser = userAcc.copyWith(
//             uid: jsonDecode(res.body)['user']['_id'],
//           );
//           error = ErrorModel(error: null, data: newUser);
//           break;
//         default:
//           error = ErrorModel(error: 'Signup failed. Status code: ${res.statusCode}', data: null);
//       }
//     }
//   } catch (e) {
//     print(e);
//     error = ErrorModel(error: e.toString(), data: null);
//   }

//   return error;
// }

}
