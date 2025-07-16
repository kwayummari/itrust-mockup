import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/contributions_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FundOrderScreen extends StatefulWidget {
  const FundOrderScreen({super.key});

  @override
  State<FundOrderScreen> createState() => _FundOrderScreenState();
}

class _FundOrderScreenState extends State<FundOrderScreen> {
  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor().bgLight,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColor().textColor,
                )),
            title: Text(
              "Subscriptions",
              style: TextStyle(color: AppColor().textColor),
            ),
            bottom: TabBar(
                indicatorColor: AppColor().blueBTN,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3.0,
                unselectedLabelColor: AppColor().grayText,
                labelColor: AppColor().blueBTN,
                dividerColor: AppColor().grayText,
                tabs: const [
                  Tab(
                      child: Text(
                    "Contributions",
                    style: TextStyle(fontSize: 18.0),
                  )),
                  Tab(
                    child: Text(
                      "Redemptions",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: <Widget>[
            Contributions(
              mp: mp.fundOrders,
            ),
            Contributions(mp: mp.fundRedemptionOrder)
          ]),
        ));
  }
}
