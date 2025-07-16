import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';

Widget stockCard(MarketProvider snapshot, i, appWidth) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColor().grayText, width: 0.2),
      color: AppColor().stockCardColor,
      borderRadius: BorderRadius.circular(10.0),
    ),
    margin: const EdgeInsets.only(right: 10.0),
    padding: const EdgeInsets.all(8.0),
    width: appWidth * 0.85,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(
            children: [
              CircleAvatar(
                child: Image.asset(
                    "assets/images/tickerLogo/${snapshot.stock?[i].name}.jpg"),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${snapshot.stock?[i].name}",
                    style: TextStyle(
                        color: AppColor().textColor,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Last retrieved on ${snapshot.stock?[i].date}",
                    style: TextStyle(color: AppColor().selected),
                  )
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 12.0,
            top: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last Trading Price",
                    style: TextStyle(color: AppColor().grayText),
                  ),
                  Text(
                    "TZS ${currencyFormat(double.parse("${snapshot.stock?[i].openPrice}"))}",
                    style:
                        TextStyle(color: AppColor().textColor, fontSize: 16.0),
                  )
                ],
              ),
              const VerticalDivider(),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Change",
                    style: TextStyle(color: AppColor().grayText),
                  ),
                  Text(
                    " TZS ${snapshot.stock?[i].changeAmount}(${snapshot.stock?[i].changePercentage}%)",
                    style: TextStyle(
                        color:
                            int.parse("${snapshot.stock?[i].changeAmount}") >= 0
                                ? AppColor().success
                                : Colors.red,
                        fontSize: 14.0),
                  )
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
}
