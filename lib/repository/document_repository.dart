import 'package:http/http.dart';

class DocumentRepository {

  final Client _client;

  DocumentRepository({
    required Client client
    }) : _client = client;

}