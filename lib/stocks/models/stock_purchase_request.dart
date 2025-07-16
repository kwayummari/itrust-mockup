import 'dart:convert';

StockPurchase stockPurchaseFromJson(String str) =>
    StockPurchase.fromJson(json.decode(str));

String stockPurchaseToJson(StockPurchase data) => json.encode(data.toJson());

class StockPurchase {
  String useCustodian;
  String price;
  String volume;
  String type;
  String securityId;
  String mode;
  String? paymentOption;
  String? mobile;

  StockPurchase({
    required this.useCustodian,
    required this.price,
    required this.volume,
    required this.type,
    required this.securityId,
    required this.mode,
    this.paymentOption,
    this.mobile,
  });

  factory StockPurchase.fromJson(Map<String, dynamic> json) => StockPurchase(
        useCustodian: json["use_custodian"],
        price: json["price"],
        volume: json["volume"],
        type: json["type"],
        securityId: json["security_id"],
        mode: json["mode"],
        paymentOption: json["paymentOption"],
        mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() {
    final map = {
      "use_custodian": useCustodian,
      "price": price,
      "volume": volume,
      "type": type,
      "securityId": securityId,
      "mode": mode,
    };
    if (paymentOption != null) map["paymentOption"] = paymentOption!;
    if (mobile != null) map["mobile"] = mobile!;
    return map;
  }
}
