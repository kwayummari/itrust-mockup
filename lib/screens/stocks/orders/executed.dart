import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';

import 'package:iwealth/stocks/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExecutedOrderScreen extends StatefulWidget {
  const ExecutedOrderScreen({super.key});

  @override
  State<ExecutedOrderScreen> createState() => _ExecutedOrderScreenState();
}

class _ExecutedOrderScreenState extends State<ExecutedOrderScreen> {
  void getOds(MarketProvider marketProvider) async {
    var orderStatus = await StockWaiter().getOrders(marketProvider);
    if (orderStatus == "1") {
      if (kDebugMode) {
        print("[STOCK ORDERS]: ORDERS DATA PULLED SUCCESSFULLY !!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final marketProvider = Provider.of<MarketProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          getOds(marketProvider);
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          child: Container(
            height: appHeight,
            width: appWidth,
            decoration: BoxDecoration(
                border: Border.all(color: AppColor().inputFieldColor),
                borderRadius: BorderRadius.circular(10.0)),
            child: marketProvider.order == []
                ? Center(
                    child: Text(
                    "No orders",
                    style: TextStyle(color: AppColor().textColor),
                  ))
                : ListView.builder(
                    itemCount: marketProvider.order.length,
                    itemBuilder: (context, i) {
                      if (marketProvider.order[i].status == "complete" ||
                          marketProvider.order[i].status == "rejected" ||
                          marketProvider.order[i].status == "approved") {
                        return orderCard(
                            context, marketProvider.order[i]);
                      } else {
                        return const SizedBox();
                      }
                    }),
          ),
        ),
      ),
    );
  }
}
