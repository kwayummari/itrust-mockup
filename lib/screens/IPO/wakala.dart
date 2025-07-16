import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/payment_method.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/subscription.dart';
import 'package:iwealth/utilities/filtera_subsc.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WakalaInstruction extends StatefulWidget {
  String fundCode, accountNumber, amount, fundName, purchasesId, fundId;
  WakalaInstruction(
      {super.key,
      required this.fundCode,
      required this.accountNumber,
      required this.amount,
      required this.fundName,
      required this.fundId,
      required this.purchasesId});

  @override
  State<WakalaInstruction> createState() => _WakalaInstructionState();
}

class _WakalaInstructionState extends State<WakalaInstruction> {
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
            payByWallet(
                name: widget.fundName,
                fundCode: widget.fundCode,
                amount: widget.amount,
                purchasesId: widget.purchasesId,
                fundId: widget.fundId,
                mp: mp,
                context: context),

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: PayBy(
                paymentType: 'fund',
                name: widget.fundName,
                amount: widget.amount,
                mp: mp,
                orderId: widget.purchasesId,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "OR",
                  style: TextStyle(
                      color: AppColor().textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 17.0),
                ),
              ),
            ),
            ExpansionTile(
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                collapsedBackgroundColor: AppColor().grayText,
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                title: Text(
                  "BY USING MOBILE APPLICATION:",
                  style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600),
                ),
                children: [
                  Text(
                    "1. Login to your Application",
                    style: TextStyle(color: AppColor().textColor),
                  ),
                  Text(
                    "2. Choose Tranfer To Bank or Banking",
                    style: TextStyle(color: AppColor().textColor),
                  ),
                  Text(
                    '3. Choose "NBC BANK" ',
                    style: TextStyle(color: AppColor().textColor),
                  ),
                  RichText(
                      text: TextSpan(
                          text: '4. Enter Fund Account Number ',
                          style: TextStyle(color: AppColor().textColor),
                          children: [
                        TextSpan(
                          text: '"${widget.accountNumber}"',
                          style: TextStyle(
                              color: AppColor().blueBTN,
                              fontWeight: FontWeight.w600),
                        )
                      ])),
                  Text(
                    "5. Choose Tranfer To Bank or Banking",
                    style: TextStyle(color: AppColor().textColor),
                  ),
                  Text(
                    '6. Enter the amount',
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
                              '"${mp.usrSub.firstWhere((UserSubscriber data) => data.fundCode == widget.fundCode, orElse: () => UserSubscriber(amount: "NF", fundName: "NF", fundCode: "NF", inMinContr: "NF", subs: "NF", clientRef: "NF")).clientRef}"',
                          style: TextStyle(
                              color: AppColor().blueBTN,
                              fontWeight: FontWeight.w600),
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
                ]),
            SizedBox(
              height: appHeight * 0.01,
            ),
            ExpansionTile(
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              collapsedBackgroundColor: AppColor().grayText,
              collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              title: Text(
                "BY USING BANK MOBILE APPLICATION:",
                style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600),
              ),
              children: [
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
                            color: AppColor().blueBTN,
                            fontWeight: FontWeight.w600),
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
                            '"${mp.usrSub.firstWhere((UserSubscriber data) => data.fundCode == widget.fundCode, orElse: () => UserSubscriber(amount: "NF", fundName: "NF", fundCode: "NF", inMinContr: "NF", subs: "NF", clientRef: "NF")).clientRef}"',
                        style: TextStyle(
                            color: AppColor().blueBTN,
                            fontWeight: FontWeight.w600),
                      )
                    ])),
                Text(
                  '8. Click "Next" ',
                  style: TextStyle(color: AppColor().textColor),
                ),
                Text(
                  '9. Enter Your PIN & Confirm Payment/Transfer',
                  style: TextStyle(color: AppColor().textColor),
                )
              ],
            ),
            SizedBox(
              height: appHeight * 0.01,
            ),
            ExpansionTile(
              collapsedBackgroundColor: AppColor().grayText,
              expandedCrossAxisAlignment: CrossAxisAlignment.center,
              collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              title: Text(
                "TOP UP WITH BANK DEPOSIT/WAKALA:",
                style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600),
              ),
              children: [
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
                          'Account Number: ${widget.accountNumber} ',
                          style: TextStyle(color: AppColor().textColor),
                        ),
                        Text(
                          'Account Name: ${widget.fundName}',
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
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                  onPressed: () {
                    // Navigate directly to order list without triggering home screen loads
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const BottomNavBarWidget(currentIndex: 2)),
                        (route) => false);
                  },
                  child: const Text("Go To Order Page")),
            ),
            SizedBox(
              height: appHeight * 0.01,
            ),
            // Text(
            //   "After completing the payment, please be sure to upload your proof of payment (receipt). We appreciate your attention to this detail!, upload button will be shown on your subscription screen",
            //   style: TextStyle(
            //       color: AppColor().blueBTN, fontWeight: FontWeight.w600),
            // ),
            // Align(
            //   alignment: Alignment.center,
            //   child: largeBTN(appWidth * 0.2, "Got It", AppColor().blueBTN, () {
            //     Navigator.pushAndRemoveUntil(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => const BottomNavBarWidget()),
            //         (route) => false);
            //   }),
            // )
          ],
        ));
  }
}
