// To parse this JSON data, do
//
//     final userRegisterRequest = userRegisterRequestFromJson(jsonString);

import 'dart:convert';

UserRegisterRequest userRegisterRequestFromJson(String str) =>
    UserRegisterRequest.fromJson(json.decode(str));

String userRegisterRequestToJson(UserRegisterRequest data) =>
    json.encode(data.toJson());

class UserRegisterRequest {
  String username;
  String password;
  String email;
  int wallet;

  UserRegisterRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.wallet,
  });

  factory UserRegisterRequest.fromJson(Map<String, dynamic> json) =>
      UserRegisterRequest(
        username: json["username"],
        password: json["password"],
        email: json["email"],
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "email": email,
    "wallet": wallet,
  };
}
