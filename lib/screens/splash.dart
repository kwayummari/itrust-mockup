import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/services/auth/toggle.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Toggle()));
    });
    final double appHeight = MediaQuery.of(context).size.height;
    final double appWidht = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: appHeight,
        width: appWidht,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    "assets/images/young-afro-man-listening-music-with-headphones.jpg"),
                fit: BoxFit.fill)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Pay and transfer money easily",
                style: TextStyle(
                    fontFamily: "Poppins",
                    color: AppColor().textColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Make and accept contactless payment using wallet",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 15.0,
                      color: AppColor().grayText,
                      fontWeight: FontWeight.w800)),
            )
          ],
        ),
      ),
    );
  }
}
