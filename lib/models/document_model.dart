class DocumentModel {

  final String title;
  final String uid;
  final List content;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      title: json['title'] as String,
      uid: json['uid'] as String,
      content: json['content'] as List,
      createdAt: DateTime.parse(json['createdAt'] as String),
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'uid': uid,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
    };
  }
  final DateTime createdAt;
  final String id;

  DocumentModel({required this.title, required this.uid, required this.content, required this.createdAt, required this.id});
}