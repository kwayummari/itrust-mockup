import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/fund/subscription.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Contributions extends StatefulWidget {
  List<Subscription> mp;
  Contributions({super.key, required this.mp});

  @override
  State<Contributions> createState() => _ContributionsState();
}

class _ContributionsState extends State<Contributions> {
  final currFormat = NumberFormat("#,##0.00", "en_US");
  void getFund(MarketProvider marketProvider) async {
    var subscriptioStatus =
        await StockWaiter().getFundOrders(mp: marketProvider, context: context);

    if (subscriptioStatus == "1") {
      if (kDebugMode) {
        print("Pulled");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final mp = Provider.of<MarketProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          getFund(mp);
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: AppColor().stockCardColor),
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: AppColor().constant,
              ),
              itemCount: widget.mp.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.mp[i].fundName,
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        currencyFormat(double.parse(widget.mp[i].amount)),
                        style: TextStyle(color: AppColor().textColor),
                      )
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.mp[i].date,
                        style: TextStyle(color: AppColor().grayText),
                      ),
                      Text(
                        widget.mp[i].transStatus == "3"
                            ? "COMPLETE"
                            : "PENDING",
                        style: TextStyle(
                            color: widget.mp[i].transStatus == "3"
                                ? AppColor().success
                                : Colors.amber),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
