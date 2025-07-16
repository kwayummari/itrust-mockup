import 'package:iwealth/stocks/models/performance.dart';
import 'package:iwealth/stocks/widgets/stock_ticker.dart';
import 'package:flutter/material.dart';

Widget marketMovers(List<MarketPerformance>? data, id) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ListView.builder(
        itemCount: data?.length,
        itemBuilder: (context, i) {
          return stockTicker(data?[i].name, data?[i].security, data?[i].change,
              data?[i].close, data?[i].volume, id);
        }),
  );
}
