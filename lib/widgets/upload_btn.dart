import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

Widget uploadBTN(appHeight, appWidth, label, hint, filename, uploadFile) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: TextStyle(color: AppColor().textColor, fontSize: 18.0),
        ),
      ),
      filename == null
          ? MaterialButton(
              onPressed: uploadFile,
              height: appHeight * 0.1,
              minWidth: appWidth,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColor().grayText,
                  ),
                  borderRadius: BorderRadius.circular(5.0)),
              color: AppColor().blueBTN,
              child: Row(
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    color: AppColor().textColor,
                    size: 50.0,
                  ),
                  Text(
                    hint,
                    style: TextStyle(color: AppColor().textColor),
                  ),
                ],
              ),
            )
          : MaterialButton(
              onPressed: uploadFile,
              height: appHeight * 0.1,
              minWidth: appWidth,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColor().blueBTN),
                  borderRadius: BorderRadius.circular(5.0)),
              color: AppColor().blueBTN,
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: AppColor().success,
                    size: 50.0,
                  ),
                  SizedBox(
                    width: 200,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "$filename Selected, \n  ",
                          style: TextStyle(color: AppColor().textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          " click To Edit",
                          style: TextStyle(color: AppColor().textColor),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    ],
  );
}
