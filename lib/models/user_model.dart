import 'dart:convert';

class UserModel {
  final String email;
  //final String id;
  final String name;
  final String profilePic;
  final String uid;
  final String token;

  UserModel({
    required this.email,
    //required this.id,
    required this.name,
    required this.profilePic,
    required this.uid,
    required this.token,
  });

  // From JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      //id: json['id'],
      name: json['name'] ?? '',
      profilePic: json['profilePic'] ?? '',
      uid: json['_id'] ?? '',
      token: json['token'] ?? '',
    );
  }

  // From UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
     // 'id': id,
      'name': name,
      'profilePic': profilePic,
      'uid': uid,
      'token': token,
    };
  }

  // copyWith function
  UserModel copyWith({
    String? email,
    String? id,
    String? name,
    String? profilePic,
    String? uid,
    String? token,
  }) {
    return UserModel(
      email: email ?? this.email,
      //id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }
}
