// To parse this JSON data, do
//
//     final userRegisterRespon = userRegisterResponFromJson(jsonString);

import 'dart:convert';

UserRegisterRespon userRegisterResponFromJson(String str) =>
    UserRegisterRespon.fromJson(json.decode(str));

String userRegisterResponToJson(UserRegisterRespon data) =>
    json.encode(data.toJson());

class UserRegisterRespon {
  bool success;
  String message;
  int uid;
  String username;
  String email;
  String role;
  String wallet;

  UserRegisterRespon({
    required this.success,
    required this.message,
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.wallet,
  });

  factory UserRegisterRespon.fromJson(Map<String, dynamic> json) =>
      UserRegisterRespon(
        success: json["success"],
        message: json["message"],
        uid: json["uid"],
        username: json["username"],
        email: json["email"],
        role: json["role"],
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "uid": uid,
    "username": username,
    "email": email,
    "role": role,
    "wallet": wallet,
  };
}
