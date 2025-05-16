import 'dart:convert';

import 'package:google_docs/constants.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

class DocumentRepository {

  final Client _client;
         
  DocumentRepository({
    required Client client
    }) : _client = client;

    Future<ErrorModel> createDocument(String token) async {

       try {
        
        var res = await _client.post(
          Uri.parse('$host/doc/create'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: {
            'cretedAt': DateTime.now().millisecondsSinceEpoch
          }
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
      
      } catch (e) {
        error = ErrorModel(
          error: e.toString(),
          data: null,
        );
      }
      return error;
    }

}