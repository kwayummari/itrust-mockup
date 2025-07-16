import 'dart:convert';

import 'package:flutter/material.dart';

BondOrdersResponse bondOrdersResponseFromJson(String str) =>
    BondOrdersResponse.fromJson(json.decode(str));

String bondOrdersResponseToJson(BondOrdersResponse data) =>
    json.encode(data.toJson());

class BondOrdersResponse {
  BondOrdersPage data;
  int code;

  BondOrdersResponse({
    required this.data,
    required this.code,
  });

  factory BondOrdersResponse.fromJson(Map<String, dynamic> json) =>
      BondOrdersResponse(
        data: BondOrdersPage.fromJson(json["data"]),
        code: json["code"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "code": code,
      };
}

class BondOrdersPage {
  int currentPage;
  List<BondOrder> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<BondPaginationLink> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  BondOrdersPage({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory BondOrdersPage.fromJson(Map<String, dynamic> json) => BondOrdersPage(
        currentPage: json["current_page"],
        data: List<BondOrder>.from(
            json["data"].map((x) => BondOrder.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"] ?? 0,
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: List<BondPaginationLink>.from(
            json["links"].map((x) => BondPaginationLink.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"] ?? 0,
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class BondOrder {
  String id;
  String vat;
  String cmsa;
  String dse;
  String cds;
  String totalFees;
  String brokerage;
  String payout;
  String faceValue;
  String price;
  String type;
  String amount;
  DateTime date;
  String status;
  String security;
  String marketType;
  dynamic traded;
  dynamic balance;

  BondOrder({
    required this.id,
    required this.vat,
    required this.cmsa,
    required this.dse,
    required this.cds,
    required this.totalFees,
    required this.brokerage,
    required this.payout,
    required this.faceValue,
    required this.price,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
    required this.security,
    required this.marketType,
    required this.traded,
    required this.balance,
  });

  factory BondOrder.fromJson(Map<String, dynamic> json) => BondOrder(
        id: json["id"],
        vat: json["vat"],
        cmsa: json["cmsa"],
        dse: json["dse"],
        cds: json["cds"],
        totalFees: json["total_fees"],
        brokerage: json["brokerage"],
        payout: json["payout"],
        faceValue: json["face_value"],
        price: json["price"],
        type: json["type"],
        amount: json["amount"],
        date: DateTime.parse(json["date"]),
        status: json["status"],
        security: json["security"],
        marketType: json["market_type"],
        traded: json["traded"],
        balance: json["balance"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vat": vat,
        "cmsa": cmsa,
        "dse": dse,
        "cds": cds,
        "total_fees": totalFees,
        "brokerage": brokerage,
        "payout": payout,
        "face_value": faceValue,
        "price": price,
        "type": type,
        "amount": amount,
        "date": date.toIso8601String(),
        "status": status,
        "security": security,
        "market_type": marketType,
        "traded": traded,
        "balance": balance,
      };

  // Helper to get a user-friendly status with color and icon
  Map<String, dynamic> getFriendlyStatus() {
    switch (status.toLowerCase()) {
      case 'new':
        return {
          'label': 'New',
          'color': Colors.blue,
          'icon': Icons.hourglass_top
        };
      case 'pending' || 'submitted':
        return {
          'label': 'Submitted',
          'color': Colors.blue,
          'icon': Icons.pending
        };
      case 'complete':
        return {
          'label': 'Complete',
          'color': Colors.green,
          'icon': Icons.check_circle
        };
      case 'cancelled':
        return {
          'label': 'Cancelled',
          'color': Colors.red,
          'icon': Icons.cancel
        };
      default:
        return {'label': status, 'color': Colors.blue, 'icon': Icons.info};
    }
  }
}

class BondPaginationLink {
  String? url;
  String label;
  bool active;

  BondPaginationLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory BondPaginationLink.fromJson(Map<String, dynamic> json) =>
      BondPaginationLink(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
