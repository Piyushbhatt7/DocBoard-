import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

final documentRepositoryProvider = Provider(
  (ref) => DocumentRepository(client: Client()),
);

class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error = ErrorModel(error: 'Some error occurred', data: null);
    try {
      var res = await http.post(
        Uri.parse('$host/api/doc/create'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'title': 'Untitled Document',
          'content': [],
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      if (res.statusCode == 200) {
        error = ErrorModel(
          error: null,
          data: DocumentModel.fromJson(jsonDecode(res.body)),
        );
      } else {
        error = ErrorModel(error: jsonDecode(res.body)['error'], data: null);
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
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
        Uri.parse('$host/api/docs/me'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      print('Status Code: ${res.statusCode}');
      print('Response Body: ${res.body}');

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(DocumentModel.fromJson(jsonDecode(res.body)[i]));
          }
          error = ErrorModel(error: null, data: documents);

          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    var res = await http.post(
      Uri.parse('$host/doc/title'),
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      body: jsonEncode({'title': title, 'id': id}),
    );
  }
}
