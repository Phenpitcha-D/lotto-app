// To parse this JSON data, do
//
//     final userLoginRespon = userLoginResponFromJson(jsonString);

import 'dart:convert';

UserLoginRespon userLoginResponFromJson(String str) => UserLoginRespon.fromJson(json.decode(str));

String userLoginResponToJson(UserLoginRespon data) => json.encode(data.toJson());

class UserLoginRespon {
    bool success;
    String message;
    String token;
    User user;

    UserLoginRespon({
        required this.success,
        required this.message,
        required this.token,
        required this.user,
    });

    factory UserLoginRespon.fromJson(Map<String, dynamic> json) => UserLoginRespon(
        success: json["success"],
        message: json["message"],
        token: json["token"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "token": token,
        "user": user.toJson(),
    };
}

class User {
    int uid;
    String username;
    String email;
    int wallet;
    String role;
    String createdAt;

    User({
        required this.uid,
        required this.username,
        required this.email,
        required this.wallet,
        required this.role,
        required this.createdAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        uid: json["uid"],
        username: json["username"],
        email: json["email"],
        wallet: json["wallet"],
        role: json["role"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "email": email,
        "wallet": wallet,
        "role": role,
        "created_at": createdAt,
    };
}
