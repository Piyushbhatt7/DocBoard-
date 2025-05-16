import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/models/user_model.dart';
import 'package:google_docs/repository/local_storage_repo.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(
      clientId: '193875630945-4g80o8vpci8okssnrbhp3sm72dv7bu83.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
      serverClientId: '193875630945-4g80o8vpci8okssnrbhp3sm72dv7bu83.apps.googleusercontent.com',
    ),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      print('Starting Google Sign In process...');
      
      // First try to sign in silently
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      print('Silent sign in result: ${user?.email ?? 'null'}');
      
      // If silent sign-in fails, show the popup
      if (user == null) {
        print('Attempting to show sign in popup...');
        user = await _googleSignIn.signIn();
        print('Popup sign in result: ${user?.email ?? 'null'}');
      }

      if (user != null) {
        print('User signed in successfully: ${user.email}');
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName ?? '',
          profilePic: user.photoUrl ?? '',
          uid: '',
          token: '',
        );

        final url = '$host/api/signup';
        print('Attempting to connect to: $url');

        var res = await _client.post(
          Uri.parse(url),
          body: jsonEncode(userAcc.toJson()),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        print('Response status: ${res.statusCode}');
        print('Response body: ${res.body}');

        switch (res.statusCode) {
          case 200:
            final responseData = jsonDecode(res.body);
            final newUser = userAcc.copyWith(
              uid: responseData['user']['_id'],
              token: responseData['token'],
            );
            error = ErrorModel(error: null, data: newUser);
            await _localStorageRepository.setToken(newUser.token);
            break;
          default:
            error = ErrorModel(
              error: 'Failed to sign up: ${res.body}',
              data: null,
            );
            break;
        }
      } else {
        print('Sign in was cancelled or failed');
        error = ErrorModel(
          error: 'Sign in was cancelled or failed',
          data: null,
        );
      }
    } catch (e) {
      print('Error during sign in: $e');
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null && token.isNotEmpty) {
        var res = await _client.get(
          Uri.parse('$host/api/'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
        );
        
        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonDecode(res.body)['user'],
            ).copyWith(token: token);
            error = ErrorModel(error: null, data: newUser);
            await _localStorageRepository.setToken(newUser.token);
            break;
          default:
            await _localStorageRepository.setToken('');
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
      await _localStorageRepository.setToken('');
    }
    return error;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    await _localStorageRepository.setToken('');
  }
}