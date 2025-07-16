import 'package:flutter/foundation.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/providers/payment.dart';
import 'package:iwealth/screens/user/otp.dart';
import 'package:iwealth/services/nbc/apis.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionConfirm extends StatefulWidget {
  String amount, to, narration, toName;
  TransactionConfirm(
      {super.key,
      required this.amount,
      required this.narration,
      required this.to,
      required this.toName});

  @override
  State<TransactionConfirm> createState() => _TransactionConfirmState();
}

class _TransactionConfirmState extends State<TransactionConfirm> {
  final formKey = GlobalKey<FormState>();
  String? code;
  var hasConfirmed = false;
  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final pp = Provider.of<PaymentProvider>(context);
    final mp = Provider.of<MarketProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
            )),
        backgroundColor: AppColor().bgLight,
        title: Text(
          "Confirm Transaction",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: appHeight,
          width: appWidth,
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  "From:",
                  style: TextStyle(color: AppColor().grayText),
                ),
                subtitle: Text(
                  SessionPref.getUserProfile()![9],
                  style: TextStyle(color: AppColor().textColor),
                ),
              ),
              ListTile(
                title: Text(
                  "To:",
                  style: TextStyle(color: AppColor().grayText),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "iTrust Account Number: ${widget.to}",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    Text(
                      widget.toName,
                      style: TextStyle(color: AppColor().grayText),
                    )
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  "Amount:",
                  style: TextStyle(color: AppColor().grayText),
                ),
                subtitle: Text(
                  "TZS ${widget.amount}",
                  style: TextStyle(color: AppColor().textColor),
                ),
              ),
              ListTile(
                title: Text(
                  "Description:",
                  style: TextStyle(color: AppColor().grayText),
                ),
                subtitle: Text(
                  widget.narration,
                  style: TextStyle(color: AppColor().textColor),
                ),
              ),
              SizedBox(
                height: appHeight * 0.1,
              ),
              hasConfirmed
                  ? Form(
                      key: formKey,
                      child: Column(
                        children: [
                          paymentCode(
                              w: appWidth,
                              h: appHeight,
                              otp: (val) {
                                setState(() {
                                  code = val;
                                });
                              },
                              context: context),
                          SizedBox(
                            height: appHeight * 0.05,
                          ),
                          largeBTN(
                              appWidth * 0.8, "Transfer", AppColor().blueBTN,
                              () async {
                            if (formKey.currentState!.validate()) {
                              loading(context);
                              var status = await NBC().transferMoney(
                                  channelRef: pp.cheque!.channelRef,
                                  vcode: code!,
                                  mp: mp,
                                  context: context);
                              if (status == "success") {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SuccessScreen(
                                            btn: const Text(""),
                                            successMessage:
                                                "Transaction Completed Successfully",
                                            txtDesc: "",
                                            screen:
                                                const BottomNavBarWidget())));
                                setState(() {
                                  hasConfirmed = false;
                                });
                              } else {
                                Navigator.pop(context);
                                AppSnackbar(
                                  isError: true,
                                  response:
                                      "Something went wrong, Please try again",
                                ).show(context);
                              }
                            }
                          })
                        ],
                      ),
                    )
                  : const Text(""),
              SizedBox(
                height: appHeight * 0.2,
              ),
              hasConfirmed == false
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        largeBTN(appWidth * 0.4, "Cancel", AppColor().orangeApp,
                            () {}),
                        largeBTN(appWidth * 0.4, "Confirm", AppColor().blueBTN,
                            () async {
                          loading(context);
                          var status = await NBC().verifyInformation(
                              channelRef: pp.cheque!.channelRef);
                          if (status == "success") {
                            if (kDebugMode) {
                              print("Confirmed");
                            }
                            Navigator.pop(context);

                            setState(() {
                              hasConfirmed = true;
                            });
                          } else {
                            Navigator.pop(context);
                            AppSnackbar(
                              isError: true,
                              response:
                                  "Something went wrong, Please try again",
                            ).show(context);
                          }
                        }),
                      ],
                    )
                  : const Text("")
            ],
          ),
        ),
      ),
    );
  }
}
