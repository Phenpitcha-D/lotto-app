// To parse this JSON data, do
//
//     final userLoginRequest = userLoginRequestFromJson(jsonString);

import 'dart:convert';

UserLoginRequest userLoginRequestFromJson(String str) =>
    UserLoginRequest.fromJson(json.decode(str));

String userLoginRequestToJson(UserLoginRequest data) =>
    json.encode(data.toJson());

class UserLoginRequest {
  String username;
  String email;
  String password;

  UserLoginRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      UserLoginRequest(
        username: json["username"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
    "username": username,
    "email": email,
    "password": password,
  };
}
