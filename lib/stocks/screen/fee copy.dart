import 'dart:io';

import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/payment_method.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/models/order.dart';
import 'package:iwealth/stocks/screen/payment_options.dart';
import 'package:iwealth/stocks/widgets/feecard.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/document_picker.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:provider/provider.dart';

class FeeScreen extends StatefulWidget {
  final Order order;
  final String amount, stockName;
  final String orderType;
  final String logoUrl;

  const FeeScreen({
    super.key,
    required this.order,
    required this.amount,
    required this.stockName,
    required this.orderType,
    required this.logoUrl,
  });

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  bool isProcessing = false;

  void _handlePayment(BuildContext context, MarketProvider mp) async {
    setState(() => isProcessing = true);
    try {
      showBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: 200,
              color: Colors.red,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
            );
          }).closed.then((_) {
        setState(() => isProcessing = false);
      });
      // final orderResponse =
      //     await StockWaiter().orderStock(widget.order, mp, context);
      // if (orderResponse['status'] == true) {
      //   showModalBottomSheet(
      //     context: context,
      //     isScrollControlled: true,
      //     backgroundColor: Colors.transparent,

      //     builder: (context) => PaymentOptionsPage(
      //         paymentType: 'stock',
      //         name: widget.stockName,
      //         amount: (() {
      //           String cleanedAmount = widget.amount.replaceAll(",", "");
      //           double? parsed = double.tryParse(cleanedAmount);
      //           if (parsed == null) return widget.amount;
      //           return parsed.round().toString();
      //         })(),
      //         orderId: orderResponse['purchaseId'],
      //         logoUrl: widget.logoUrl),
      //   );
      // } else {
      //   setState(() {
      //     isProcessing = false;
      //   });
      //   AppSnackbar(
      //     isError: true,
      //     response: "Failed to place sell order. Please try again later.",
      //   ).show(context);
      // }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      AppSnackbar(
        isError: true,
        response: "Failed to place sell order. Please try again later.",
      ).show(context);
    }
  }

  void _showPaymentOptionsDialog(
      BuildContext context, MarketProvider mp) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentOptionsDialog(
        order: widget.order,
        amount: widget.amount,
        stockName: widget.stockName,
        mp: mp,
        onSuccess: (String message) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(
                btn: const Text(""),
                successMessage: "Order Placed Successfully",
                txtDesc: message,
                screen: const BottomNavBarWidget(),
              ),
            ),
          );
        },
      ),
    );
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
      body: Container(
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
            feeCard(infoName: "Currency", infoData: "TZS", infoFontSize: 16.0),
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
    );
  }
}

class PaymentOptionsDialog extends StatefulWidget {
  final Order order;
  final String amount;
  final String stockName;
  final MarketProvider mp;
  final void Function(String message) onSuccess;

  const PaymentOptionsDialog({
    super.key,
    required this.order,
    required this.amount,
    required this.stockName,
    required this.mp,
    required this.onSuccess,
  });

  @override
  State<PaymentOptionsDialog> createState() => _PaymentOptionsDialogState();
}

class _PaymentOptionsDialogState extends State<PaymentOptionsDialog> {
  bool isLoading = false;
  String? proofFile;
  File? receipt;

