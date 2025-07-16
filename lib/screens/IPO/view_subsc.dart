import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/payment_method.dart';
import 'package:iwealth/models/fund/fund_model.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/howto.dart';
import 'package:iwealth/screens/IPO/subscription.dart';
import 'package:iwealth/services/IPO/ipo_waiter.dart';
import 'package:iwealth/stocks/screen/payment_options.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utilities/filtera_subsc.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/pop_up_dialog.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:iwealth/widgets/snack_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/widgets/document_picker.dart';
import 'package:iwealth/models/IPO/subscription.dart';

import '../stocks/orders/order_details_widgets.dart';

class ViewSubscription extends StatefulWidget {
  final IPOSubscription fundOrder;
  const ViewSubscription({super.key, required this.fundOrder});

  @override
  State<ViewSubscription> createState() => _ViewSubscriptionState();
}

class _ViewSubscriptionState extends State<ViewSubscription>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  var refresher = "";
  TextEditingController paidAmount = TextEditingController();
  TextEditingController desc = TextEditingController();
  String? proofFile;
  File? receipt;
  late IPOSubscription? fundOrder;
  late FundModel fund;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fundOrder = widget.fundOrder;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final cleanAmount = '${fundOrder?.amount}'.replaceAll(",", "");
    final double? parsedAmount = double.tryParse(cleanAmount);
    if (parsedAmount != null) {
      final formattedAmount = parsedAmount.toStringAsFixed(2);
      if (formattedAmount.length > 15) {
        paidAmount.text = formattedAmount.substring(0, 15);
      } else {
        paidAmount.text = formattedAmount;
      }
    } else {
      paidAmount.text = "0.00";
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void submitProofOfpayment({required MarketProvider mp}) async {
    if (formKey.currentState!.validate()) {
      if (proofFile != null) {
        loading(context);

        final cleanAmount = paidAmount.text.replaceAll(",", "");
        final double? parsedAmount = double.tryParse(cleanAmount);
        if (parsedAmount == null) {
          Navigator.pop(context);
          AppSnackbar(
            isError: true,
            response: "Please enter valid amount",
          ).show(context);
          return;
        }

        final wholeAmount = parsedAmount.round().toString();
        if (wholeAmount.length > 15) {
          Navigator.pop(context);
          AppSnackbar(
            isError: true,
            response: "Amount exceeds maximum allowed digits",
          ).show(context);
          return;
        }

        var status = await IpoWaiter().uploadProofOfPayment(
            context: context,
            receipt: receipt!,
            amount: wholeAmount, // Send whole number amount
            description: desc.text,
            purchaseId: fundOrder?.id ?? '');

        if (status == "success") {
          var subStatus =
              await IpoWaiter().getSubscriptionList(mp: mp, context: context);
          if (subStatus == "success") {
            appSnackBar(
                msg: "Payment Proof Submitted Successfully", context: context);
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SuccessScreen(
                        btn: const Text(""),
                        successMessage: "Paid Successfully",
                        txtDesc: "",
                        screen: IPOSubscriptionListScreen(
                            subsData: filterSubsc(
                                fundCode: fundOrder?.fundCode ?? '',
                                mp: mp)))));
          } else if (status == "fail") {
            Navigator.pop(context);
            AppSnackbar(
              isError: true,
              response: "Something went wrong, Please try again",
            ).show(context);
          }
        } else if (status == "fail") {
          Navigator.pop(context);
          AppSnackbar(
            isError: true,
            response: "Something went wrong, Please try again",
          ).show(context);
        }
      } else {
        popUpDialog("Please Upload Receipt", "Okay", AppColor().textColor,
            Icons.warning, () {
          Navigator.pop(context);
        }, context);
      }
    }
  }

  // ============= IMAGE PICKER ================

  // Modify takePicture method to properly handle navigation
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

        // Animate the change
        _animationController.forward(from: 0.0);
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

  // ============================================

  Widget _buildSubmitButton(MarketProvider mp) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: () => submitProofOfpayment(mp: mp),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor().blueBTN,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withOpacity(0.1);
                }
                return null;
              },
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.upload_file,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Submit Payment Proof",
                style: TextStyle(
                  color: AppColor().constant,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection(MarketProvider mp) {
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor().blueBTN.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Text(
                  "Payment Options",
                  style: TextStyle(
                    color: AppColor().blueBTN,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: PayBy(
                                  paymentType: 'fund',
                                  name: fundOrder?.name ?? '',
                                  amount: fundOrder?.amount ?? '',
                                  orderId: fundOrder?.id ?? '',
                                  mp: mp,
                                  logoUrl: fund.logoUrl ?? '',
                                ),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: _buildPaymentOptionItem(
                          "Pay via USSD",
                          Icons.phone_android,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Upload Payment Proof Option
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => takePicture(),
                        borderRadius: BorderRadius.circular(8),
                        child: _buildPaymentOptionItem(
                          "Upload Payment Proof",
                          receipt != null
                              ? Icons.check_circle
                              : Icons.upload_file,
                          hasFile: receipt != null,
                          subtitle: receipt != null ? proofFile : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (receipt != null) ...[
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          File(receipt!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                            onPressed: () {
                              setState(() {
                                receipt = null;
                                proofFile = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomTextfield().amountToSent(
                          hint: "Enter amount paid",
                          label: "Amount Paid*",
                          inputType: TextInputType.number,
                          minAmount: 10000,
                          controller: paidAmount,
                          valueCapture: (val) {
                            // Optional: Add any validation or formatting here
                          },
                        ),
                        _buildSubmitButton(mp), // New beautiful button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentOptionItem(String title, IconData icon,
      {bool hasFile = false, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasFile
              ? AppColor().success.withOpacity(0.5)
              : AppColor().blueBTN.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: hasFile ? AppColor().success.withOpacity(0.05) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: hasFile ? AppColor().success : AppColor().blueBTN,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColor().textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColor().textColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                hasFile ? Icons.edit : Icons.arrow_forward_ios,
                color: hasFile ? AppColor().success : AppColor().blueBTN,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);
    fund = mp.fund.firstWhere((f) => f.shareClassCode == fundOrder?.fundCode);

    MarketProvider().setAccountDetails(
        accountNumber: fundOrder?.accountNumber ?? '',
        clientRef: fundOrder?.clientRef);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        bottom: OrderDetailsWidgets.buildHeader(
          logoUrl: fund.logoUrl,
          title: fundOrder?.name ?? '',
          isBuyOrder: fundOrder?.transactionType.toLowerCase() == 'buy',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor().lowerBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          OrderDetailsWidgets.buildDetailItem(
                              context: context,
                              leftLabel: 'Nav',
                              leftValue: '#buy/sale NAV',
                              rightLabel: 'Exchange',
                              rightValue: 'iTrust'),
                          OrderDetailsWidgets.buildDetailItem(
                              context: context,
                              leftLabel: 'Control Number',
                              leftValue: '${fundOrder?.clientRef}',
                              showCopyButton: true),
                          OrderDetailsWidgets.buildDetailItem(
                              context: context,
                              leftLabel: 'Date',
                              leftValue: DateFormat("dd MMM yyyy")
                                  .format(DateTime.parse('${fundOrder?.date}')),
                              rightLabel: 'Amount',
                              rightValue:
                                  'TZS. ${currencyFormat(double.tryParse(fundOrder?.amount ?? '0'))}',
                              hideBorder: true),
                          OrderDetailsWidgets.buildDetailItem(
                              context: context,
                              leftLabel: '',
                              leftValue: 'Order Status',
                              rightLabel: '',
                              rightValue:
                                  '${fundOrder?.getFriendlyStatus()['label']}'
                                      .toUpperCase(),
                              isStatus: true,
                              statusColor:
                                  fundOrder?.getFriendlyStatus()['color'],
                              hideBorder: true),
                        ],
                      ),
                    ),
                    // if (fundOrder?.status.toLowerCase() == "pending")
                    //   _buildPaymentSection(mp),
                    TextButton.icon(
                      onPressed: () => howToPayDialog(
                        appHeight: MediaQuery.of(context).size.height,
                        appWidth: MediaQuery.of(context).size.width,
                        context: context,
                        accountNumber: fundOrder?.accountNumber ?? '',
                        clientReference: fundOrder?.clientRef ?? '',
                        fundName: fundOrder?.name ?? '',
                        fundCode: fundOrder?.fundCode ?? '',
                        fundId: fundOrder?.fundId ?? '',
                        purchaseId: fundOrder?.id ?? '',
                        amount: fundOrder?.amount ?? '',
                        mp: mp,
                      ),
                      icon:
                          Icon(Icons.help_outline, color: AppColor().orangeApp),
                      label: Text(
                        "Need help with payment?",
                        style: TextStyle(
                          color: AppColor().orangeApp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (fundOrder?.status.toLowerCase() == 'pending' &&
                  fundOrder?.transactionType.toLowerCase() == 'buy')
                largeBTN(
                    double.infinity, 'Complete Payment', AppColor().blueBTN,
                    () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => PaymentOptionsPage(
                        paymentType: 'fund',
                        name: fundOrder?.name ?? '',
                        amount: fundOrder?.amount ?? '0',
                        orderId: fundOrder?.id ?? '',
                        logoUrl: fund.logoUrl),
                  );
                })
            ],
          ),
        ),
      ),
    );
  }
}
