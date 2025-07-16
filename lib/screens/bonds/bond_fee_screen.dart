import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/models/bond_model.dart';
import 'package:iwealth/stocks/models/bond_order_model.dart';
import 'package:iwealth/stocks/screen/payment_options.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/stocks/widgets/feecard.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_bottom.dart';

class BondFeeScreen extends StatefulWidget {
  final BondOrderRequest order;
  final Bond bond;

  const BondFeeScreen({super.key, required this.order, required this.bond});

  @override
  State<BondFeeScreen> createState() => _BondFeeScreenState();
}

class _BondFeeScreenState extends State<BondFeeScreen> {
  bool isProcessing = false;

  void _handlePayment(BuildContext context, MarketProvider mp) async {
    setState(() => isProcessing = true);
    try {
      final orderResponse =
          await StockWaiter().orderBond(widget.order, mp, context);
      print("Order Response: $orderResponse");
      if (orderResponse['status'] == true) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PaymentOptionsPage(
            paymentType: 'bond',
            name: widget.bond.securityName ?? "Bond",
            amount: (() {
              String cleanedAmount =
                  mp.bondsCostBreakdown?.payout.replaceAll(",", "") ?? "";
              double? parsed = double.tryParse(cleanedAmount);
              if (parsed == null) {
                return mp.bondsCostBreakdown?.payout ?? "";
              }
              return parsed.round().toString();
            })(),
            orderId: orderResponse['data'],
            logoUrl: widget.bond.logoUrl ?? "",
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
              isProcessing = false;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavBarWidget(currentIndex: 2),
              ),
            );
          }
        });
      } else {
        setState(() {
          isProcessing = false;
        });
        print("Order Response: $orderResponse");
        AppSnackbar(
          isError: true,
          response: "Failed to place order. Please try again later.",
        ).show(context);
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      AppSnackbar(
        isError: true,
        response: "Failed to place order. Please try again later.",
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;
    final mp = Provider.of<MarketProvider>(context);

    final breakdown = mp.bondsCostBreakdown;
    final numberFormat = NumberFormat('#,##0.00');

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
          ),
        ),
        backgroundColor: AppColor().bgLight,
        title: Text(
          "Confirm Bond Transaction",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: Container(
        height: appHeight,
        width: appWidth,
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Bond Details",
                style: TextStyle(color: AppColor().textColor, fontSize: 17.0),
              ),
            ),
            SizedBox(height: appHeight * 0.02),
            feeCard(
                infoName: "Bond",
                infoData: widget.bond.securityName,
                infoFontSize: 16.0),
            feeCard(
                infoName: "Face Value",
                infoData: currencyFormat(widget.order.faceValue),
                infoFontSize: 16.0),
            feeCard(
                infoName: "Order Price",
                infoData: currencyFormat(widget.order.price),
                infoFontSize: 16.0),
            feeCard(infoName: "Currency", infoData: "TZS", infoFontSize: 16.0),
            ExpansionTile(
              title: Text(
                "View Full Cost Breakdown",
                style: TextStyle(color: AppColor().blueBTN, fontSize: 18.0),
              ),
              iconColor: AppColor().blueBTN,
              collapsedIconColor: AppColor().blueBTN,
              children: [
                largeFeeCard(
                    infoName: "Gross Consideration",
                    infoData: breakdown?.totalFees,
                    subInfo: "",
                    infoFontSize: 17.0),
                largeFeeCard(
                    infoName: "Brokerage Commission",
                    infoData: breakdown?.brokerage,
                    subInfo: "",
                    infoFontSize: 17.0),
                largeFeeCard(
                    infoName: "VAT",
                    infoData: breakdown?.vat,
                    subInfo: "",
                    infoFontSize: 17.0),
                largeFeeCard(
                    infoName: "DSE Fee",
                    infoData: breakdown?.dse,
                    subInfo: "",
                    infoFontSize: 17.0),
                largeFeeCard(
                    infoName: "CMSA Fee",
                    infoData: breakdown?.cmsa,
                    subInfo: "",
                    infoFontSize: 17.0),
                largeFeeCard(
                    infoName: "CDS Fee",
                    infoData: breakdown?.cds,
                    subInfo: "",
                    infoFontSize: 17.0),
                largeFeeCard(
                    infoName: "Total Charges",
                    infoData: breakdown?.totalFees,
                    subInfo: "",
                    infoFontSize: 17.0),
              ],
            ),
            SizedBox(height: appHeight * 0.02),
            feeCard(
                infoName: "Net Amount Payable (TZS)",
                infoData: breakdown?.payout,
                infoFontSize: 30.0),
            SizedBox(height: appHeight * 0.02),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: largeBTN(
                appWidth,
                "Confirm & Place Order",
                AppColor().blueBTN,
                isProcessing ? null : () => _handlePayment(context, mp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
