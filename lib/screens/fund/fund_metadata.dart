import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

Widget fundMetadata({required String title, required String value}) {
  return ListTile(
    title: Text(
      title,
      style: TextStyle(color: AppColor().textColor),
    ),
    trailing: Text(
      value,
      style:
          TextStyle(color: AppColor().textColor, fontWeight: FontWeight.w600),
    ),
  );
}
