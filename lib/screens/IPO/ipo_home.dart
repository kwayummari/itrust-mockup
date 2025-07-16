import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/IPO/ipo_desc.dart';
import 'package:iwealth/screens/IPO/subscription.dart';
import 'package:flutter/material.dart';

class IpoHome extends StatefulWidget {
  const IpoHome({super.key});

  @override
  State<IpoHome> createState() => _IpoHomeState();
}

class _IpoHomeState extends State<IpoHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor().bgLight,
            title: Text(
              "iTrust IPO Funds",
              style: TextStyle(color: AppColor().textColor),
            ),
            actions: const [],
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColor().textColor,
                )),
            bottom: TabBar(
                indicatorColor: AppColor().blueBTN,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3.0,
                unselectedLabelColor: AppColor().textColor,
                labelColor: AppColor().blueBTN,
                dividerColor: AppColor().grayText,
                tabs: const [
                  Tab(
                      child: Text(
                    "Funds",
                    style: TextStyle(fontSize: 18.0),
                  )),
                  Tab(
                    child: Text(
                      "My Subscriptions",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: <Widget>[
            IPODescriptionScreen(tile: "iTrust Funds IPO"),
            IPOSubscriptionListScreen(
              subsData: const [],
            )
          ]),
        ));
  }
}
