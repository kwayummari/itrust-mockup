// To parse this JSON data, do // // final stockPurchaseResponse = stockPurchaseResponseFromJson(jsonString);

import 'dart:convert';

StockPurchaseResponse stockPurchaseResponseFromJson(String str) =>
    StockPurchaseResponse.fromJson(json.decode(str));

String stockPurchaseResponseToJson(StockPurchaseResponse data) =>
    json.encode(data.toJson());

class StockPurchaseResponse {
  int code;
  String? status;
  String message;
  PurchaseData data;

  StockPurchaseResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory StockPurchaseResponse.fromJson(Map<String, dynamic> json) =>
      StockPurchaseResponse(
        code: json["code"],
        message: json["message"],
        data: PurchaseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data.toJson(),
      };
}

class PurchaseData {
  String? purchaseId;
  String? balance;
  String? requiredAmount;
  String? difference;

  PurchaseData({
    this.purchaseId,
    this.balance,
    this.requiredAmount,
    this.difference,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) => PurchaseData(
        purchaseId: json["purchaseId"],
        balance: json["Balance"],
        requiredAmount: json["Required"],
        difference: json["Difference"],
      );

  Map<String, dynamic> toJson() => {
        "purchaseId": purchaseId,
      };
}
