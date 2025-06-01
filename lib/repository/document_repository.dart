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

      print('Get Documents Status Code: ${res.statusCode}');
      print('Get Documents Response Body: ${res.body}');

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];
          final jsonData = jsonDecode(res.body);
          if (jsonData is List) {
            for (var doc in jsonData) {
              documents.add(DocumentModel.fromJson(doc));
            }
          }
          error = ErrorModel(error: null, data: documents);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }
    } catch (e) {
      print('Error in getDocument: $e');
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> updateTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );

    try {
      var res = await http.post(
        Uri.parse('$host/api/doc/title'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'title': title, 'id': id}),
      );

      print('Update Title Status Code: ${res.statusCode}');
      print('Update Title Response Body: ${res.body}');

      switch (res.statusCode) { 
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(jsonDecode(res.body))
          );
          break;
        case 404:
          error = ErrorModel(
            error: 'Document not found',
            data: null
          );
          break;
        default:
          error = ErrorModel(
            error: 'Failed to update document title',
            data: null
          );
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );

    try {
      var res = await _client.get(
        Uri.parse('$host/api/docs/$id'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      print('Get Document Status Code: ${res.statusCode}');
      print('Get Document Response Body: ${res.body}');

      switch (res.statusCode) {
        case 200:
          final jsonData = jsonDecode(res.body);
          error = ErrorModel(
            error: null, 
            data: DocumentModel.fromJson(jsonData)
          );
          break;
        case 404:
          error = ErrorModel(
            error: 'Document not found',
            data: null
          );
          break;
        default:
          error = ErrorModel(
            error: 'Failed to fetch document',
            data: null
          );
      }
    } catch (e) {
      print('Error in getDocumentById: $e');
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

}
