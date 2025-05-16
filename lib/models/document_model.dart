import 'dart:convert';
import 'dart:math';

class DocumentModel {

  final String title;
  final String uid;
  final List content;

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      title: map['title'] ?? '',
      uid: map['uid'] ?? '',
      content: map['content'] ,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      id: map['_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) => DocumentModel.fromMap(map)

  DocumentModel({required this.title, required this.uid, required this.content, required this.createdAt, required this.id});
}