import 'dart:convert';

BondResponse bondResponseFromJson(String str) =>
    BondResponse.fromJson(json.decode(str));

String bondResponseToJson(BondResponse data) => json.encode(data.toJson());

class BondResponse {
  final List<Bond> bonds;
  final int? code;

  BondResponse({
    required this.bonds,
    this.code,
  });

  factory BondResponse.fromJson(Map<String, dynamic> json) => BondResponse(
        bonds: json["data"] != null
            ? List<Bond>.from(json["data"].map((x) => Bond.fromJson(x)))
            : [],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(bonds.map((x) => x.toJson())),
        "code": code,
      };
}

class Bond {
  final String? id;
  final double? yield;
  final String? isin;
  final String? couponFrequency;
  final double coupon;
  final int tenure;
  final DateTime? issueDate;
  final DateTime? maturityDate;
  final int issuedAmount;
  final BondType type;
  final String? securityName;
  final BondMarket market;
  final BondCategory category;
  final double yieldToMaturity;
  final double price;
  final int? reopened;
  final String? logoUrl;
  final String? accruedInterest;
  final DateTime? couponDateOne;
  final DateTime? couponDateTwo;
  final DateTime? couponDateThree;
  final DateTime? couponDateFour;
  final int minBidAmount;
  final TaxStatus taxStatus;
  final double pricing;

  Bond({
    this.id,
    this.yield,
    this.isin,
    this.couponFrequency,
    required this.coupon,
    required this.tenure,
    this.issueDate,
    this.maturityDate,
    required this.issuedAmount,
    required this.type,
    this.securityName,
    required this.market,
    required this.category,
    required this.yieldToMaturity,
    required this.price,
    this.reopened,
    this.logoUrl,
    this.accruedInterest,
    this.couponDateOne,
    this.couponDateTwo,
    this.couponDateThree,
    this.couponDateFour,
    required this.minBidAmount,
    required this.taxStatus,
    required this.pricing,
  });

  factory Bond.fromJson(Map<String, dynamic> json) => Bond(
        id: json["id"]?.toString(),
        yield: json["yield"] == null
            ? null
            : double.tryParse(json["yield"].toString()),
        isin: json["isin"]?.toString(),
        couponFrequency: json["coupon_frequency"]?.toString(),
        coupon: double.tryParse(json["coupon"]?.toString() ?? '') ?? 0.0,
        tenure: int.tryParse(json["tenure"]?.toString() ?? '') ?? 0,
        issueDate: json["issue_date"] != null
            ? DateTime.tryParse(json["issue_date"])
            : null,
        maturityDate: json["maturity_date"] != null
            ? DateTime.tryParse(json["maturity_date"])
            : null,
        issuedAmount:
            int.tryParse(json["issued_amount"]?.toString() ?? '') ?? 0,
        type: bondTypeMapper.map[json["type"]] ?? BondType.corporate,
        securityName: json["security_name"]?.toString(),
        market: bondMarketMapper.map[json["market"]] ?? BondMarket.secondary,
        category: bondCategoryMapper.map[json["category"]] ?? BondCategory.bond,
        yieldToMaturity:
            double.tryParse(json["yield_time_maturity"]?.toString() ?? '') ??
                0.0,
        price: double.tryParse(json["price"]?.toString() ?? '') ?? 0.0,
        reopened: json["reopened"],
        logoUrl: json["url_logo"]?.toString(),
        accruedInterest: json["accrued_interest"] == "null"
            ? null
            : json["accrued_interest"]?.toString(),
        couponDateOne: json["coupon_date_one"] == "0000-00-00"
            ? null
            : DateTime.tryParse(json["coupon_date_one"] ?? ''),
        couponDateTwo: json["coupon_date_two"] == "0000-00-00"
            ? null
            : DateTime.tryParse(json["coupon_date_two"] ?? ''),
        couponDateThree: json["coupon_date_three"] == "0000-00-00"
            ? null
            : DateTime.tryParse(json["coupon_date_three"] ?? ''),
        couponDateFour: json["coupon_date_four"] == "0000-00-00"
            ? null
            : DateTime.tryParse(json["coupon_date_four"] ?? ''),
        minBidAmount: json["min_bid_amount"],
        taxStatus: taxStatusMapper.map[json["taxable"]] ?? TaxStatus.no,
        pricing: double.tryParse(json["pricing"]?.toString() ?? '') ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "yield": yield,
        "isin": isin,
        "coupon_frequency": couponFrequency,
        "coupon": coupon,
        "tenure": tenure,
        "issue_date": issueDate?.toIso8601String(),
        "maturity_date": maturityDate?.toIso8601String(),
        "issued_amount": issuedAmount,
        "type": bondTypeMapper.reverse[type],
        "security_name": securityName,
        "market": bondMarketMapper.reverse[market],
        "category": bondCategoryMapper.reverse[category],
        "yield_time_maturity": yieldToMaturity,
        "price": price,
        "reopened": reopened,
        "url_logo": logoUrl,
        "accrued_interest": accruedInterest,
        "coupon_date_one": couponDateOne?.toIso8601String(),
        "coupon_date_two": couponDateTwo?.toIso8601String(),
        "coupon_date_three": couponDateThree?.toIso8601String(),
        "coupon_date_four": couponDateFour?.toIso8601String(),
        "min_bid_amount": minBidAmount,
        "taxable": taxStatusMapper.reverse[taxStatus],
        "pricing": pricing,
      };
}

enum BondCategory { bond }

final bondCategoryMapper = EnumMapper({
  "bond": BondCategory.bond,
});

enum BondMarket { secondary }

final bondMarketMapper = EnumMapper({
  "secondary": BondMarket.secondary,
});

enum TaxStatus { no, yes }

final taxStatusMapper = EnumMapper({
  "No": TaxStatus.no,
  "Yes": TaxStatus.yes,
});

enum BondType { corporate, government }

final bondTypeMapper = EnumMapper({
  "corporate": BondType.corporate,
  "government": BondType.government,
});

class EnumMapper<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumMapper(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
