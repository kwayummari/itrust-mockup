// To parse JSON data for bond order cost breakdown
import 'dart:convert';

/// Model for bond order cost breakdown
BondOrderCostBreakdown bondOrderCostBreakdownFromJson(String str) =>
    BondOrderCostBreakdown.fromJson(json.decode(str));

/// Convert bond order cost breakdown to JSON string
String bondOrderCostBreakdownToJson(BondOrderCostBreakdown data) =>
    json.encode(data.toJson());

/// Represents the cost breakdown for a bond order
class BondOrderCostBreakdown {
  /// Dar es Salaam Stock Exchange fee
  final String dse;

  /// Capital Markets and Securities Authority fee
  final String cmsa;

  /// Central Depository System fee
  final String cds;

  /// Value Added Tax
  final String vat;

  /// Brokerage fee
  final String brokerage;

  /// Total of all fees
  final String totalFees;

  /// Total cost including fees
  final String total;

  /// Final payout amount
  final String payout;

  BondOrderCostBreakdown({
    required this.dse,
    required this.cmsa,
    required this.cds,
    required this.vat,
    required this.brokerage,
    required this.totalFees,
    required this.total,
    required this.payout,
  });

  factory BondOrderCostBreakdown.fromJson(Map<String, dynamic> json) =>
      BondOrderCostBreakdown(
        dse: json["dse"],
        cmsa: json["cmsa"],
        cds: json["cds"],
        vat: json["vat"],
        brokerage: json["brokerage"],
        totalFees: json["total_fees"],
        total: json["total"],
        payout: json["payout"],
      );

  Map<String, dynamic> toJson() => {
        "dse": dse,
        "cmsa": cmsa,
        "cds": cds,
        "vat": vat,
        "brokerage": brokerage,
        "total_fees": totalFees,
        "total": total,
        "payout": payout,
      };
}