  Future<void> takePicture() async {
    if (!mounted) return;

    try {
      final File? result = await DocumentPicker.pickDocument(
        context: context,
        allowedExtensions: ["pdf", "png", "jpg"],
      );

      if (result != null && mounted) {
        setState(() {
          receipt = result;
          proofFile = result.path.split('/').last;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting document: $e')),
        );
      }
    }
  }

  void _handlePayment(String paymentOption) async {
    setState(() => isLoading = true);
    widget.order.paymentOption = paymentOption;
    try {
      final orderResponse =
          await StockWaiter().orderStock(widget.order, widget.mp, context);
      if (orderResponse['status'] == true) {
        if (paymentOption == "wallet") {
          double requiredAmount = double.parse(
              "${widget.mp.feeCharge?.payout.replaceAll(",", "")}");
          double availableBalance = widget.mp.portfolio!.wallet!;
          if (availableBalance < requiredAmount) {
            Navigator.pop(context);
            AppSnackbar(
              isError: true,
              response:
                  "Available balance: TZS ${currencyFormat(availableBalance)}\nRequired amount: TZS ${currencyFormat(requiredAmount)}",
            ).show(context);
            return;
          }
        } else if (paymentOption == "ussd") {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: PayBy(
                  paymentType: 'stock',
                  name: widget.stockName,
                  amount: (() {
                    String cleanedAmount = widget.amount.replaceAll(",", "");
                    double? parsed = double.tryParse(cleanedAmount);
                    if (parsed == null) return widget.amount;
                    return parsed.round().toString();
                  })(),
                  orderId: orderResponse['purchase_id'],
                  mp: widget.mp,
                ),
              ),
            ),
          );
        } else if (paymentOption == "proof of payment") {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              File? selectedReceipt = receipt;
              String? selectedProofFile = proofFile;
              bool isSubmitting = false;

              return StatefulBuilder(
                builder: (context, setModalState) {
                  Future<void> handleSubmit() async {
                    setModalState(() => isSubmitting = true);
                    if (selectedReceipt != null) {
                      String? status =
                          await StockWaiter().stockPayProofOfPayment(
                        receipt: selectedReceipt!,
                        amount: (() {
                          String cleanedAmount =
                              widget.amount.replaceAll(",", "");
                          double? parsed = double.tryParse(cleanedAmount);
                          if (parsed == null) return widget.amount;
                          return parsed.round().toString();
                        })(),
                        description: "Payment for ${widget.stockName}",
                        purchaseId: orderResponse['purchase_id'],
                        context: context,
                      );
                      if (status == "success") {
                        Navigator.pop(context); // Close modal
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessScreen(
                              btn: const Text(""),
                              successMessage: "Order Placed Successfully",
                              txtDesc:
                                  "Proof of payment uploaded successfully.",
                              screen: const BottomNavBarWidget(),
                            ),
                          ),
                        );
                      } else {
                        AppSnackbar(
                          isError: true,
                          response:
                              "Failed to upload proof of payment. Please try again later.",
                        ).show(context);
                      }
                    } else {
                      AppSnackbar(
                        isError: true,
                        response:
                            "Please select a document to upload as proof of payment.",
                      ).show(context);
                    }
                  }

                  return Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor().bgLight,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Upload Proof of Payment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColor().textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: isSubmitting
                              ? null
                              : () async {
                                  final File? result =
                                      await DocumentPicker.pickDocument(
                                    context: context,
                                    allowedExtensions: ["pdf", "png", "jpg"],
                                  );
                                  if (result != null) {
                                    setModalState(() {
                                      selectedReceipt = result;
                                      selectedProofFile =
                                          result.path.split('/').last;
                                    });
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor().blueBTN),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.attach_file,
                                    color: AppColor().blueBTN),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedProofFile ??
                                        "Select file (pdf, png, jpg)",
                                    style: TextStyle(
                                      color: AppColor().textColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor().blueBTN,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    await handleSubmit();
                                  },
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    "Submit Proof",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
      } else {
        Navigator.pop(context);
        AppSnackbar(
          isError: true,
          response: "Failed to place sell order. Please try again later.",
        ).show(context);
      }
    } catch (e) {
      Navigator.pop(context);
      AppSnackbar(
        isError: true,
        response: "Failed to place sell order. Please try again later.",
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor().bgLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Choose Payment Option",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColor().textColor)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.account_balance_wallet,
                    color: AppColor().blueBTN),
                title: Text("Wallet",
                    style: TextStyle(color: AppColor().textColor)),
                onTap: () => _handlePayment("wallet"),
              ),
              ListTile(
                leading: Icon(Icons.phone_android, color: AppColor().blueBTN),
                title:
                    Text("USSD", style: TextStyle(color: AppColor().textColor)),
                onTap: () => _handlePayment("ussd"),
              ),
              ListTile(
                leading: Icon(Icons.upload_file, color: AppColor().blueBTN),
                title: Text("Submit Proof of Payment",
                    style: TextStyle(color: AppColor().textColor)),
                onTap: () => _handlePayment("proof of payment"),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
