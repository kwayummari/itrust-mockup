import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/fund_payment_options.dart';
import 'package:iwealth/screens/fund/transaction_details.dart';
import 'package:iwealth/stocks/widgets/wallet.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/utility/number_formatter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({super.key});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  bool isVisible = false;
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  String? _amount;

  final TextInputFormatter _numberFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final newText = NumberFormatter.formatNumber(text.replaceAll(',', ''));
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  });

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_formatAmount);
  }

  void _formatAmount() {
    String text = _amountController.text.replaceAll(',', '');
    if (text.isNotEmpty) {
      _amountController.value = TextEditingValue(
        text: NumberFormatter.formatNumber(text),
        selection: TextSelection.collapsed(
            offset: NumberFormatter.formatNumber(text).length),
      );
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatAmount);
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appHeights = MediaQuery.of(context).size.height;
    final double appWidths = MediaQuery.of(context).size.width;
    final MarketProvider marketProvider = Provider.of<MarketProvider>(context);

    return GestureDetector(
      onTap: () {
        _amountFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text('My Wallet'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: walletCard(
                      appHeights,
                      appWidths,
                      currencyFormat(
                          marketProvider.portfolio?.availableBalance ?? 0),
                      () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                      isVisible,
                      marketProvider,
                      context,
                      showActionButtons: false,
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add Funds",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          focusNode: _amountFocusNode,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _numberFormatter,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Enter an amount',
                            prefixText: 'TZS ',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade400,
                                )),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: _amountButton(
                                  "+TZS 1,000",
                                  () {
                                    _amountController.text = "1000";
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: _amountButton(
                                  "+TZS 2,000",
                                  () {
                                    _amountController.text = "2000";
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: _amountButton(
                                  "+TZS 5,000",
                                  () {
                                    _amountController.text = "5000";
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _amount = _amountController.text;
                              if (_amount != null && _amount!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FundPaymentOptionsScreen(
                                      amount: _amount!,
                                    ),
                                  ),
                                );
                                // Perform proceed action
                                if (kDebugMode) {
                                  print(
                                      "Proceed with amount: ${_amountController.text}");
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please enter an amount')));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade500,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Proceed',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transaction",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "View All >",
                        style: TextStyle(color: AppColor().orangeApp),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Netflix Entertainment",
                  "12,343.00",
                  "Paid on 13 Dec, 12:53 PM",
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
                const SizedBox(height: 8),
                _transactionItem(
                  "Grace Salome",
                  "1,99,345.00",
                  "Received on 13 Dec, 12:53 PM",
                  isReceived: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _amountButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.grey),
      ),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _transactionItem(String name, String amount, String date,
      {bool isReceived = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(
              name: name,
              amount: amount,
              date: date,
              isReceived: isReceived,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(date,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                Text("${isReceived ? "+ " : ""}TZS $amount",
                    style: TextStyle(
                        color:
                            isReceived ? Colors.green.shade600 : Colors.black,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            const Divider(
              color: Color.fromARGB(90, 158, 158, 158),
              thickness: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}
