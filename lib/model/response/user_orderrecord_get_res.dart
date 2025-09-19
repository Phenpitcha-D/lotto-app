// To parse this JSON data, do
//
//     final userOrdersRecordResponse = userOrdersRecordResponseFromJson(jsonString);

import 'dart:convert';

UserOrdersRecordResponse userOrdersRecordResponseFromJson(String str) =>
    UserOrdersRecordResponse.fromJson(json.decode(str));

String userOrdersRecordResponseToJson(UserOrdersRecordResponse data) =>
    json.encode(data.toJson());

class UserOrdersRecordResponse {
  bool success;
  List<Datum> data;

  UserOrdersRecordResponse({required this.success, required this.data});

  factory UserOrdersRecordResponse.fromJson(Map<String, dynamic> json) =>
      UserOrdersRecordResponse(
        success: json["success"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int oid;
  int purchasePrice;
  String purchaseTime;
  String lottoNumber;
  int lid;

  Datum({
    required this.oid,
    required this.purchasePrice,
    required this.purchaseTime,
    required this.lottoNumber,
    required this.lid,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    oid: json["oid"],
    purchasePrice: json["purchase_price"],
    purchaseTime: json["purchase_time"],
    lottoNumber: json["lotto_number"],
    lid: json["lid"],
  );

  Map<String, dynamic> toJson() => {
    "oid": oid,
    "purchase_price": purchasePrice,
    "purchase_time": purchaseTime,
    "lotto_number": lottoNumber,
    "lid": lid,
  };
}
