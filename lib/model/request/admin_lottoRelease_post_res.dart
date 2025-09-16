// To parse this JSON data, do
//
//     final lottoReleaseRequest = lottoReleaseRequestFromJson(jsonString);

import 'dart:convert';

LottoReleaseRequest lottoReleaseRequestFromJson(String str) => LottoReleaseRequest.fromJson(json.decode(str));

String lottoReleaseRequestToJson(LottoReleaseRequest data) => json.encode(data.toJson());

class LottoReleaseRequest {
    List<Lotto> lottos;

    LottoReleaseRequest({
        required this.lottos,
    });

    factory LottoReleaseRequest.fromJson(Map<String, dynamic> json) => LottoReleaseRequest(
        lottos: List<Lotto>.from(json["lottos"].map((x) => Lotto.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "lottos": List<dynamic>.from(lottos.map((x) => x.toJson())),
    };
}

class Lotto {
    String lottoNumber;
    int price;

    Lotto({
        required this.lottoNumber,
        required this.price,
    });

    factory Lotto.fromJson(Map<String, dynamic> json) => Lotto(
        lottoNumber: json["lotto_number"],
        price: json["price"],
    );

    Map<String, dynamic> toJson() => {
        "lotto_number": lottoNumber,
        "price": price,
    };
}
