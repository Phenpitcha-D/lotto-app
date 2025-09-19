// To parse this JSON data, do
//
//     final transReq = transReqFromJson(jsonString);

import 'dart:convert';

TransReq transReqFromJson(String str) => TransReq.fromJson(json.decode(str));

String transReqToJson(TransReq data) => json.encode(data.toJson());

class TransReq {
    int uid;
    int amount;
    String description;

    TransReq({
        required this.uid,
        required this.amount,
        required this.description,
    });

    factory TransReq.fromJson(Map<String, dynamic> json) => TransReq(
        uid: json["uid"],
        amount: json["amount"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "amount": amount,
        "description": description,
    };
}
