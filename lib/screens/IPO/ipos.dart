import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/ipo_card.dart';
import 'package:iwealth/screens/IPO/ipo_home.dart';
import 'package:iwealth/services/IPO/ipo_waiter.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';

class IPO extends StatefulWidget {
  const IPO({super.key});

  @override
  State<IPO> createState() => _IPOState();
}

class _IPOState extends State<IPO> {
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final mp = Provider.of<MarketProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: AppColor().stockCardColor,
        title: Text(
          "IPO",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: Container(
          padding: const EdgeInsets.all(10.0),
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          child: ListView(
            children: [
              ipoCard(
                  icon: Icons.ac_unit,
                  h: appHeight,
                  w: appWidth,
                  ipoHeader: "iTrust Funds",
                  onTapped: () {
                    pullIPOFundList(mp: mp);
                  },
                  context: context),
              ipoCard(
                  icon: Icons.payments_outlined,
                  h: appHeight,
                  w: appWidth,
                  ipoHeader: "Right Issues",
                  onTapped: () {},
                  context: context),
              ipoCard(
                  icon: Icons.mosque,
                  h: appHeight,
                  w: appWidth,
                  ipoHeader: "Sukuk Launch",
                  onTapped: () {},
                  context: context)
            ],
          )
          // child,
          ),
    );
  }

  void pullIPOFundList({required MarketProvider mp}) async {
    // if (mp.fundIPO.isEmpty || mp.ipoSubsc.isEmpty) {
    loading(context);

    var status = await IpoWaiter().getIPOFund(context: context, mp: mp);
    if (status == "success") {
      var sbsStatus =
          await IpoWaiter().getSubscriptionList(mp: mp, context: context);
      if (sbsStatus == "success") {
        await IpoWaiter().userSubscribed(mp: mp);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const IpoHome()));
      } else if (sbsStatus == "fail") {
        Navigator.pop(context);
        AppSnackbar(
          isError: true,
          response: "Something went wrong, Please try again",
        ).show(context);
      }
    } else if (status == "fail") {
      Navigator.pop(context);
      AppSnackbar(
        isError: true,
        response: "Something went wrong, Please try again",
      ).show(context);
    }
    // } else {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => const IpoHome()));
    // }
  }
}
