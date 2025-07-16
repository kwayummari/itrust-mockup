import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankInstruction extends StatefulWidget {
  String fundCode, accountNumber;
  BankInstruction(
      {super.key, required this.fundCode, required this.accountNumber});

  @override
  State<BankInstruction> createState() => _BankInstructionState();
}

class _BankInstructionState extends State<BankInstruction> {
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final mp = Provider.of<MarketProvider>(context);

    return Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        height: appHeight,
        width: appWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BY USING BANK MOBILE APPLICATION:",
              style: TextStyle(
                  color: AppColor().textColor,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              "1. Login to your Application",
              style: TextStyle(color: AppColor().textColor),
            ),
            Text(
              "2. Choose Tranfer/Send Money",
              style: TextStyle(color: AppColor().textColor),
            ),
            Text(
              '3. Choose "Other Banks"  ',
              style: TextStyle(color: AppColor().textColor),
            ),
            Text(
              '4. Choose "NBC BANK"',
              style: TextStyle(color: AppColor().textColor),
            ),
            RichText(
                text: TextSpan(
                    text: '5. Enter Fund Account Number ',
                    style: TextStyle(color: AppColor().textColor),
                    children: [
                  TextSpan(
                    text: '"${widget.accountNumber}"',
                    style: TextStyle(
                        color: AppColor().blueBTN, fontWeight: FontWeight.w600),
                  )
                ])),
            Text(
              '6. Enter Amount',
              style: TextStyle(color: AppColor().textColor),
            ),
            RichText(
                text: TextSpan(
                    text:
                        '7. In the Description field enter your Control Number ',
                    style: TextStyle(color: AppColor().textColor),
                    children: [
                  TextSpan(
                    text:
                        '"${mp.usrSub.firstWhere((UserSubscriber data) => data.fundCode == widget.fundCode, orElse: () => UserSubscriber(fundName: "", amount: "", fundCode: "NF", inMinContr: "NF", subs: "NF", clientRef: "NF")).clientRef}"',
                    style: TextStyle(
                        color: AppColor().blueBTN, fontWeight: FontWeight.w600),
                  )
                ])),
            Text(
              '8. Click "Next" ',
              style: TextStyle(color: AppColor().textColor),
            ),
            Text(
              '9. Enter Your PIN & Confirm Payment/Transfer',
              style: TextStyle(color: AppColor().textColor),
            ),
            SizedBox(
              height: appHeight * 0.04,
            ),
            Text(
              "TOP UP WITH BANK DEPOSIT/WAKALA:",
              style: TextStyle(
                  color: AppColor().textColor,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: appWidth,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    // color: AppColor().blueBTN,
                    borderRadius: BorderRadius.circular(8.0)),
                child: Column(
                  children: [
                    Text(
                      'Bank: NBC Bank',
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    Text(
                      'Branch: Corporate Branch',
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    Text(
                      'Account Number: XXXXXXXXXX ',
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    Text(
                      'Account Name: Fund Name',
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    Text(
                      'Swift Code: NLCBTZTZ',
                      style: TextStyle(color: AppColor().textColor),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "1. Locate a branch - Locate any Bank branch or Wakala around you where you can deposit the funds.",
              style: TextStyle(color: AppColor().textColor),
            ),
            Text(
              "2. Fill out a payment slip - Complete the form and ensure you use your Control Number provided to you by iTrust.",
              style: TextStyle(color: AppColor().textColor),
            ),
            Text(
              '3. Receive a confirmation - After completion of the deposit, ensure you have received a confirmation of the funds being deposited.',
              style: TextStyle(color: AppColor().textColor),
            ),
            SizedBox(
              height: appHeight * 0.01,
            ),
            Text(
              "After completing the payment, please be sure to upload your proof of payment (receipt). We appreciate your attention to this detail!, upload button will be shown on your subscription screen",
              style: TextStyle(
                  color: AppColor().blueBTN, fontWeight: FontWeight.w600),
            ),
            Align(
              alignment: Alignment.center,
              child: largeBTN(appWidth * 0.2, "Got It", AppColor().blueBTN, () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BottomNavBarWidget()),
                    (route) => false);
              }),
            )
          ],
        ));
  }
}
