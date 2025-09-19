// To parse this JSON data, do
//
//     final lottoReleaseRequest = lottoReleaseRequestFromJson(jsonString);

import 'dart:convert';

LottoReleaseRequest lottoReleaseRequestFromJson(String str) =>
    LottoReleaseRequest.fromJson(json.decode(str));

String lottoReleaseRequestToJson(LottoReleaseRequest data) =>
    json.encode(data.toJson());

class LottoReleaseRequest {
  int count;
  int price;

  LottoReleaseRequest({required this.count, required this.price});

  factory LottoReleaseRequest.fromJson(Map<String, dynamic> json) =>
      LottoReleaseRequest(count: json["count"], price: json["price"]);

  Map<String, dynamic> toJson() => {"count": count, "price": price};
}
