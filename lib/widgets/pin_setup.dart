import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/widgets/otp_one_field.dart';
import 'package:flutter/material.dart';

Widget fieldPIN(label, hint, inputType, width, valueCapture) {
  return Padding(
    padding: const EdgeInsets.only(top: 18.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            "Your 4 digit PIN will be used to login to the app, make payments, investments, etc. ",
            style: TextStyle(color: AppColor().grayText),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            label,
            style: TextStyle(
                color: AppColor().textColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          children: [
            oneField(width, inputType, valueCapture),
            oneField(width, inputType, valueCapture),
            oneField(width, inputType, valueCapture),
            oneField(width, inputType, valueCapture),
          ],
        ),
      ],
    ),
  );
}
