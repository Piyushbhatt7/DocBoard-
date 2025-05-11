import 'dart:convert';

class UserModel {
  final String email;
  final String id;
  final String name;
  final String profilePic;
  final String uid;
  final String token;

  UserModel({
    required this.email,
    required this.id,
    required this.name,
    required this.profilePic,
    required this.uid,
    required this.token,
  });

  // From JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      profilePic: json['profilePic'],
      uid: json['uid'],
      token: json['token'], email: '',
    );
  }

  // From UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePic': profilePic,
      'uid': uid,
      'token': token,
    };
  }
}
