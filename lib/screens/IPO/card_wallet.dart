import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/stocks/statement/statement.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget cardWallet(
    {required bool isVisible,
    required double appHeights,
    required double appWidths,
    required balance,
    required VoidCallback onClick,
    required MarketProvider mp,
    required context}) {
  return Card(
    elevation: 30.0,
    color: AppColor().orangeApp,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "My Wallet (${SessionPref.getUserProfile()![9]})",
            style: TextStyle(
                color: AppColor().constant,
                fontSize: 18.0,
                letterSpacing: 1.0,
                wordSpacing: 5,
                fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: Text(
                  "TZS",
                  style: TextStyle(color: AppColor().constant),
                ),
              ),
              Text(
                isVisible ? balance : "XXXXXXXX",
                style: TextStyle(
                    color: AppColor().constant,
                    fontSize: 20.0,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: onClick,
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColor().constant,
                  )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          height: appHeights * 0.05,
          width: appWidths,
          decoration: const BoxDecoration(
              color: Color.fromARGB(100, 27, 27, 27),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0))),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                      barrierColor: AppColor().selected,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppColor().bgLight,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      "assets/images/Logo_ only_name.svg",
                                      width: 80,
                                    )),
                              ),
                              Text(
                                "Hello ${SessionPref.getUserProfile()![0]}, You can deposit money in your wallet account number ${SessionPref.getUserProfile()![9]} through: ",
                                style: TextStyle(color: AppColor().textColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "> MNOs AGENTS(WAKALA)",
                                  style: TextStyle(color: AppColor().textColor),
                                ),
                              ),
                              Text(
                                "> BANK TRANSFER TO YOUR WALLET",
                                style: TextStyle(color: AppColor().textColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "YOUR ACCOUNT NAME: ${SessionPref.getUserProfile()![0]} ${SessionPref.getUserProfile()![2]}",
                                  style: TextStyle(color: AppColor().textColor),
                                ),
                              )
                            ],
                          ),
                        );
                      });
                },
                child: Text(
                  "+ Top Up",
                  style: TextStyle(color: AppColor().constant, fontSize: 12),
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
                            builder: (context) => const StatementScreen()));
                  } else {
                    Navigator.pop(context);
                  }
                },
                label: Text(
                  "View Statement",
                  style: TextStyle(color: AppColor().constant, fontSize: 12.0),
                ),
                icon: Icon(
                  Icons.description_outlined,
                  color: AppColor().constant,
                ),
              )
            ],
          ),
        )
      ],
    ),
  );
}
