import 'dart:io';

import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/payment_method.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/stocks/orders/order_details_widgets.dart';
import 'package:iwealth/services/stocks/apis_request.dart'; // Use StockWaiter
import 'package:iwealth/stocks/screen/stock_order_list.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/animation_wrapper.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/pop_up_dialog.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:iwealth/widgets/snack_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/widgets/document_picker.dart';

class UploadProofPayment extends StatefulWidget {
  final String paymentType;
  final String name;
  final String amount;
  final String orderId;
  final String logoUrl;
  final MarketProvider mp;

  const UploadProofPayment(
      {super.key,
      required this.logoUrl,
      required this.paymentType,
      required this.name,
      required this.amount,
      required this.orderId,
      required this.mp});

  @override
  State<UploadProofPayment> createState() => _OrderUploadProofPaymentState();
}

class _OrderUploadProofPaymentState extends State<UploadProofPayment> {
  final formKey = GlobalKey<FormState>();
  TextEditingController desc = TextEditingController(text: '');
  TextEditingController paidAmount = TextEditingController();
  File? receipt;
  String? proofFile;
  String? receiptError;
  bool _isLoading = false;

  @override
  void dispose() {
    desc.dispose();
    paidAmount.dispose();
    super.dispose();
  }

  void submitProofOfpayment({required MarketProvider mp}) async {
    if (formKey.currentState!.validate() && proofFile != null) {
      setState(() {
        _isLoading = true;
        receiptError = null;
      });
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
      // Default to success for this example
      var status = await StockWaiter().uploadProofOfPayment(
        context: context,
        receipt: receipt!,
        amount: wholeAmount,
        description: desc.text,
        purchaseId: widget.orderId,
        paymentType: widget.paymentType,
      );
      if (status == "success") {
        await StockWaiter().getOrders(mp);
        appSnackBar(
            msg: "Payment Proof Submitted Successfully", context: context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SuccessScreen(
                    btn: const Text(""),
                    successMessage: "Paid Successfully",
                    txtDesc: "Your order payment has been submitted.",
                    screen: const BottomNavBarWidget(
                      currentIndex: 2,
                    ))));
      } else {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        AppSnackbar(
          isError: true,
          response: "Failed to submit Payment Proof.",
        ).show(context);
      }
    } else {
      if (proofFile == null) {
        setState(() {
          receiptError = "Please upload a receipt";
        });
      }
    }
  }

  void takePicture(File? selectedFile) {
    // if (!mounted) return;
    try {
      if (selectedFile != null) {
        setState(() {
          receipt = selectedFile;
          proofFile = selectedFile.path.split('/').last;
        });
      } else {
        setState(() {
          receipt = null;
          proofFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting document: $e')),
        );
      }
    }
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

  Widget _receiptName(IconData icon, String text, Color color) {
    return AnimationWrapper(
      index: 1,
      delayPerItem: 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color:
                    color == AppColor().blueBTN ? AppColor().grayText : color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16).copyWith(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColor().mainColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderDetailsWidgets.buildHeader(
                  logoUrl: widget.logoUrl,
                  title: widget.name,
                  isBuyOrder: true,
                  margin: const EdgeInsets.all(0),
                  bgColor: Colors.transparent,
                  rightWidget: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: AppColor().textColor,
                      ))),
              const SizedBox(height: 16),
              Text(
                "Upload Proof of Payment",
                style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                // padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (proofFile != null)
                      _receiptName(
                        Icons.check_circle,
                        proofFile ?? '',
                        AppColor().success,
                      )
                    else if (receiptError != null)
                      _receiptName(
                        Icons.upload_file,
                        receiptError ?? '',
                        Colors.red,
                      ),
                    // else if (proofFile == null)
                    //   _receiptName(
                    //     Icons.upload_file,
                    //     'No file selected',
                    //     AppColor().blueBTN,
                    //   ),
                    DocumentPicker.newPickDocument(
                      context: context,
                      allowedExtensions: ["pdf", "png", "jpg"],
                      onFileSelected: takePicture,
                    ),
                  ],
                ),
              ),
              CustomTextfield().amountToSent(
                hint: "Enter amount paid",
                label: "Amount Paid",
                inputType: TextInputType.number,
                minAmount: 1, // Or whatever the minimum is
                controller: paidAmount,
                valueCapture: (val) {
                  setState(() {
                    paidAmount.text = val;
                  });
                },
              ),
              CustomTextfield().nameNQ(
                "Enter description",
                "Description(optional)",
                TextInputType.text,
                (val) {
                  setState(() {
                    desc.text = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor().blueBTN,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  // Disable button while loading, and call our processing function
                  onPressed: () => submitProofOfpayment(mp: widget.mp),
                  // onPressed: () {
                  //   setState(() {
                  //     _isLoading = true;
                  //   });
                  // },
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon(Icons.lock_outline,
                            //     color: AppColor().constant),
                            // const SizedBox(width: 8),
                            Text(
                              "Confirm",
                              style: TextStyle(
                                color: AppColor().constant,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
