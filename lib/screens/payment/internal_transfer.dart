import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/payment.dart';
import 'package:iwealth/screens/payment/confirm_txn.dart';
import 'package:iwealth/services/nbc/apis.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final formKey = GlobalKey<FormState>();
  String? accNumber, from;
  TextEditingController amount = TextEditingController();
  TextEditingController narration = TextEditingController();

  final currFormat = NumberFormat("#,##0.00", "en_US");

  void sendQuoatation({required PaymentProvider pp}) async {
    if (formKey.currentState!.validate()) {
      loading(context);
      var status = await NBC().initiateTransfer(
          amount: amount.text,
          to: accNumber!,
          narration: narration.text,
          from: SessionPref.getUserProfile()![9],
          pp: pp);

      if (status == "success") {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionConfirm(
                      amount: currencyFormat(double.parse(pp.cheque!.amount)),
                      narration: pp.cheque!.narration,
                      to: pp.cheque!.receiverAccount,
                      toName: pp.cheque!.receiverName,
                    )));
      } else if (status == "validFail") {
        Navigator.pop(context);
        AppSnackbar(
          isError: true,
          response: "Wrong Receiver Account Number",
        ).show(context);
      } else {
        Navigator.pop(context);
        AppSnackbar(
                              isError: true,
                              response:
                                  "Something went wrong, Please try again",
                            ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final pp = Provider.of<PaymentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
            )),
        backgroundColor: AppColor().bgLight,
        title: Text(
          "Pay to iTrust Account",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          height: appHeight,
          width: appWidth,
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextfield().idVerification(
                      "Enter iTrust Account Number",
                      "From:",
                      12,
                      SessionPref.getUserProfile()![9],
                      TextInputType.number,
                      true, (val) {
                    setState(() {
                      from = SessionPref.getUserProfile()![9];
                    });
                  }),
                  CustomTextfield().idVerification(
                      "Enter iTrust Account Number",
                      "To: (iTrust Account Number)",
                      12,
                      null,
                      TextInputType.number,
                      false, (val) {
                    accNumber = val;
                  }),
                  CustomTextfield().amountToSent(
                      hint: "Enter Amount",
                      label: "Amount(TZS)",
                      inputType: TextInputType.number,
                      minAmount: 1000,
                      controller: amount,
                      valueCapture: (val) {}),
                  CustomTextfield().nameC("Add Description", "Description",
                      TextInputType.name, narration, (val) {}),
                  // Spacer(),
                  SizedBox(
                    height: appHeight * 0.1,
                  ),
                  largeBTN(appWidth * 0.8, "Continue", AppColor().blueBTN, () {
                    if (kDebugMode) {
                      print(
                          "TO ACC NO: $accNumber, FROM: $from, amout: ${amount.text} and Narration: ${narration.text}");
                    }
                    sendQuoatation(pp: pp);
                  })
                ],
              )),
        ),
      ),
    );
  }
}
