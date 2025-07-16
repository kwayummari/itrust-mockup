class Stock {
  String? closePrice,
      deals,
      highPrice,
      lowPrice,
      openPrice,
      turnOver,
      price,
      volume,
      changeAmount,
      changePercentage,
      marketCap,
      date,
      fullname,
      logo,
      name,
      sector,
      stockID,
      description;
  // double?

  Stock(
      {required this.changeAmount,
      required this.changePercentage,
      required this.closePrice,
      required this.date,
      required this.deals,
      required this.fullname,
      required this.highPrice,
      required this.logo,
      required this.lowPrice,
      required this.marketCap,
      required this.name,
      required this.openPrice,
      required this.price,
      required this.sector,
      required this.stockID,
      required this.turnOver,
      required this.volume,
      required this.description});
}

// To parse this JSON data, do

// final allStockApiResponse = allStockApiResponseFromJson(jsonString);

// import 'dart:convert';

// AllStockApiResponse allStockApiResponseFromJson(String str) =>
//     AllStockApiResponse.fromJson(json.decode(str));

// String allStockApiResponseToJson(AllStockApiResponse data) =>
//     json.encode(data.toJson());

// class AllStockApiResponse {
//   List<Stock>? data;
//   int? code;

//   AllStockApiResponse({
//     this.data,
//     this.code,
//   });

//   factory AllStockApiResponse.fromJson(Map<String, dynamic> json) =>
//       AllStockApiResponse(
//         data: json["data"] == null
//             ? []
//             : List<Stock>.from(json["data"]!.map((x) => Stock.fromJson(x))),
//         code: json["code"],
//       );

//   Map<String, dynamic> toJson() => {
//         "data": data == null
//             ? []
//             : List<dynamic>.from(data!.map((x) => x.toJson())),
//         "code": code,
//       };
// }

// class Stock {
//   String? name;
//   String? fullname;
//   String? logo;
//   String? change;
//   String? id;
//   String? companyId;
//   String? symbol;
//   String? open;
//   String? prevClose;
//   String? close;
//   String? high;
//   String? low;
//   String? turnOver;
//   String? deals;
//   String? outStandingBId;
//   String? outStandingOffer;
//   String? volume;
//   String? mcap;
//   DateTime? date;
//   DateTime? systemDate;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   dynamic deletedAt;
//   String? price;
//   String? priceChangePercentage;
//   String? securityId;
//   int? priceChangeValue;
//   String? sector;
//   String? weekHigh;
//   String? weekLow;

//   Stock({
//     this.name,
//     this.fullname,
//     this.logo,
//     this.change,
//     this.id,
//     this.companyId,
//     this.symbol,
//     this.open,
//     this.prevClose,
//     this.close,
//     this.high,
//     this.low,
//     this.turnOver,
//     this.deals,
//     this.outStandingBId,
//     this.outStandingOffer,
//     this.volume,
//     this.mcap,
//     this.date,
//     this.systemDate,
//     this.createdAt,
//     this.updatedAt,
//     this.deletedAt,
//     this.price,
//     this.priceChangePercentage,
//     this.securityId,
//     this.priceChangeValue,
//     this.sector,
//     this.weekHigh,
//     this.weekLow,
//   });

//   factory Stock.fromJson(Map<String, dynamic> json) => Stock(
//         name: json["name"],
//         fullname: json["fullname"],
//         logo: json["logo"],
//         change: json["change"],
//         id: json["id"],
//         companyId: json["companyId"],
//         symbol: json["symbol"],
//         open: json["open"],
//         prevClose: json["prevClose"],
//         close: json["close"],
//         high: json["high"],
//         low: json["low"],
//         turnOver: json["turnOver"],
//         deals: json["deals"],
//         outStandingBId: json["outStandingBId"],
//         outStandingOffer: json["outStandingOffer"],
//         volume: json["volume"],
//         mcap: json["mcap"],
//         date: json["date"] == null ? null : DateTime.parse(json["date"]),
//         systemDate: json["systemDate"] == null
//             ? null
//             : DateTime.parse(json["systemDate"]),
//         createdAt: json["createdAt"] == null
//             ? null
//             : DateTime.parse(json["createdAt"]),
//         updatedAt: json["updatedAt"] == null
//             ? null
//             : DateTime.parse(json["updatedAt"]),
//         deletedAt: json["deletedAt"],
//         price: json["price"],
//         priceChangePercentage: json["priceChangePercentage"],
//         securityId: json["securityId"],
//         priceChangeValue: json["priceChangeValue"],
//         sector: json["sector"],
//         weekHigh: json["weekHigh"],
//         weekLow: json["weekLow"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "fullname": fullname,
//         "logo": logo,
//         "change": change,
//         "id": id,
//         "companyId": companyId,
//         "symbol": symbol,
//         "open": open,
//         "prevClose": prevClose,
//         "close": close,
//         "high": high,
//         "low": low,
//         "turnOver": turnOver,
//         "deals": deals,
//         "outStandingBId": outStandingBId,
//         "outStandingOffer": outStandingOffer,
//         "volume": volume,
//         "mcap": mcap,
//         "date":
//             "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
//         "systemDate":
//             "${systemDate!.year.toString().padLeft(4, '0')}-${systemDate!.month.toString().padLeft(2, '0')}-${systemDate!.day.toString().padLeft(2, '0')}",
//         "createdAt": createdAt?.toIso8601String(),
//         "updatedAt": updatedAt?.toIso8601String(),
//         "deletedAt": deletedAt,
//         "price": price,
//         "priceChangePercentage": priceChangePercentage,
//         "securityId": securityId,
//         "priceChangeValue": priceChangeValue,
//         "sector": sector,
//         "weekHigh": weekHigh,
//         "weekLow": weekLow,
//       };
// }
