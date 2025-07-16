import 'dart:convert';

BondPortfolioSummary bondPortfolioSummaryFromJson(String str) =>
    BondPortfolioSummary.fromJson(json.decode(str));

String bondPortfolioSummaryToJson(BondPortfolioSummary data) =>
    json.encode(data.toJson());

class BondPortfolioSummary {
  bool? success;
  String? message;
  int? code;
  dynamic errors;
  String? timestamp;

  double wallet;
  double currentValue;
  double investedValue;
  double profitOrLoss;
  double profitOrLossPercentage;

  BondPortfolioSummary({
    this.success,
    this.message,
    this.code,
    this.errors,
    this.timestamp,
    required this.wallet,
    required this.currentValue,
    required this.investedValue,
    required this.profitOrLoss,
    required this.profitOrLossPercentage,
  });

  factory BondPortfolioSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return BondPortfolioSummary(
      success: json['success'],
      message: json['message'],
      code: json['code'],
      errors: json['errors'],
      timestamp: json['timestamp'],
      wallet: _parseDouble(data["wallet"]),
      currentValue: _parseDouble(data["current_value"]),
      investedValue: _parseDouble(data["invested_value"]),
      profitOrLoss: _parseDouble(data["profit_or_loss"]),
      profitOrLossPercentage: _parseDouble(data["profit_or_loss_percentage"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "code": code,
        "errors": errors,
        "timestamp": timestamp,
        "data": {
          "wallet": wallet,
          "current_value": currentValue,
          "invested_value": investedValue,
          "profit_or_loss": profitOrLoss,
          "profit_or_loss_percentage": profitOrLossPercentage,
        }
      };
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
