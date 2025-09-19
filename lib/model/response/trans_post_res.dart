// To parse this JSON data, do
//
//     final transRes = transResFromJson(jsonString);

import 'dart:convert';

TransRes transResFromJson(String str) => TransRes.fromJson(json.decode(str));

String transResToJson(TransRes data) => json.encode(data.toJson());

class TransRes {
    bool success;
    String action;
    int uid;
    int transactionId;
    int newBalance;
    String type;

    TransRes({
        required this.success,
        required this.action,
        required this.uid,
        required this.transactionId,
        required this.newBalance,
        required this.type,
    });

    factory TransRes.fromJson(Map<String, dynamic> json) => TransRes(
        success: json["success"],
        action: json["action"],
        uid: json["uid"],
        transactionId: json["transaction_id"],
        newBalance: json["new_balance"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "action": action,
        "uid": uid,
        "transaction_id": transactionId,
        "new_balance": newBalance,
        "type": type,
    };
}
