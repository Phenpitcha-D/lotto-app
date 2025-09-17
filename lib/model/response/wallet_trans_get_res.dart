// To parse this JSON data, do
//
//     final walletTransRespon = walletTransResponFromJson(jsonString);

import 'dart:convert';

List<WalletTransRespon> walletTransResponFromJson(String str) => List<WalletTransRespon>.from(json.decode(str).map((x) => WalletTransRespon.fromJson(x)));

String walletTransResponToJson(List<WalletTransRespon> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WalletTransRespon {
    int transactionId;
    int uid;
    String type;
    String description;
    int amount;
    String createdAt;

    WalletTransRespon({
        required this.transactionId,
        required this.uid,
        required this.type,
        required this.description,
        required this.amount,
        required this.createdAt,
    });

    factory WalletTransRespon.fromJson(Map<String, dynamic> json) => WalletTransRespon(
        transactionId: json["transaction_id"],
        uid: json["uid"],
        type: json["type"],
        description: json["description"],
        amount: json["amount"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "uid": uid,
        "type": type,
        "description": description,
        "amount": amount,
        "created_at": createdAt,
    };
}
