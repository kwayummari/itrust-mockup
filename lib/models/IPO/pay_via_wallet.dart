import 'package:flutter/foundation.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/subscription.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

payViaWallet(
    {required MarketProvider mp,
    required fundName,
    required amount,
    required fundCode,
    required fundId,
    context}) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/images/Logo_with name.svg",
                width: 100,
              ),
              ListTile(
                title: Text(
                  "Fund Name",
                  style: TextStyle(color: AppColor().textColor),
                ),
                subtitle: Text(
                  fundName,
                  style: TextStyle(color: AppColor().textColor),
                ),
              ),
              ListTile(
                title: Text(
                  "Amount",
                  style: TextStyle(color: AppColor().textColor),
                ),
                subtitle: Text("TZS ${currencyFormat(double.parse(amount))}"),
              ),
              Text(
                "Wallet Balance(TZS ${currencyFormat(mp.portfolio?.wallet ?? 0)} ) ",
                style: TextStyle(color: AppColor().blueBTN),
              ),
              Divider(
                color: AppColor().blueBTN,
              ),
              double.parse("${mp.portfolio?.wallet}") >= double.parse(amount)
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor().blueBTN),
                      onPressed: () async {
                        Navigator.pop(context);
                        loading(context);
                        var status = await StockWaiter().placeFundOrder(
                            shareClassCode: fundCode,
                            purchasesValue: amount,
                            fundId: fundId,
                            context: context);

                        if (status == "1") {
                          // Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SuccessScreen(
                                      btn: const Text(""),
                                      successMessage: "Paid Successfully",
                                      txtDesc: "",
                                      screen: IPOSubscriptionListScreen(
                                          subsData: mp.ipoSubsc
                                              .where((stock) =>
                                                  stock.fundCode == fundCode)
                                              .toList()))));
                        } else if (status != "1") {
                          // appSnackBar(msg: status, context: context);
                          if (kDebugMode) {
                            print("FAIL DUE TO $status");
                          }
                          // Navigator.pop(context);
                          // Btmsheet().errorSheet(context, "Pay By Wallet",
                          //     "$status");
                        }
                      },
                      child: Text(
                        "Confirm",
                        style: TextStyle(color: AppColor().constant),
                      ))
                  : const Text(
                      "Insufficient Fund to do this transaction",
                      style: TextStyle(color: Colors.red),
                    )
            ],
          ),
        );
      });
}
