// To parse this JSON data, do
//
//     final rewardResultResponse = rewardResultResponseFromJson(jsonString);

import 'dart:convert';

RewardResultResponse rewardResultResponseFromJson(String str) =>
    RewardResultResponse.fromJson(json.decode(str));

String rewardResultResponseToJson(RewardResultResponse data) =>
    json.encode(data.toJson());

class RewardResultResponse {
  bool success;
  List<Result> results;
  Special special;

  RewardResultResponse({
    required this.success,
    required this.results,
    required this.special,
  });

  factory RewardResultResponse.fromJson(Map<String, dynamic> json) =>
      RewardResultResponse(
        success: json["success"],
        results: List<Result>.from(
          json["results"].map((x) => Result.fromJson(x)),
        ),
        special: Special.fromJson(json["special"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "special": special.toJson(),
  };
}

class Result {
  int bid;
  String lottoNumber;
  int bounty;
  int bountyRank;
  String drawDate;

  Result({
    required this.bid,
    required this.lottoNumber,
    required this.bounty,
    required this.bountyRank,
    required this.drawDate,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    bid: json["bid"],
    lottoNumber: json["lotto_number"],
    bounty: json["bounty"],
    bountyRank: json["bounty_rank"],
    drawDate: json["draw_date"],
  );

  Map<String, dynamic> toJson() => {
    "bid": bid,
    "lotto_number": lottoNumber,
    "bounty": bounty,
    "bounty_rank": bountyRank,
    "draw_date": drawDate,
  };
}

class Special {
  Special();

  factory Special.fromJson(Map<String, dynamic> json) => Special();

  Map<String, dynamic> toJson() => {};
}
