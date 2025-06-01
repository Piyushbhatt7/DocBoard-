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

      if (res.statusCode == 200) {
        List<dynamic> documents = jsonDecode(res.body);
        List<DocumentModel> docs = documents
            .map((doc) => DocumentModel.fromJson(doc))
            .toList();
        error = ErrorModel(error: null, data: docs);
      } else {
        error = ErrorModel(error: jsonDecode(res.body)['error'], data: null);
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
        Uri.parse('$host/api/doc/$id'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      print('Get Document Status Code: ${res.statusCode}');
      print('Get Document Response Body: ${res.body}');

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
      var res = await _client.put(
        Uri.parse('$host/api/doc/title'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'title': title,
          'id': id,
        }),
      );

      print('Update Title Status Code: ${res.statusCode}');
      print('Update Title Response Body: ${res.body}');

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

  Future<ErrorModel> updateDocument({
    required String token,
    required String id,
    required List<dynamic> content,
  }) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );

    try {
      var res = await _client.put(
        Uri.parse('$host/api/doc/content'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'content': content,
          'id': id,
        }),
      );

      print('Update Document Status Code: ${res.statusCode}');
      print('Update Document Response Body: ${res.body}');

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
}
