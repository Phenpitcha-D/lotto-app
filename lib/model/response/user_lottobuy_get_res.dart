// To parse this JSON data, do
//
//     final userLottoBuyResponse = userLottoBuyResponseFromJson(jsonString);

import 'dart:convert';

UserLottoBuyResponse userLottoBuyResponseFromJson(String str) =>
    UserLottoBuyResponse.fromJson(json.decode(str));

String userLottoBuyResponseToJson(UserLottoBuyResponse data) =>
    json.encode(data.toJson());

class UserLottoBuyResponse {
  bool success;
  String message;
  String lottoNumber;
  int price;
  int orderId;

  UserLottoBuyResponse({
    required this.success,
    required this.message,
    required this.lottoNumber,
    required this.price,
    required this.orderId,
  });

  factory UserLottoBuyResponse.fromJson(Map<String, dynamic> json) =>
      UserLottoBuyResponse(
        success: json["success"],
        message: json["message"],
        lottoNumber: json["lotto_number"],
        price: json["price"],
        orderId: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "lotto_number": lottoNumber,
    "price": price,
    "order_id": orderId,
  };
}
