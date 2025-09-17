// To parse this JSON data, do
//
//     final userLottoBuyRequest = userLottoBuyRequestFromJson(jsonString);

import 'dart:convert';

UserLottoBuyRequest userLottoBuyRequestFromJson(String str) =>
    UserLottoBuyRequest.fromJson(json.decode(str));

String userLottoBuyRequestToJson(UserLottoBuyRequest data) =>
    json.encode(data.toJson());

class UserLottoBuyRequest {
  int lid;

  UserLottoBuyRequest({required this.lid});

  factory UserLottoBuyRequest.fromJson(Map<String, dynamic> json) =>
      UserLottoBuyRequest(lid: json["lid"]);

  Map<String, dynamic> toJson() => {"lid": lid};
}
