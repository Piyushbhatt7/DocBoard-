import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/models/user_model.dart';
import 'package:google_docs/repository/local_storage_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    googleSignIn: GoogleSignIn(scopes: ['email', 'profile']),
    client: http.Client(),
    localStorageRepo: LocalStorageRepo(),
  );
});


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
    GoogleSignInAccount? user;

    if (kIsWeb) {
      print('[SIGNIN] Attempting signInSilently() on Web...');
      user = await _googleSignIn.signInSilently();
    } else {
      print('[SIGNIN] Attempting signInSilently() on Mobile...');
      user = await _googleSignIn.signInSilently();
      if (user == null) {
        print('[SIGNIN] signInSilently failed, trying signIn...');
        user = await _googleSignIn.signIn();
      }
    }

    print('[SIGNIN] User: $user');

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
        body: jsonEncode(userAcc.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('[SIGNIN] Signup API Response: ${res.statusCode} - ${res.body}');

      if (res.statusCode == 200) {
        final newUser = userAcc.copyWith(
          uid: jsonDecode(res.body)['user']['_id'],
          token: jsonDecode(res.body)['token'],
        );
        error = ErrorModel(error: null, data: newUser);
        await _localStorageRepo.setToken(newUser.token);
      } else {
        error = ErrorModel(
            error: 'Signup failed. Status code: ${res.statusCode}', data: null);
      }
    } else {
      error = ErrorModel(error: 'User is null. Sign-in failed.', data: null);
    }
  } catch (e, st) {
    print('[SIGNIN ERROR] $e');
    print('[STACKTRACE] $st');
    error = ErrorModel(error: e.toString(), data: null);
  }

  return error;
}

 Future<ErrorModel> getUserData() async {
  ErrorModel error = ErrorModel(error: 'Some unexpected error occurred', data: null);

  try {
    
    String? token = await _localStorageRepo.getToken();

    if(token!=null)
    {

      var res = await _client.get(
        Uri.parse('$host/'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      switch (res.statusCode) {
        case 200:
          final newUser = UserModel.fromJson(jsonDecode(res.body)['user'])
          .copyWith(token: token);

          error = ErrorModel(error: null, data: newUser);
          _localStorageRepo.setToken(newUser.token);
          break;
      }
    }
    
  } catch (e) {
    print(e);
    error = ErrorModel(error: e.toString(), data: null);
  }

  return error;
}

}
