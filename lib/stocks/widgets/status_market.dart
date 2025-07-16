import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';

import 'package:flutter/material.dart';

Widget marketStatus(MarketProvider marketProvider, int index, appHeight,
    appWidth, currentSliderValue, onSliderChange) {
  return Container(
    padding: const EdgeInsets.all(8),
    color: AppColor().constant,
    // height: appHeight * 0.13,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        marketProvider.marketIndex.isNotEmpty
            ? Row(
                children: [
                  Text(
                    "${marketProvider.marketIndex[index].code}   ${marketProvider.marketIndex[index].closePrice}",
                    style: TextStyle(color: AppColor().textColor),
                  ),
                  Text(
                    "  |  ",
                    style: TextStyle(color: AppColor().blueBTN),
                  ),
                  Text("${marketProvider.marketIndex[index].change}%",
                      style: TextStyle(
                        color: double.parse(marketProvider
                                    .marketIndex[index].change
                                    .toString()) <
                                0
                            ? Colors.red
                            : AppColor().textColor,
                      )),
                ],
              )
            : Text(
                "",
                style: TextStyle(color: AppColor().textColor),
              ),
        MaterialButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: marketProvider.market == "closed"
                      ? Colors.red
                      : AppColor().success),
              borderRadius: BorderRadius.circular(4.0)),
          color: marketProvider.market == "closed"
              ? Colors.red
              : AppColor().success,
          child: Text(
            "Market is ${marketProvider.market}",
            style: TextStyle(color: AppColor().constant),
          ),
        )
      ],
    ),
  );
}
