import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppColor {
  Color mainColor = const Color(0xffFFFFFF); // const Color(0xff040b12);
  Color textColor = const Color(0xff000000); // const Color(0xffFFFFFF);p
  Color grayText = const Color(0xff919AAA);
  Color neutralTextMedium = const Color(0xff565656);
  Color divider = const Color(0xffEBEBEB);
  Color blueBTN = const Color(0xFF0C5080);
  Color primaryBlue = const Color(0xff1A82CF);
  Color inputFieldColor = const Color.fromRGBO(117, 117, 117, 0.1);
  Color orangeApp = const Color(0xffE54C25);
  Color lowerBg = const Color.fromRGBO(175, 192, 204, 0.13);
  Color gang = const Color(0xff0e314a);
  Color success = Colors.green;
  Color selected = const Color.fromARGB(120, 22, 54, 80);
  Color constant = const Color(0xffFFFFFF);
  Color bgLight = const Color(0xffFFFFFF);
  Color stockCardColor = const Color.fromARGB(255, 204, 226, 243);
  Color pinColor = const Color.fromARGB(30, 12, 87, 148);
  Color tagColor = const Color(0xffA3CDEC);
  Color cardColor = const Color.fromARGB(255, 220, 234, 237);
  Color portfolio = const Color(0xff0C5080);
  Color cardBottom = const Color(0xff125B91);
  Color transparent = Colors.transparent;
  Color black = HexColor('#000000');
  Color white = HexColor('#ffffff');
  Color gray = const Color.fromRGBO(117, 117, 117, 0.1);
  Color blueText = HexColor('#1A82CF');

// Define the gradient as a constant
  LinearGradient appGradient = const LinearGradient(
    colors: [
      Color(0xffFFF4EA),
      Color(0xffE2F5FE) // End color
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
