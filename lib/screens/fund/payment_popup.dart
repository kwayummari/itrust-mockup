import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'; // Import package
import 'package:iwealth/services/wallet/api_requests.dart'; // Import WalletWaiter
import 'package:iwealth/widgets/custom_ftextfield.dart'; // Custom widgets

class PaymentPopupScreen extends StatefulWidget {
  final String initialAmount;

  const PaymentPopupScreen({super.key, required this.initialAmount});

  @override
  _PaymentPopupScreenState createState() => _PaymentPopupScreenState();
}

class _PaymentPopupScreenState extends State<PaymentPopupScreen> {
  late TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  PhoneNumber? _selectedPhoneNumber;
  final FocusNode _phoneFocusNode = FocusNode();
  bool isLoading = false; // Loader state

  @override
  void initState() {
    super.initState();
    // Set the initial amount as a string directly to the controller
    _amountController = TextEditingController(text: widget.initialAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      // Parse the string to a double for calculations
      double amount = double.parse(_amountController.text.replaceAll(",", ""));
      String phoneNumber = _selectedPhoneNumber?.phoneNumber ?? "Unknown";

      // WalletWaiter to process payment
      WalletWaiter().processPayment(
        amount: amount,
        phoneNumber: phoneNumber,
        context: context,
      );
    }
  }

  // Method for phone number widget
  Widget payPhoneNumber(onChange, phoneNumber) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Text(
              "Payment Phone Number",
              style: TextStyle(
                color: Colors.blue, // Change to your preferred color
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InternationalPhoneNumberInput(
            onInputChanged: onChange,
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            textStyle: const TextStyle(
                color: Colors.blue), // Change to your preferred color
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.onUserInteraction,
            selectorTextStyle: const TextStyle(
                color: Colors.blue), // Change to your preferred color
            initialValue: phoneNumber,
            textFieldController: TextEditingController(),
            inputDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
              hintText: "712 345 678",
              hintStyle: const TextStyle(
                  color: Colors.grey), // Change to your preferred color
              fillColor: Colors.blue.shade100, // Change to your preferred color
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextfield().amountToSent(
              hint: "Enter amount",
              label: "Amount",
              inputType: const TextInputType.numberWithOptions(decimal: true),
              controller: _amountController,
              minAmount: 500.0, // Set a minimum amount requirement
              valueCapture: (value) => _amountController.text = value,
            ),
            const SizedBox(height: 10),
            CustomTextfield().phoneNumber(
              (PhoneNumber phoneNumber) {
                setState(() {
                  _selectedPhoneNumber = phoneNumber;
                });
              },
              _selectedPhoneNumber ?? PhoneNumber(isoCode: 'TZ'),
              focusNode: _phoneFocusNode,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : _processPayment, // Disable when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white) // Show loader
                      : const Text('Proceed', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
