import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/ipo_card.dart';
import 'package:iwealth/screens/IPO/pay_instruct.dart';
import 'package:iwealth/screens/IPO/subscription.dart';
import 'package:iwealth/screens/fund/fund_metadata.dart';
import 'package:iwealth/screens/user/kyc.dart';
import 'package:iwealth/services/IPO/ipo_waiter.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/stocks/services/pull_metadata.dart';
import 'package:iwealth/stocks/widgets/kyc_banner.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utilities/filtera_subsc.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FundDetailsScreen extends StatefulWidget {
  String launchOn,
      fundCode,
      accountNumber,
      ipoid,
      description,
      fundName,
      category,
      nav,
      percentgain,
      minInv,
      entryFee,
      subsPrice,
      exitFee;
  FundDetailsScreen(
      {super.key,
      required this.accountNumber,
      required this.fundCode,
      required this.ipoid,
      required this.exitFee,
      required this.category,
      required this.entryFee,
      required this.fundName,
      required this.minInv,
      required this.nav,
      required this.percentgain,
      required this.launchOn,
      required this.description,
      required this.subsPrice});

  @override
  State<FundDetailsScreen> createState() => _FundDetailsScreenState();
}

class _FundDetailsScreenState extends State<FundDetailsScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController ipoAmount = TextEditingController();
  TextEditingController description = TextEditingController();

  void contribute({required MarketProvider mp}) async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);
      loading(context);
      var status = await IpoWaiter().contributeToIPO(
          fundCode: widget.fundCode,
          ipoId: widget.ipoid,
          amount: ipoAmount.text.replaceAll(",", ""),
          description: description.text, context: context);

      if (status[0] == "success") {
        if (kDebugMode) {
          print("PURCHASES ID: ${status[1]}");
        }
        await IpoWaiter().getSubscriptionList(mp: mp, context: context);
        await IpoWaiter().userSubscribed(mp: mp);
        if (kDebugMode) {
          print("Success");
        }
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => IPOPayInstruction(
                      purchasesId: status[1],
                      fundName: widget.fundName,
                      fundCode: widget.fundCode,
                      accountNumber: widget.accountNumber,
                      amount: ipoAmount.text.replaceAll(",", ""),
                      fundId: '',
                    ))).then((h) {
          ipoAmount.clear();
          description.clear();
        });
        // ipoAmount.dispose();

        // Navigator.pushre
      } else if (status == "fail") {
        ipoAmount.clear();
        description.clear();
        Navigator.pop(context);
        AppSnackbar(
          isError: true,
          response: "Something went wrong, Please try again",
        ).show(context);
      }
    }
  }

  fieldRestrict(
      {required String code,
      required String iniMinAmount,
      required MarketProvider mp}) {
    var restricted = "";
    var sub = mp.usrSub.firstWhere(
        (UserSubscriber data) => data.fundCode == code,
        orElse: () => UserSubscriber(
            fundCode: "NF",
            inMinContr: "NF",
            subs: "NF",
            clientRef: "NF",
            amount: "NF",
            fundName: "NF"));

    if (sub.fundCode == "NF") {
      restricted = iniMinAmount;
    } else {
      restricted = sub.subs;
    }
    return double.parse(restricted);
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final mp = Provider.of<MarketProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
            )),
        backgroundColor: AppColor().bgLight,
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        height: appHeight,
        width: appWidth,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: ListView(
          children: [
            SessionPref.getUserProfile()![6] == "pending"
                ? kycBanner(
                    appHeight,
                    appWidth,
                    mp,
                    "Complete Profile to\n start buying units",
                    AppColor().blueBTN,
                    "Proceed",
                    false, () {
                    setState(() async {
                      await PullMetadata().nidabtnPressed(mp, context);
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const KYCScreen()));
                    // }
                  })
                : SessionPref.getUserProfile()![6] == "submitted" ||
                        SessionPref.getUserProfile()![7] == "pending"
                    ? kycBanner(
                        appHeight,
                        appWidth,
                        mp,
                        "we’re reviewing your submitted Profile. Kindly wait for the verification to complete.",
                        AppColor().orangeApp,
                        "On-Review",
                        false,
                        () {})
                    : const Text(""),
            Card(
              elevation: 5.0,
              // padding: EdgeInsets.all(10.0),
              // height: appHeight * 0.19,
              // width: appWidth,
              // decoration: BoxDecoration(color: AppColor().bgLight),
              color: AppColor().bgLight,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.graphic_eq_outlined,
                      color: AppColor().textColor,
                    ),
                    title: Text(
                      widget.fundName,
                      style: TextStyle(
                          color: AppColor().textColor,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      widget.category,
                      style: TextStyle(color: AppColor().grayText),
                    ),
                    trailing: largeBTN(
                        appWidth * 0.2,
                        "BUY",
                        AppColor().blueBTN,
                        SessionPref.getUserProfile()![6] == "finished" &&
                                SessionPref.getUserProfile()![7] == "active"
                            ? () {
                                ipoSubscriptionForm(
                                    msg: "",
                                    appHeights: appHeight,
                                    appWidths: appWidth,
                                    btnPressed: () {
                                      // print(fieldRestrict(
                                      //     code: widget.fundCode, iniMinAmount: widget.minInv, mp: mp));
                                      contribute(mp: mp);

                                      // .where((UserSubscriber data) => data.fundCode == "8956123");
                                    },
                                    context: context,
                                    formKey: formKey,
                                    restrictAmount: fieldRestrict(
                                        code: widget.fundCode,
                                        iniMinAmount: widget.minInv,
                                        mp: mp),
                                    ipoAmount: ipoAmount,
                                    description: description);
                              }
                            : null),
                  ),
                  ListTile(
                    title: Text(
                      "TZS ${currencyFormat(double.parse(widget.nav))}",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    subtitle: Text(
                      "+${currencyFormat(double.parse(widget.percentgain))}%",
                      style: TextStyle(color: AppColor().success),
                    ),
                    trailing: ElevatedButton(
                        onPressed: () async {
                          loading(context);
                          var status =
                              await IpoWaiter().getSubscriptionList(mp: mp, context: context);
                          if (status == "success") {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        IPOSubscriptionListScreen(
                                          subsData: filterSubsc(
                                              fundCode: widget.fundCode,
                                              mp: mp),
                                        )));
                          } else {
                            Navigator.pop(context);
                            AppSnackbar(
                              isError: true,
                              response:
                                  "Something went wrong, Please try again",
                            ).show(context);
                          }
                        },
                        child: Text(
                          "My Subscriptions",
                          style: TextStyle(
                              color: AppColor().blueBTN,
                              fontWeight: FontWeight.w600),
                        )),
                  )
                ],
              ),
            ),
            Card(
              elevation: 3.0,
              color: AppColor().bgLight,
              // margin: const EdgeInsets.only(top: 10.0),
              // padding: const EdgeInsets.all(10.0),
              // // height: appHeight * 0.8,
              // width: appWidth,
              // decoration: BoxDecoration(color: AppColor().bgLight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 15),
                    child: Text(
                      widget.description,
                      style: TextStyle(color: AppColor().blueBTN),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  // fundMetadata(title: "Launched On", value: widget.launchOn),
                  fundMetadata(
                      title: "Minimum Initial Investment ",
                      value:
                          "TZS ${currencyFormat(double.parse(widget.minInv))}"),
                  fundMetadata(
                    title: "Subsequent Contribution",
                    value: currencyFormat(double.parse(widget.subsPrice)),
                  ),
                  fundMetadata(
                      title: "Net Asset Value(NAV)",
                      value: "TZS ${currencyFormat(double.parse(widget.nav))}"),
                  fundMetadata(
                      title: "Entry Fee",
                      value:
                          "TZS ${currencyFormat(double.parse(widget.entryFee))}"),
                  fundMetadata(
                      title: "Exit Fee",
                      value:
                          "TZS ${currencyFormat(double.parse(widget.exitFee))}"),
                  ExpansionTile(
                    // backgroundColor: AppColor().grayText,
                    collapsedIconColor: AppColor().blueBTN,
                    childrenPadding: const EdgeInsets.all(10.0),
                    expansionAnimationStyle: AnimationStyle(
                        curve: Curves.ease,
                        duration: const Duration(seconds: 1)),
                    title: Text(
                      "How to Purchases/subscribe ?",
                      style: TextStyle(
                          color: AppColor().blueBTN,
                          fontWeight: FontWeight.w600),
                    ),

                    children: [
                      // RichText(text:)
                      Text(
                        "Step 1: Make sure You've completed to fill Profile and You can 'BUY' button in your top right side",
                        style: TextStyle(
                            color: AppColor().textColor,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Step 2: Click "BUY" button in your top right side',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        'Step 3: Provide amout you would like to invest for your future today',
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        "Step 4: Click Continue then You'll be prompted to dpeosit money in the given account.",
                        style: TextStyle(color: AppColor().textColor),
                      ),
                      Text(
                        'Note: Please remember to use your iTrust Account "${SessionPref.getUserProfile()![9]}" as the reference for Wakala when making a deposit. ',
                        style: TextStyle(
                            color: AppColor().textColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
