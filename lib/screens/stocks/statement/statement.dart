import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/stocks/statement/statement_details.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  final currFormat = NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final mp = Provider.of<MarketProvider>(context);
    return Scaffold(
      // backgroundColor: AppColor().mainColor,
      appBar: AppBar(
        backgroundColor: AppColor().bgLight,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BottomNavBarWidget()));
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
            )),
        title: Text(
          "Wallet Statement",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: Container(
          padding: const EdgeInsets.all(10.0),
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          child: ListView.separated(
            itemCount: mp.statement.length,
            separatorBuilder: (context, i) {
              return Divider(
                color: AppColor().inputFieldColor,
              );
            },
            itemBuilder: (context, i) {
              return ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StatementDetails(
                                // amount:
                                //     double.parse(mp.statement[i].debit) > 0 ? currencyFormat(double.parse(mp.statement[i].debit)) : currencyFormat(double.parse(mp.statement[i].credit)),
                                amount: mp.statement[i].amount,
                                date: mp.statement[i].transactionDate,
                                transactionType: mp.statement[i].transactionType
                                    .toUpperCase(),
                                from:
                                    "${SessionPref.getUserProfile()?[0]} ${SessionPref.getUserProfile()?[2]}",
                                to: "iTrust Finance Limited",
                                reference: mp.statement[i].transactionReference,
                                qnty: mp.statement[i].orderType == "equity"
                                    ? "${mp.statement[i].transactionQuantity} @ TZS ${mp.statement[i].transactionPrice}"
                                    : null,
                              )));
                },
                title: Text(
                  mp.statement[i].transactionDescription
                      .replaceFirst(RegExp(r' '), ''),
                  style: TextStyle(color: AppColor().textColor),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      "${mp.statement[i].transactionDate} | ",
                      style: TextStyle(color: AppColor().grayText),
                    ),
                    mp.statement[i].transactionType == "C"
                        ? Text(
                            "Money In",
                            style: TextStyle(color: AppColor().success),
                          )
                        : mp.statement[i].transactionType == "D"
                            ? Text(
                                "Money Out",
                                style: TextStyle(color: AppColor().orangeApp),
                              )
                            : const Text("")
                  ],
                ),
                trailing: Text(
                  "TZS ${double.parse(mp.statement[i].debit) > 0 ? currencyFormat(double.parse(mp.statement[i].debit)) : currencyFormat(double.parse(mp.statement[i].credit))}",
                  style: TextStyle(color: AppColor().textColor),
                ),
              );
            },
          )),
    );
  }
}
