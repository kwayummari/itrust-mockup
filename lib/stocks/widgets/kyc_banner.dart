import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:flutter/material.dart';

Widget kycBanner(appHeight, appWidth, metadataProvider, msg, borderColor,
    btnTxt, bool rotate, btnPressed) {
  return Container(
    margin: const EdgeInsets.only(top: 10.0),
    height: appHeight * 0.11,
    width: appWidth,
    decoration: BoxDecoration(
        color: AppColor().inputFieldColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10.0)),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.info,
            color: borderColor,
          ),
          SizedBox(
            width: appWidth * 0.5,
            child: Text(
              "Hi ${SessionPref.getUserProfile()?[0]}, $msg",
              style: TextStyle(color: AppColor().textColor, fontSize: 12.0),
              overflow: TextOverflow.clip,
            ),
          ),
          MaterialButton(
            onPressed: btnPressed,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColor().blueBTN),
                borderRadius: BorderRadius.circular(5.0)),
            color: borderColor,
            child: Row(
              children: [
                Text(
                  btnTxt,
                  style: TextStyle(color: AppColor().textColor),
                ),
                rotate
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: AppColor().textColor,
                          ),
                        ),
                      )
                    : const Text("")
              ],
            ),
          )
        ],
      ),
    ),
  );
}
