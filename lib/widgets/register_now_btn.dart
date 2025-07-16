import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

Widget largeBTN(double width, String btnName, btncol, navigate) {
  return Padding(
    padding: const EdgeInsets.only(top: 12.0),
    child: MaterialButton(
      disabledColor: AppColor().inputFieldColor,
      disabledTextColor: AppColor().textColor,
      textColor: AppColor().constant,
      onPressed: navigate,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      minWidth: width,
      height: 56.0,
      color: btncol,
      child: Text(
        btnName,
        style: const TextStyle(
            fontFamily: "Poppins", fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget orderBtn(double width, double height, String btnName, btncol, navigate) {
  return Padding(
    padding: const EdgeInsets.only(top: 15.0),
    child: MaterialButton(
      onPressed: navigate,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
      minWidth: width,
      height: height,
      color: btncol,
      child: Text(
        btnName,
        style: TextStyle(
            fontFamily: "Poppins",
            color: AppColor().constant,
            fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget orderTypeBtn(
    double width, String btnName, btncol, borderColor, navigate) {
  return Padding(
    padding: const EdgeInsets.only(top: 15.0),
    child: MaterialButton(
      onPressed: navigate,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(8.0)),
      minWidth: width,
      height: 60.0,
      color: btncol,
      child: Text(
        btnName,
        style: TextStyle(
            fontFamily: "Poppins",
            color: AppColor().constant,
            fontSize: 18.0,
            fontWeight: FontWeight.w500),
      ),
    ),
  );
}
