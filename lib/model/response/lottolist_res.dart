// To parse this JSON data, do
//
//     final lottoListRespon = lottoListResponFromJson(jsonString);

import 'dart:convert';

List<LottoListRespon> lottoListResponFromJson(String str) =>
    List<LottoListRespon>.from(
      json.decode(str).map((x) => LottoListRespon.fromJson(x)),
    );

String lottoListResponToJson(List<LottoListRespon> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LottoListRespon {
  int lid;
  String lottoNumber;
  String status;
  int price;
  String createdAt;

  LottoListRespon({
    required this.lid,
    required this.lottoNumber,
    required this.status,
    required this.price,
    required this.createdAt,
  });

  factory LottoListRespon.fromJson(Map<String, dynamic> json) =>
      LottoListRespon(
        lid: json["lid"],
        lottoNumber: json["lotto_number"],
        status: json["status"],
        price: json["price"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "lid": lid,
    "lotto_number": lottoNumber,
    "status": status,
    "price": price,
    "created_at": createdAt,
  };
}
