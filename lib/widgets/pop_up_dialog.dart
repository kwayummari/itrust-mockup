import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

Future popUpDialog(msg, btnTxt, txtColor, IconData icon, clickMe, context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor().bgLight,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: txtColor,
              ),
              Text(
                msg,
                style: TextStyle(color: txtColor),
              )
            ],
          ),
          actions: [TextButton(onPressed: clickMe, child: Text(btnTxt))],
        );
      });
}

Future circularPopUp(context) {
  return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AlertDialog(
          // backgroundColor: AppColor().mainColor,
          content: Center(
            child: CircularProgressIndicator(),
          ),
        );
      });
}
