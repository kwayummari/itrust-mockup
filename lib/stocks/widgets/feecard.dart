import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

Widget feeCard({required infoName, required infoData, required infoFontSize}) {
  return ListTile(
    title: Text(
      infoName,
      style: TextStyle(color: AppColor().grayText),
    ),
    trailing: Text(
      infoData,
      style: TextStyle(color: AppColor().textColor, fontSize: infoFontSize),
    ),
  );
}

Widget largeFeeCard(
    {required infoName,
    required infoData,
    required subInfo,
    required infoFontSize}) {
  return ListTile(
    title: Text(
      infoName,
      style: TextStyle(color: AppColor().textColor, fontSize: 12.0),
    ),
    trailing: Text(
      infoData,
      style: TextStyle(color: AppColor().textColor, fontSize: 12.0),
    ),
    subtitle: Text(
      subInfo,
      style: TextStyle(color: AppColor().grayText),
    ),
  );
}
