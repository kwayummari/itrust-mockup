import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

Widget oneField(width, inputType, valueCapture) {
  return Container(
    margin: const EdgeInsets.only(right: 8.0, bottom: 10.0),
    width: width,
    child: TextFormField(
      onChanged: valueCapture,
      keyboardType: inputType,
      style: TextStyle(
        color: AppColor().textColor,
      ),
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12),
          hintText: "",
          hintStyle: TextStyle(color: AppColor().grayText),
          fillColor: AppColor().inputFieldColor,
          counterText: "",
          filled: true),
      maxLength: 1,
    ),
  );
}
