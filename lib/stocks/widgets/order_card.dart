import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/stocks/orders/details_order.dart';
import 'package:flutter/material.dart';

import '../models/order.dart';

Widget orderCard( BuildContext context,Order order) {
  String status = order.status ?? 'unknown';
  return Container(
    margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
    decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor().inputFieldColor))),
    child: ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetails(
                      order:order,
                    )));
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            order.stockName ?? '',
            style: TextStyle(color: AppColor().textColor),
          ),
          Text(
            order.payout ?? '',
            style: TextStyle(color: AppColor().textColor),
          )
        ],
      ),
      subtitle: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
            child: Row(
              children: [
                Text(
                  order.date ?? '',
                  style: TextStyle(color: AppColor().grayText),
                ),
                const Spacer(),
                Text(
                  order.price ?? '',
                  style: TextStyle(color: AppColor().grayText),
                )
              ],
            ),
          ),
          Row(
            children: [
              Text(
                order.orderType == "buy" ? "BUY " : "SELL",
                style: TextStyle(
                    color: order.orderType == "buy"
                        ? AppColor().blueBTN
                        : order.orderType != "buy"
                            ? AppColor().orangeApp
                            : AppColor().inputFieldColor),
              ),
              Text(
                "| ${order.executed}/${order.volume} | ${order.mode}",
                style: TextStyle(color: AppColor().grayText),
              ),
              const Spacer(),
              Text(
                status == "new"
                    ? "RECEIVED"
                    : status == "pending"
                        ? "PLACED"
                        : status == "approved"
                            ? "EXECUTING"
                            : status == "complete"
                                ? "COMPLETE"
                                : status == "rejected"
                                    ? "REJECTED"
                                    : "UNKNOWN",
                style: TextStyle(
                    color: status == "new"
                        ? AppColor().blueBTN
                        : status == "complete"
                            ? AppColor().success
                            : status == "rejected"
                                ? Colors.red
                                : status == "pending"
                                    ? Colors.amber
                                    : status == "approved"
                                        ? Colors.cyan
                                        : AppColor().inputFieldColor),
              ),
            ],
          )
        ],
      ),
    ),
  );
}
