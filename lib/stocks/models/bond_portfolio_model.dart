import 'dart:convert';

BondListResponse bondListResponseFromJson(String str) =>
    BondListResponse.fromJson(json.decode(str));

String bondListResponseToJson(BondListResponse data) =>
    json.encode(data.toJson());

class BondListResponse {
  List<MyBond> bonds;
  int statusCode;

  BondListResponse({
    required this.bonds,
    required this.statusCode,
  });

  factory BondListResponse.fromJson(Map<String, dynamic> json) =>
      BondListResponse(
        bonds: List<MyBond>.from(json["data"].map((x) => MyBond.fromJson(x))),
        statusCode: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(bonds.map((x) => x.toJson())),
        "code": statusCode,
      };
}

class MyBond {
  String bondName;
  String couponRate;
  String market;
  DateTime maturityDate;
  String bondType;
  String bondId;
  int faceValue;

  MyBond({
    required this.bondName,
    required this.couponRate,
    required this.market,
    required this.maturityDate,
    required this.bondType,
    required this.bondId,
    required this.faceValue,
  });

  factory MyBond.fromJson(Map<String, dynamic> json) => MyBond(
        bondName: json["bond"],
        couponRate: json["coupon"],
        market: json["market"],
        maturityDate: DateTime.parse(json["maturity_date"]),
        bondType: json["type"],
        bondId: json["bond_id"],
        faceValue: json["face_value"],
      );

  Map<String, dynamic> toJson() => {
        "bond": bondName,
        "coupon": couponRate,
        "market": market,
        "maturity_date":
            "${maturityDate.year.toString().padLeft(4, '0')}-${maturityDate.month.toString().padLeft(2, '0')}-${maturityDate.day.toString().padLeft(2, '0')}",
        "type": bondType,
        "bond_id": bondId,
        "face_value": faceValue,
      };
}
