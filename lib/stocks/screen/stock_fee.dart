import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/models/order.dart';
import 'package:iwealth/stocks/screen/payment_options.dart';
import 'package:iwealth/stocks/widgets/feecard.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:provider/provider.dart';

class StockFeeScreen extends StatefulWidget {
  final Order order;
  final String amount, stockName;
  final String orderType;
  final String logoUrl;

  const StockFeeScreen({
    super.key,
    required this.order,
    required this.amount,
    required this.stockName,
    required this.orderType,
    required this.logoUrl,
  });

  @override
  State<StockFeeScreen> createState() => _StockFeeScreenState();
}

class _StockFeeScreenState extends State<StockFeeScreen> {
  bool isProcessing = false;

  void _handlePayment(BuildContext context, MarketProvider mp) async {
    setState(() => isProcessing = true);
    try {
      final orderResponse =
          await StockWaiter().orderStock(widget.order, mp, context);
      print("Order Response: $orderResponse");
      if (orderResponse['status'] == true) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PaymentOptionsPage(
              paymentType: 'stock',
              name: widget.stockName,
              amount: (() {
                String cleanedAmount = widget.amount.replaceAll(",", "");
                double? parsed = double.tryParse(cleanedAmount);
                if (parsed == null) return widget.amount;
                return parsed.round().toString();
              })(),
              orderId: orderResponse['purchaseId'],
              logoUrl: widget.logoUrl),
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

  void _placeSellOrder(BuildContext context, MarketProvider mp) async {
    setState(() => isProcessing = true);
    try {
      final orderResponse =
          await StockWaiter().orderStock(widget.order, mp, context);

      if (orderResponse['status'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              btn: const Text(""),
              successMessage: "Sell Order Placed!",
              txtDesc: orderResponse['message'] ??
                  "Your sell order has been placed successfully. The proceeds will be credited to your wallet.",
              screen: const BottomNavBarWidget(),
            ),
          ),
          (route) => false, // Removes all previous routes
        );
      } else {
        AppSnackbar(
          isError: true,
          response: "Failed to place sell order. Please try again later.",
        ).show(context);
      }
    } catch (e) {
      AppSnackbar(
        isError: true,
        response: "Failed to place sell order. Please try again later.",
      ).show(context);
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    final bool isBuying = widget.orderType == 'buy';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: AppColor().textColor)),
        title: Text(
          isBuying ? "Confirm Transaction" : "Confirm Sale",
          style: TextStyle(color: AppColor().textColor),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          height: appHeight,
          width: appWidth,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Security Details",
                  style: TextStyle(color: AppColor().textColor, fontSize: 17.0),
                ),
              ),
              SizedBox(height: appHeight * 0.02),
              feeCard(
                  infoName: "Security",
                  infoData: widget.order.stockName,
                  infoFontSize: 16.0),
              feeCard(
                  infoName: "Total Order Quantity",
                  infoData: "${widget.order.volume}",
                  infoFontSize: 16.0),
              feeCard(
                  infoName: "Price",
                  infoData:
                      "${currencyFormat(double.parse("${widget.order.price}"))}",
                  infoFontSize: 16.0),
              feeCard(
                  infoName: "Currency", infoData: "TZS", infoFontSize: 16.0),
              ExpansionTile(
                title: Text(
                  isBuying ? "View Full Cost Breakdown" : "View Sale Breakdown",
                  style: TextStyle(color: AppColor().blueBTN, fontSize: 18.0),
                ),
                iconColor: AppColor().blueBTN,
                collapsedIconColor: AppColor().blueBTN,
                children: [
                  largeFeeCard(
                      infoName: "Gross Consideration",
                      infoData: mp.feeCharge?.consideration,
                      subInfo: "",
                      infoFontSize: 17.0),
                  largeFeeCard(
                      infoName: "Brokerage Commision",
                      infoData: mp.feeCharge?.brokerage,
                      subInfo: "",
                      infoFontSize: 17.0),
                  largeFeeCard(
                      infoName: "VAT",
                      infoData: mp.feeCharge?.vat,
                      subInfo: "",
                      infoFontSize: 17.0),
                  largeFeeCard(
                      infoName: "DSE Fee",
                      infoData: mp.feeCharge?.dse,
                      subInfo: "",
                      infoFontSize: 17.0),
                  largeFeeCard(
                      infoName: "CMSA Fee",
                      infoData: mp.feeCharge?.cmsa,
                      subInfo: "",
                      infoFontSize: 17.0),
                  largeFeeCard(
                      infoName: "Fidelity Fee",
                      infoData: mp.feeCharge?.fidelity,
                      subInfo: "",
                      infoFontSize: 17.0),
                  largeFeeCard(
                      infoName: "CDS Fee",
                      infoData: mp.feeCharge?.cds,
                      subInfo: "",
                      infoFontSize: 17.0),
                  largeFeeCard(
                      infoName: "Total Charges",
                      infoData: mp.feeCharge?.totalFees,
                      subInfo: "",
                      infoFontSize: 17.0),
                ],
              ),
              SizedBox(height: appHeight * 0.02),
              feeCard(
                  infoName: isBuying
                      ? "Net Amount Payable (TZS)"
                      : "Net Proceeds (TZS)",
                  infoData: mp.feeCharge?.payout,
                  infoFontSize: 30.0),
              SizedBox(height: appHeight * 0.02),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: largeBTN(
                  appWidth,
                  isBuying ? "Confirm & Place Order" : "Confirm & Sell Stock",
                  AppColor().blueBTN,
                  isProcessing
                      ? null
                      : () {
                          if (isBuying) {
                            _handlePayment(context, mp);
                          } else {
                            _placeSellOrder(context, mp);
                          }
                        },
                ),
              ),
              if (isProcessing)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
