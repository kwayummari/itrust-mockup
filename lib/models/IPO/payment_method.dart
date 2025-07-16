import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/IPO/subscription.dart';
import 'package:iwealth/screens/stocks/orders/order_details_widgets.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utilities/filtera_subsc.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';

// This is the new entry point for showing the modal.
// It creates and returns the new StatefulWidget.

class PayBy extends StatefulWidget {
  final String name;
  final String amount;
  final String orderId;
  final String paymentType;
  final MarketProvider mp;
  final String? logoUrl;

  const PayBy({
    required this.name,
    required this.amount,
    required this.orderId,
    required this.paymentType,
    required this.mp,
    this.logoUrl,
    // required this.isAzamPay,
    super.key,
  });

  @override
  State<PayBy> createState() => PayByState();
}

class PayByState extends State<PayBy> {
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedGateway;
  bool _isLoading = false; // To manage the loading state of the button
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: "TZ");
  final formKey = GlobalKey<FormState>();
  final paymentGateways = [
    {
      "name": "Mixx by Yas (Tigo Pesa)",
      "value": "tigo",
      'icon':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Yas_Tanzania.svg/640px-Yas_Tanzania.svg.png'
    },
    {
      "name": "Azam Pay",
      "value": "azampay",
      'icon':
          'https://azampesa.co.tz/wp-content/uploads/2023/05/AzamPesa-logo.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    final userProf = SessionPref.getUserProfile() ?? [];
    if (userProf.isNotEmpty) {
      setState(() {
        _phoneNumber = PhoneNumber(
          isoCode: "TZ",
          phoneNumber: userProf[4],
        );
      });
    }
  }

  @override
  void dispose() {
    // Always dispose of controllers to prevent memory leaks.
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (formKey.currentContext == null || !formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator on the button
    });
    // The loading(context) dialog can be disruptive. Disabling it in favor of a button indicator.
    // loading(context);
    Map<String, dynamic> result;

    try {
      // if (widget.isAzamPay) {
      //   result = await StockWaiter().payByAzamPesa(
      //     phoneNumber: fullPhoneNumber,
      //     amount: widget.amount,
      //     purchaseId: widget.purchaseId,
      //     context: context,
      //   );
      // } else {
      result = await StockWaiter().payByMobile(
        paymentType: widget.paymentType,
        phoneNumber: _phoneNumber.phoneNumber.toString().substring(1),
        amount: widget.amount,
        purchaseId: widget.orderId,
        context: context,
        gateway: widget.paymentType == 'fund' || widget.paymentType == 'stock'
            ? _selectedGateway
            : null,
      );

      print('result: $result');
      // }

      if (result["status"] == "success") {
        // Close the modal before navigating to the success screen
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              btn: const SizedBox
                  .shrink(), // Using SizedBox.shrink() for an empty widget
              successMessage:
                  result["message"] ?? "Payment Initiated Successfully",
              txtDesc: "You will receive a prompt to complete the payment.",
              screen: const BottomNavBarWidget(
                currentIndex: 2,
              ), // Or navigate back to a relevant screen
            ),
          ),
        );
      }
      // else {
      //   _showErrorDialog(
      //     "Payment Error",
      //     "Failed to process payment. \n${result['response']?['message'] ?? 'Unknown error occurred.'}",
      //   );
      // }
    } catch (e) {
      // Catch any unexpected errors during the API call
      // Navigator.pop(context); // Hide loading indicator
      // _showErrorDialog(
      //     "An Error Occurred", "Something went wrong: ${e.toString()}");
    } finally {
      // Ensure the loading state is always reset
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0).copyWith(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
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
                  logoUrl: widget.logoUrl ?? '',
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
              // Content
              const SizedBox(height: 16),
              Text(
                "Amount",
                style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor().inputFieldColor,
                  border: Border.all(color: AppColor().inputFieldColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "TZS ${currencyFormat(double.parse(widget.amount))}",
                  style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),

              CustomTextfield().phoneNumber(
                (val) => setState(() => _phoneNumber = val),
                _phoneNumber,
              ),
              const SizedBox(height: 16),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Gateway",
                      style: TextStyle(
                          color: AppColor().textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGateway, // Binds to the state variable
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(0),
                          filled: true,
                          fillColor: AppColor().inputFieldColor,
                        ),
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(12),
                        isExpanded: false,
                        hint: Text(
                          "Select Payment Gateway",
                          style: TextStyle(color: AppColor().grayText),
                        ),
                        dropdownColor: AppColor().mainColor,

                        items: paymentGateways
                            .map((item) => DropdownMenuItem(
                                  value: item['value'],
                                  child: Row(
                                    children: [
                                      if (item['icon'] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Image.network(
                                            item['icon']!,
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                      Text(item['name'] ?? ''),
                                    ],
                                  ),
                                ))
                            .toList(),

                        // No more StatefulBuilder needed. setState will rebuild the whole widget.
                        onChanged: (value) {
                          setState(() {
                            _selectedGateway = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a payment gateway.";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                  onPressed: _isLoading ? null : _processPayment,
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
                            Icon(Icons.lock_outline,
                                color: AppColor().constant),
                            const SizedBox(width: 8),
                            Text(
                              "Pay Securely",
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
            ],
          ),
        ),
      ),
    );
  }
}

Widget payByWallet({
  required String name,
  required String fundCode,
  required String amount,
  required String purchasesId,
  required String fundId,
  required MarketProvider mp,
  required BuildContext context,
}) {
  return SingleChildScrollView(
    child: Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: ExpansionTile(
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        collapsedBackgroundColor: AppColor().blueBTN,
        backgroundColor: AppColor().blueBTN,
        title: ListTile(
          leading: Icon(
            Icons.wallet,
            color: AppColor().constant,
          ),
          title: Text(
            "Pay By Wallet",
            style: TextStyle(color: AppColor().constant, fontSize: 17.0),
          ),
        ),
        children: [
          ListTile(
            title: Text(
              "Fund Name",
              style: TextStyle(color: AppColor().constant),
            ),
            subtitle: Text(
              name,
              style: TextStyle(color: AppColor().constant),
            ),
          ),
          ListTile(
            title: Text(
              "Amount",
              style: TextStyle(color: AppColor().constant),
            ),
            subtitle: Text(
              "TZS ${currencyFormat(double.parse(amount))}",
              style: TextStyle(color: AppColor().constant),
            ),
          ),
          Text(
            "Wallet Balance(TZS ${currencyFormat(mp.portfolio?.wallet ?? 0)} ) ",
            style: TextStyle(color: AppColor().blueBTN),
          ),
          Divider(
            color: AppColor().blueBTN,
          ),
          double.parse("${mp.portfolio?.wallet}") >= double.parse(amount)
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor().blueBTN,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () async {
                    loading(context);
                    var status = await StockWaiter().placeFundOrder(
                        shareClassCode: fundCode,
                        purchasesValue: amount,
                        fundId: fundId,
                        context: context);

                    if (status == "1") {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                            btn: const Text(""),
                            successMessage: "Paid Successfully",
                            txtDesc: "",
                            screen: IPOSubscriptionListScreen(
                              subsData: filterSubsc(fundCode: fundCode, mp: mp),
                            ),
                          ),
                        ),
                      );
                    } else {
                      Navigator.pop(context); // Stop loading indicator
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Payment Error"),
                            content: Text(
                                "Failed to process payment. Please try again later. Error: $status"),
                            actions: [
                              TextButton(
                                child: const Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: AppColor().blueBTN),
                  ),
                )
              : const Text(
                  "Insufficient Fund to do this transaction",
                  style: TextStyle(color: Colors.red),
                )
        ],
      ),
    ),
  );
}
