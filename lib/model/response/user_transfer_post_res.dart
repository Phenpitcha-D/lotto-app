// To parse this JSON data, do
//
//     final transferRes = transferResFromJson(jsonString);

import 'dart:convert';

TransferRes transferResFromJson(String str) => TransferRes.fromJson(json.decode(str));

String transferResToJson(TransferRes data) => json.encode(data.toJson());

class TransferRes {
    bool success;
    String message;
    From from;
    From to;
    int amount;

    TransferRes({
        required this.success,
        required this.message,
        required this.from,
        required this.to,
        required this.amount,
    });

    factory TransferRes.fromJson(Map<String, dynamic> json) => TransferRes(
        success: json["success"],
        message: json["message"],
        from: From.fromJson(json["from"]),
        to: From.fromJson(json["to"]),
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "from": from.toJson(),
        "to": to.toJson(),
        "amount": amount,
    };
}

class From {
    int uid;
    int newBalance;
    int transactionId;

    From({
        required this.uid,
        required this.newBalance,
        required this.transactionId,
    });

    factory From.fromJson(Map<String, dynamic> json) => From(
        uid: json["uid"],
        newBalance: json["new_balance"],
        transactionId: json["transaction_id"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "new_balance": newBalance,
        "transaction_id": transactionId,
    };
}
