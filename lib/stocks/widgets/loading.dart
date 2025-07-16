import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

loading(context) {
  return showDialog(
      barrierColor: AppColor().selected,
      context: context,
      barrierDismissible: false,

      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColor().blueBTN,
          ),
        );
      });
}
