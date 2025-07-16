import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: AppColor().mainColor,
      body: Container(
        padding: const EdgeInsets.all(8.0),
        height: appHeight,
        width: appWidth,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: Column(
          children: [
            Image.asset("assets/images/construction-removebg-preview.png"),
            Text(
              "Currently under construction. Soon, you'll enjoy the services. ",
              style: TextStyle(color: AppColor().textColor, fontSize: 18.0),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
