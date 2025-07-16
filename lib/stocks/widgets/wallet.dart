import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/fund/add_funds.dart';
import 'package:iwealth/screens/stocks/statement/statement.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:flutter/material.dart';

Widget walletCard(
  appHeight,
  appWidth,
  balance,
  onclick,
  isVisble,
  mp,
  context, {
  bool showActionButtons = true,
}) {
  return Container(
    height: appHeight * 0.22,
    width: appWidth,
    decoration: BoxDecoration(
      color: AppColor().orangeApp,
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    showActionButtons
                        ? "My Wallet (${SessionPref.getUserProfile()![9]})"
                        : "My Wallet",
                    style: TextStyle(
                      color: AppColor().constant,
                      fontSize: 18.0,
                      letterSpacing: 1.0,
                      wordSpacing: 5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showActionButtons ? "Wallet Balance" : "",
                          style: TextStyle(color: AppColor().constant),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  "TZS",
                                  style: TextStyle(color: AppColor().constant),
                                ),
                              ),
                              Text(
                                isVisble ? balance : "XXXXXXXX",
                                style: TextStyle(
                                  color: AppColor().constant,
                                  fontSize: 20.0,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: onclick,
                                icon: Icon(
                                  isVisble
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColor().constant,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showActionButtons)
          Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            height: appHeight * 0.05,
            width: appWidth,
            decoration: const BoxDecoration(
                color: Color.fromARGB(100, 27, 27, 27),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0))),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddFundsScreen()),
                    );
                  },
                  child: Text(
                    "+ Add Funds",
                    style: TextStyle(color: AppColor().constant),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    loading(context);
                    var statementStatus = await StockWaiter()
                        .viewStatement(marketProvider: mp, context: context);
                    if (statementStatus == "1") {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StatementScreen()),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  label: Text(
                    "View Statement",
                    style: TextStyle(color: AppColor().constant),
                  ),
                  icon: Icon(
                    Icons.description_outlined,
                    color: AppColor().constant,
                  ),
                )
              ],
            ),
          ),
      ],
    ),
  );
}
