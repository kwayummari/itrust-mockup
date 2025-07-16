import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/IPO/wakala.dart';
import 'package:flutter/material.dart';

class IPOPayInstruction extends StatefulWidget {
  String fundCode, accountNumber, amount, fundName, purchasesId, fundId;
  IPOPayInstruction(
      {super.key,
      required this.fundCode,
      required this.accountNumber,
      required this.amount,
      required this.fundName,
      required this.purchasesId,
      required this.fundId});

  @override
  State<IPOPayInstruction> createState() => _IPOPayInstructionState();
}

class _IPOPayInstructionState extends State<IPOPayInstruction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor().bgLight,
          title: Text(
            "Payment",
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
        ),
        body: WakalaInstruction(
            fundCode: widget.fundCode,
            accountNumber: widget.accountNumber,
            amount: widget.amount,
            fundName: widget.fundName,
            purchasesId: widget.purchasesId,
            fundId: widget.fundId));
  }
}
