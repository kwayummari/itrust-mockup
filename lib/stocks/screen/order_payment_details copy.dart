import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/payment_method.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart'; // Use StockWaiter
import 'package:iwealth/stocks/models/order.dart';
import 'package:iwealth/stocks/screen/stock_order_list.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/pop_up_dialog.dart';
import 'package:iwealth/widgets/snack_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/widgets/document_picker.dart';

Color parseColor(String colorStr) {
  try {
    if (colorStr.startsWith('#')) {
      return Color(int.parse(colorStr.replaceFirst('#', '0xff')));
    } else if (colorStr.length == 6) {
      return Color(int.parse('0xff$colorStr'));
    }
  } catch (e) {}
  return Colors.black;
}

class OrderPaymentDetailsPage extends StatefulWidget {
  final Order order;

  const OrderPaymentDetailsPage({super.key, required this.order});

  @override
  State<OrderPaymentDetailsPage> createState() =>
      _OrderPaymentDetailsPageState();
}

class _OrderPaymentDetailsPageState extends State<OrderPaymentDetailsPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController desc = TextEditingController();
  File? receipt;
  String? proofFile;

  late AnimationController _animationController;

  bool _isLoadingFees = true;
  String? _feeError;
  double? _transactionFees;
  double? _finalTotalAmount;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrderFees();
    });

    final double price = double.tryParse(widget.order.price ?? '') ?? 0.0;
    final double volume = double.tryParse(widget.order.volume ?? '') ?? 0.0;
    final double totalAmount = price * volume;

    paidAmount.text = totalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _animationController.dispose();
    paidAmount.dispose();
    desc.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderFees() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFees = true;
      _feeError = null;
    });

    final mp = Provider.of<MarketProvider>(context, listen: false);

    try {
      print('--- 🚀 DEBUG: Preparing to fetch fees for Order ---');
      var encoder = const JsonEncoder.withIndent('  ');
      print(encoder.convert(widget.order.toMap()));
      print('----------------------------------------------------');

      var chargestatus = await StockWaiter().getFeesCharges(widget.order, mp);

      print('--- ✅ DEBUG: Fee calculation status: $chargestatus ---');
      print(
          '--- 💰 DEBUG: FeeCharge object from provider: ${mp.feeCharge?.payout}, fees: ${mp.feeCharge?.totalFees} ---');
      print('----------------------------------------------------');

      if (chargestatus == '1' && mounted) {
        final String payoutString = mp.feeCharge?.payout ?? '0';
        final String feesString = mp.feeCharge?.totalFees ?? '0';

        final double finalAmountToPay =
            double.tryParse(payoutString.replaceAll(',', '')) ?? 0.0;
        final double transactionFees =
            double.tryParse(feesString.replaceAll(',', '')) ?? 0.0;

        setState(() {
          _transactionFees = transactionFees;
          _finalTotalAmount = finalAmountToPay;

          paidAmount.text = finalAmountToPay.toStringAsFixed(2);

          _isLoadingFees = false;
        });
      } else {
        throw Exception("API did not return a success status ('1').");
      }
    } catch (e) {
      if (kDebugMode) {
        print('--- ❌ DEBUG: Error in _fetchOrderFees: $e ---');
      }
      if (mounted) {
        setState(() {
          _feeError = "Could not calculate transaction fees. Please try again.";
          _isLoadingFees = false;
        });
      }
    }
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
            response: "Please enter a valid amount",
          ).show(context);
          return;
        }

        final wholeAmount = parsedAmount.round().toString();

        var status = await StockWaiter().uploadProofOfPayment(
            context: context,
            receipt: receipt!,
            amount: wholeAmount,
            description: desc.text,
            purchaseId: widget.order.stockID!,
            paymentType: 'stock');
        if (status == "success") {
          await StockWaiter().getOrders(mp);
          appSnackBar(
              msg: "Payment Proof Submitted Successfully", context: context);
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SuccessScreen(
                      btn: const Text(""),
                      successMessage: "Paid Successfully",
                      txtDesc: "Your order payment has been submitted.",
                      screen: const OrderListPage())));
        } else {
          Navigator.pop(context);
          AppSnackbar(
            isError: true,
            response: "Failed to submit Payment Proof.",
          ).show(context);
        }
      } else {
        popUpDialog("Please Upload Receipt", "Okay", AppColor().textColor,
            Icons.warning, () => Navigator.pop(context), context);
      }
    }
  }

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
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting document: $e')),
        );
      }
    }
  }

  Widget _buildInfoCard(String title, String value,
      {Color? valueColor, bool canCopy = false}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppColor().textColor.withOpacity(0.7),
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(value,
                      style: TextStyle(
                          color: valueColor ?? AppColor().textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (canCopy)
              IconButton(
                icon: Icon(Icons.copy,
                    color: AppColor().blueBTN.withOpacity(0.5)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final friendly = widget.order.getFriendlyStatus();
    final statusColor = friendly['color'];
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(friendly['icon'] as IconData, color: statusColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Status", style: TextStyle(fontSize: 14)),
                Text(friendly['label'] as String,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(MarketProvider mp) {
    final String totalAmount = _finalTotalAmount?.toStringAsFixed(2) ?? "0.00";

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
                        const BorderRadius.vertical(top: Radius.circular(4))),
                child: Text("Payment Options",
                    style: TextStyle(
                        color: AppColor().blueBTN,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
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
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                child: PayBy(
                                  paymentType: 'stock',
                                  name: widget.order.stockName!,
                                  amount: totalAmount,
                                  orderId: widget.order.stockID!,
                                  mp: mp,
                                ),
                              ),
                            ),
                          );
                        },
                        child: _buildPaymentOptionItem(
                            "Pay via TigoPesa", Icons.phone_android),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                  paymentType: 'order',
                                  name: widget.order.stockName!,
                                  amount: totalAmount,
                                  orderId: widget.order.stockID!,
                                  mp: mp,
                                  // isAzamPay: true,
                                ),
                              ),
                            ),
                          );
                        },
                        child: _buildPaymentOptionItem(
                            "Pay via Azam Pay", Icons.payment),
                      ),
                    ),
                    const SizedBox(height: 16),
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
        if (receipt != null)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomTextfield().amountToSent(
                          hint: "Enter amount paid",
                          label: "Amount Paid*",
                          inputType: TextInputType.number,
                          minAmount: 1, // Or whatever the minimum is
                          controller: paidAmount,
                          valueCapture: (val) {},
                        ),
                        _buildSubmitButton(mp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

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
    final double price = double.tryParse(widget.order.price ?? '') ?? 0.0;
    final double volume = double.tryParse(widget.order.volume ?? '') ?? 0.0;
    final double baseAmount = price * volume;

    return Scaffold(
      backgroundColor: AppColor().blueBTN,
      appBar: AppBar(
        backgroundColor: AppColor().blueBTN,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: const Text("Order Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColor().appGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.order.stockName!,
                style: TextStyle(
                    color: AppColor().textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 24)),
            const SizedBox(height: 16),
            _buildInfoCard("Quantity", widget.order.volume!, canCopy: false),
            _buildInfoCard("Price per Share", "TZS ${currencyFormat(price)}",
                canCopy: false),
            _buildInfoCard(
              "Order Value",
              "TZS ${currencyFormat(baseAmount)}",
              valueColor: AppColor().orangeApp,
            ),
            _buildFeeAndTotalSection(),
            _buildStatusIndicator(),
            if (widget.order.status?.toLowerCase() == 'new')
              _buildPaymentSection(mp),
            TextButton.icon(
              onPressed: () => (),
              icon: Icon(Icons.help_outline, color: AppColor().orangeApp),
              label: Text("Need help with payment?",
                  style: TextStyle(
                      color: AppColor().orangeApp,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeAndTotalSection() {
    if (_isLoadingFees) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: AppColor().blueBTN),
              ),
              const SizedBox(width: 16),
              Text("Calculating fees and total...",
                  style:
                      TextStyle(color: AppColor().textColor.withOpacity(0.8))),
            ],
          ),
        ),
      );
    }

    if (_feeError != null) {
      return Card(
        color: Colors.red.shade50,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(_feeError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                onPressed: _fetchOrderFees,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor().blueBTN),
              )
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildInfoCard(
          "Transaction Fees",
          "TZS ${currencyFormat(_transactionFees ?? 0.0)}",
        ),
        _buildInfoCard(
          "Total Amount to Pay",
          "TZS ${currencyFormat(_finalTotalAmount ?? 0.0)}",
          valueColor: AppColor().orangeApp,
        ),
      ],
    );
  }
}
