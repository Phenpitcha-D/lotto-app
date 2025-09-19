// To parse this JSON data, do
//
//     final transferReq = transferReqFromJson(jsonString);

import 'dart:convert';

TransferReq transferReqFromJson(String str) => TransferReq.fromJson(json.decode(str));

String transferReqToJson(TransferReq data) => json.encode(data.toJson());

class TransferReq {
    String toUsername;
    int amount;
    String description;

    TransferReq({
        required this.toUsername,
        required this.amount,
        required this.description,
    });

    factory TransferReq.fromJson(Map<String, dynamic> json) => TransferReq(
        toUsername: json["toUsername"],
        amount: json["amount"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "toUsername": toUsername,
        "amount": amount,
        "description": description,
    };
}
