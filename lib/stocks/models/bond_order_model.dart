import 'dart:convert';

/// Model for bond order request payload
BondOrderRequest bondOrderRequestFromJson(String str) =>
    BondOrderRequest.fromJson(json.decode(str));

String bondOrderRequestToJson(BondOrderRequest data) =>
    json.encode(data.toJson());

/// Model for bond order response
BondOrderResponse bondOrderResponseFromJson(String str) =>
    BondOrderResponse.fromJson(json.decode(str));

String bondOrderResponseToJson(BondOrderResponse data) =>
    json.encode(data.toJson());

class BondOrderRequest {
  final String bond;

  final double price;

  final double faceValue;

  final String notice;

  String paymentOption;

  BondOrderRequest({
    required this.bond,
    required this.price,
    required this.faceValue,
    required this.notice,
    required this.paymentOption,
  });

  factory BondOrderRequest.fromJson(Map<String, dynamic> json) =>
      BondOrderRequest(
        bond: json["bond"] as String,
        price: double.parse(json["price"] as String),
        faceValue: double.parse(json["face_value"] as String),
        notice: json["notice"] as String,
        paymentOption: json["paymentOption"] as String,
      );

  Map<String, dynamic> toJson() => {
        "bond": bond,
        "price": price.toString(),
        "face_value": faceValue.toString(),
        "notice": notice,
        "paymentOption": paymentOption,
      };
}

class BondOrderResponse {
  /// Response code
  final int code;

  /// Response message
  final String message;

  /// Response data containing purchase information
  final BondOrderData data;

  BondOrderResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory BondOrderResponse.fromJson(Map<String, dynamic> json) =>
      BondOrderResponse(
        code: json["code"] as int,
        message: json["message"] as String,
        data: BondOrderData.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data.toJson(),
      };
}

/// Contains purchase information from bond order response
class BondOrderData {
  /// Unique identifier for the purchase
  final String purchaseId;

  BondOrderData({
    required this.purchaseId,
  });

  factory BondOrderData.fromJson(Map<String, dynamic> json) => BondOrderData(
        purchaseId: json["purchaseId"] as String,
      );

  Map<String, dynamic> toJson() => {
        "purchaseId": purchaseId,
      };
}
