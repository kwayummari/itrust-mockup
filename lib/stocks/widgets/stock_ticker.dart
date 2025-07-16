import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

import '../../utility/number_fomatter.dart';

Widget stockTicker(companyName, tickerSymbol, change, price, volume, id) {
  return Container(
    decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor().bgLight))),
    child: ListTile(
      tileColor: AppColor().bgLight,
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      onTap: () {},
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              companyName,
              style: TextStyle(
                  fontFamily: "Poppins",
                  color: AppColor().textColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.clip),
            ),
          ),
          Text(
            "TZS ${currencyFormat(double.parse(price))}",
            style: TextStyle(
                fontFamily: "Poppins",
                color: AppColor().textColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tickerSymbol,
            style: TextStyle(color: AppColor().grayText),
          ),
          Text(
            id == "v" ? "Volume $volume" : "Change $change%",
            style: TextStyle(
                color: id == "v"
                    ? AppColor().grayText
                    : id == "g"
                        ? AppColor().success
                        : Colors.red),
          )
        ],
      ),
    ),
  );
}
