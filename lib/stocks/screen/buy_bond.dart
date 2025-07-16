import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/providers/market.dart'; // Keep your import
import 'package:iwealth/screens/bonds/bond_fee_screen.dart'; // Keep your import
import 'package:iwealth/services/stocks/apis_request.dart'; // Keep your import
import 'package:iwealth/stocks/models/bond_model.dart'; // Keep your import
import 'package:iwealth/stocks/models/bond_order_model.dart'; // Keep your import

class BuyBondScreen extends StatefulWidget {
  final Bond bond;

  const BuyBondScreen({super.key, required this.bond});

  @override
  _BuyBondScreenState createState() => _BuyBondScreenState();
}

class _BuyBondScreenState extends State<BuyBondScreen> {
  final _formKey = GlobalKey<FormState>();
  final _faceValueController = TextEditingController();
  final _noticeController = TextEditingController();
  final bool _useCustodian = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _faceValueController.dispose();
    _noticeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final marketProvider = Provider.of<MarketProvider>(context, listen: false);

    final order = BondOrderRequest(
      bond: widget.bond.id!,
      price: widget.bond.price,
      faceValue: double.parse(_faceValueController.text
          .replaceAll(',', '')), // Handle formatted input
      notice: _noticeController.text,
      paymentOption: 'wallet',
    );

    try {
      await StockWaiter().calculateBondOrderFees(
        order: order,
        mp: marketProvider,
        context: context,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BondFeeScreen(
            order: order,
            bond: widget.bond,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _modernInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIconData,
    required ThemeData theme,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.blueGrey[400], fontSize: 15),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.blueGrey[300], fontSize: 15),
      prefixIcon: Icon(prefixIconData, color: Colors.blueGrey[300], size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueGrey.shade100, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0.00');
    final theme = Theme.of(context);

    // Define modern text styles
    final TextStyle infoLabelStyle = TextStyle(
        fontWeight: FontWeight.w500, fontSize: 14, color: Colors.blueGrey[400]);
    final TextStyle infoValueStyle = TextStyle(
        fontWeight: FontWeight.w600, fontSize: 15, color: Colors.blueGrey[700]);
    final Color accentButtonColor = AppColor().blueBTN; // Or theme.primaryColor

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          '${widget.bond.securityName}',
          style: TextStyle(
            color: Colors.blueGrey[800],
            fontWeight: FontWeight.bold,
            fontSize: 18, // Slightly smaller for more space if name is long
          ),
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Colors.blueGrey[700], size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Makes sure content is scrollable if it overflows
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bond Information Section
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blueGrey.shade100,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order Summary",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey[700]),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow('Bond', widget.bond.securityName!,
                                    infoLabelStyle, infoValueStyle),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                    'Price',
                                    "TZS ${numberFormat.format(widget.bond.price)}",
                                    infoLabelStyle,
                                    infoValueStyle),
                                const SizedBox(height: 8),
                                _buildInfoRow('ISIN', widget.bond.isin ?? 'N/A',
                                    infoLabelStyle, infoValueStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _faceValueController,
                            decoration: _modernInputDecoration(
                              labelText: 'Face Value (TZS)',
                              hintText: 'Enter amount',
                              prefixIconData:
                                  Icons.account_balance_wallet_outlined,
                              theme: theme,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d,]')),
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                String digits =
                                    newValue.text.replaceAll(',', '');
                                if (digits.isEmpty) {
                                  return newValue.copyWith(text: '');
                                }
                                final number = double.tryParse(digits);
                                if (number == null) return oldValue;
                                final formatter = NumberFormat('#,##0');
                                final newText = formatter.format(number);
                                return TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                      offset: newText.length),
                                );
                              }),
                            ],
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                                fontWeight: FontWeight.w500),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter face value';
                              }
                              final numericValue =
                                  double.tryParse(value.replaceAll(',', ''));
                              if (numericValue == null || numericValue <= 0) {
                                return 'Please enter a valid positive face value';
                              }
                              if (numericValue < widget.bond.minBidAmount) {
                                return 'Face value must be at least ${NumberFormat('#,##0').format(widget.bond.minBidAmount)}';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                // Place Order Button - outside SingleChildScrollView
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _placeOrder(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            accentButtonColor, // Primary action color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _isLoading ? 0 : 2, // Subtle elevation
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Proceed to Confirmation',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2, // Allow security name to wrap if very long
          ),
        ),
      ],
    );
  }
}
