import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

Widget MagicText({required String text, required double fontSize}) {
  return RichText(
      text: TextSpan(children: [
    TextSpan(
        text: text[0],
        style: TextStyle(
            fontFamily: "Poppins",
            color: AppColor().orangeApp,
            fontSize: 12.0,
            fontWeight: FontWeight.w600
            // letterSpacing: 2
            ),
        children: [
          TextSpan(
            text: text.replaceRange(0, 1, ""),
            style: TextStyle(
              fontFamily: "Poppins",
              color: AppColor().blueBTN,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              // letterSpacing: 2
            ),
          )
        ])
  ]));
}
