import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';

class StatementDetails extends StatefulWidget {
  String date, transactionType, amount, from, to, reference;
  String? qnty;
  StatementDetails(
      {super.key,
      required this.amount,
      required this.date,
      this.qnty,
      required this.transactionType,
      required this.from,
      required this.to,
      required this.reference});

  @override
  State<StatementDetails> createState() => _StatementDetailsState();
}

class _StatementDetailsState extends State<StatementDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColor().mainColor,
      appBar: AppBar(
        title: Text(
          "Receipt",
          style: TextStyle(color: AppColor().textColor),
        ),
        backgroundColor: AppColor().bgLight,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
            )),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: ListView(
            children: ListTile.divideTiles(
          color: AppColor().inputFieldColor,
          context: context,
          tiles: [
            ListTile(
              title: Text(
                "Date & Time",
                style: TextStyle(color: AppColor().grayText),
              ),
              subtitle: Text(
                widget.date,
                style: TextStyle(color: AppColor().textColor),
              ),
            ),
            ListTile(
              title: Text(
                "From",
                style: TextStyle(color: AppColor().grayText),
              ),
              subtitle: Text(
                widget.from,
                style: TextStyle(color: AppColor().textColor),
              ),
            ),
            ListTile(
              title: Text(
                "To",
                style: TextStyle(color: AppColor().grayText),
              ),
              subtitle: Text(
                widget.to,
                style: TextStyle(color: AppColor().textColor),
              ),
            ),
            widget.qnty != null
                ? ListTile(
                    title: Text(
                      "Product",
                      style: TextStyle(color: AppColor().grayText),
                    ),
                    subtitle: Text(
                      "${widget.qnty}",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                  )
                : const Text(""),
            ListTile(
              title: Text(
                "Amount(TZS)",
                style: TextStyle(color: AppColor().grayText),
              ),
              subtitle: Text(
                widget.amount,
                style: TextStyle(color: AppColor().textColor),
              ),
            ),
            ListTile(
              title: Text(
                "Reference",
                style: TextStyle(color: AppColor().grayText),
              ),
              subtitle: Text(
                widget.reference,
                style: TextStyle(color: AppColor().textColor),
              ),
            ),
          ],
        ).toList()),
      ),
    );
  }
}
