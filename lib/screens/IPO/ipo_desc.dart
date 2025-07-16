import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/constants/texts.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/ipo_card.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/screens/fund/old_fund_details.dart';
import 'package:provider/provider.dart';

class IPODescriptionScreen extends StatefulWidget {
  String tile;

  IPODescriptionScreen({super.key, required this.tile});

  @override
  State<IPODescriptionScreen> createState() => _IPODescriptionScreenState();
}

class _IPODescriptionScreenState extends State<IPODescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final mp = Provider.of<MarketProvider>(context);
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColor().stockCardColor,
      //   leading: IconButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //       },
      //       icon: Icon(
      //         Icons.arrow_back_ios,
      //         color: AppColor().textColor,
      //       )),
      //   title: Text(
      //     widget.tile,
      //     style: TextStyle(color: AppColor().textColor),
      //   ),
      // ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        height: appHeight,
        width: appWidth,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              "Thank You For Your Interest",
              style: TextStyle(
                  color: AppColor().textColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                Words().fundsIPOWelcome,
                style: TextStyle(color: AppColor().textColor),
                textAlign: TextAlign.justify,
              ),
            ),
            for (var i = 0; i < mp.fundIPO.length; i++)
              ipoProduct(
                  productTitle: mp.fundIPO[i].name,
                  productDesc: mp.fundIPO[i].category,
                  whenTapped: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FundDetailsScreen(
                                  accountNumber: mp.fundIPO[i].accountNumber,
                                  description: mp.fundIPO[i].description,
                                  launchOn: mp.fundIPO[i].openDate,
                                  exitFee: mp.fundIPO[i].exitFee,
                                  category: mp.fundIPO[i].category,
                                  entryFee: mp.fundIPO[i].entryFee,
                                  fundName: mp.fundIPO[i].name,
                                  minInv: mp.fundIPO[i].minInitContribution,
                                  nav: mp.fundIPO[i].nav,
                                  percentgain: "0",
                                  subsPrice: mp.fundIPO[i].subsequentAmount,
                                  fundCode: mp.fundIPO[i].fundCode,
                                  ipoid: mp.fundIPO[i].id,
                                )));
                  }),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
              child: Text(
                "Next Steps:",
                style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                Words().fundNextStep,
                style: TextStyle(color: AppColor().textColor),
                textAlign: TextAlign.justify,
              ),
            )
          ],
        ),
      ),
    );
  }
}
