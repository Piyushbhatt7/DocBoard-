import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final documentRepositoryProvider = Provider(
  (ref) => DocumentRepository(
    client: Client(),
  ),
);


class DocumentRepository {

  final Client _client;
         
  DocumentRepository({
    required Client client
    }) : _client = client;

    Future<ErrorModel> createDocument(String token) async {
      
      ErrorModel error = ErrorModel(
        error: 'Some unexpected error occurred', 
        data: null,
        );

       try {
        
        var res = await _client.post(
          Uri.parse('$host/doc/create'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          }),
        );

        switch (res.statusCode) {
          case 200:
            error = ErrorModel(
              error: null, 
              data: DocumentModel.fromJson(res.body as Map<String, dynamic>),
              );

            break;
            default:
            error = ErrorModel(
              error: res.body, 
              data: null,
              );
        }
      
      } catch (e) {
        error = ErrorModel(
          error: e.toString(),
          data: null,
        );
      }
      return error;
    }


     Future<ErrorModel> getDocument(String token) async {
      
      ErrorModel error = ErrorModel(
        error: 'Some unexpected error occurred', 
        data: null,
        );

       try {
        
        var res = await _client.get(
          Uri.parse('$host/doc/me'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
        );

        switch (res.statusCode) {
          case 200:
          List<DocumentModel> document = [];
          for (int i = 0; i<jsonDecode(res.body).length; i++) {
            document.add(DocumentModel.fromJson(jsonDecode(res.body)[i]));
          }
            error = ErrorModel(
              error: null, 
              data: DocumentModel.fromJson(res.body as Map<String, dynamic>),
              );

            break;
            default:
            error = ErrorModel(
              error: res.body, 
              data: null,
              );
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