import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:flutter/material.dart';

Widget kycStep1(nida, passport, test) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Hi ${SessionPref.getUserProfile()?[0]}, Please complete KYC by uploading and verifying one of the document below.",
        style: TextStyle(color: AppColor().grayText, fontSize: 18),
      ),
      Center(child: Image.asset("assets/images/profile.gif")),
      Text("Choose a document to verify your ID",
          style: TextStyle(color: AppColor().textColor, fontSize: 18.0)),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "NIDA Number(National Identification Authority) Also known as Tanzania National ID Number",
          style: TextStyle(color: AppColor().grayText, fontSize: 15.0),
        ),
      ),
      MaterialButton(
        onPressed: nida,
        height: 70.0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor().inputFieldColor),
            borderRadius: BorderRadius.circular(15.0)),
        color: AppColor().inputFieldColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // ,
          children: [
            Icon(
              Icons.fingerprint,
              color: AppColor().grayText,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "NIDA",
              style: TextStyle(color: AppColor().textColor),
            ),
            // Icon(Icons.arrow_forward_ios, color: AppColor().textColor,)
          ],
        ),
      ),
      const SizedBox(
        height: 30,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Passport Number and Document",
          style: TextStyle(color: AppColor().grayText),
        ),
      ),
      MaterialButton(
        onPressed: passport,
        height: 70.0,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColor().inputFieldColor),
            borderRadius: BorderRadius.circular(15.0)),
        color: AppColor().inputFieldColor,
        child: Row(
          children: [
            Icon(
              Icons.description,
              color: AppColor().grayText,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Passport",
              style: TextStyle(color: AppColor().textColor),
            ),
          ],
        ),
      )
    ],
  );
}
