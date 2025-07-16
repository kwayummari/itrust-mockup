import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/IPO/magic_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget homeMenuIcon({appWidths, iconColor, bgColor, menuName, code, onClick}) {
  return SizedBox(
    child: Column(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                elevation: 5.0,
                backgroundColor: AppColor().constant),
            onPressed: onClick,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SvgPicture.asset(
                "assets/images/$code.svg",
                width: 30.0,
              ),
            )),
        // CircleAvatar(
        //   backgroundColor: bgColor,
        //   radius: appWidths * 0.07,
        //   child: Icon(
        //     icon,
        //     color: iconColor,
        //     size: 40.0,
        //   ),
        // ),
        Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: MagicText(text: menuName, fontSize: 12.0)),
      ],
    ),
  );
}

// Text(
//             menuName,
//             style: TextStyle(
//               fontFamily: "Poppins",
//               color: AppColor().textColor,
//               fontSize: 12.0,
//               // letterSpacing: 2
//             ),
//             textAlign: TextAlign.center,
//           )