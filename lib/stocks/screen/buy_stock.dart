import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/models/order.dart';
import 'package:iwealth/stocks/screen/stock_fee.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BuyStockScreen extends StatefulWidget {
  String tickerSymbol,
      orderType,
      changeAmount,
      changePercentage,
      price,
      btnTxt,
      stockID,
      logoUrl;
  Color btnColor;
  int qnty;
  BuyStockScreen({
    super.key,
    required this.changeAmount,
    required this.changePercentage,
    required this.price,
    required this.tickerSymbol,
    required this.btnTxt,
    required this.btnColor,
    required this.stockID,
    required this.orderType,
    required this.qnty,
    required this.logoUrl,
  });

  @override
  State<BuyStockScreen> createState() => _BuyStockScreenState();
}

class _BuyStockScreenState extends State<BuyStockScreen> {
  final formKey = GlobalKey<FormState>();
  String? numberOfShares;
  bool isRotate = false;
  double? total = 0.0;

  // Add focus node for shares
  final FocusNode _sharesFocusNode = FocusNode();

  @override
  void dispose() {
    _sharesFocusNode.dispose();
    super.dispose();
  }

  void placeOrder(MarketProvider mp) async {
    if (formKey.currentState!.validate()) {
      if (numberOfShares == null || numberOfShares!.isEmpty) {
        print("Error: Volume cannot be null or empty");
        return;
      }

      print("Volume before placing order: $numberOfShares");
      Order order = Order(
        stockName: widget.tickerSymbol,
        hasCustodian: false,
        mode: "market",
        orderType: widget.orderType,
        price: widget.price,
        stockID: widget.stockID,
        volume: numberOfShares.toString(),
      );
      setState(() {
        isRotate = true;
      });
      var chargestatus = await StockWaiter().getFeesCharges(order, mp);
      if (chargestatus == "1") {
        setState(() {
          isRotate = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockFeeScreen(
              order: order,
              amount: mp.feeCharge!.payout,
              stockName: order.stockName!,
              orderType: widget.orderType,
              logoUrl: widget.logoUrl,
            ),
          ),
        );
      }
    }
  }

  final currFormat = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final size = MediaQuery.of(context).size;

    try {
      total = double.parse("$numberOfShares") * double.parse(widget.price);
    } catch (e) {
      total = 0.0; // Set total to 0.0 on error
      if (kDebugMode) {
        print("Invalid Format $e");
      }
    }

    return GestureDetector(
      onTap: () {
        _sharesFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor().textColor,
              size: 20,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tickerSymbol,
                style: TextStyle(
                  color: AppColor().textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.changeAmount,
                    style: TextStyle(
                      color: double.parse(widget.changeAmount) > 0
                          ? Colors.green.shade600
                          : double.parse(widget.changeAmount) == 0
                              ? Colors.amber.shade700
                              : Colors.red.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    " |  ${widget.changePercentage}%",
                    style: TextStyle(
                      color: double.parse(widget.changeAmount) > 0
                          ? Colors.green.shade600
                          : double.parse(widget.changeAmount) == 0
                              ? Colors.amber.shade700
                              : Colors.red.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Price Summary Card
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.btnColor,
                                widget.btnColor.withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Price",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "TZS ${widget.price}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${widget.changePercentage}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        // Order Details
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInputField(
                                "Price Per Share",
                                widget.price,
                                null, // No onChanged since it’s not editable
                                Icons.monetization_on_outlined,
                                false, // Disabled
                              ),
                              const SizedBox(height: 6),
                              _buildInputField(
                                "Number of Shares",
                                "",
                                (val) => setState(() => numberOfShares = val),
                                Icons.shopping_basket_outlined,
                                true, // Enabled
                                isShares: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Total and Action Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              color: AppColor().textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "TZS ${currencyFormat(total)}",
                            style: TextStyle(
                              color: AppColor().blueBTN,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => placeOrder(marketProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.btnColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isRotate
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColor().constant,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.btnTxt,
                                  style: TextStyle(
                                    color: AppColor().constant,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String initialValue,
    Function(String?)? onChanged,
    IconData icon,
    bool isEnabled, {
    bool isShares = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor().textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          enabled: isEnabled,
          keyboardType: TextInputType.number,
          focusNode: isShares ? _sharesFocusNode : null,
          style: TextStyle(
            color: isEnabled ? AppColor().textColor : Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: isShares && isEnabled ? "Enter number of shares" : null,
            prefixIcon: Icon(
              icon,
              color: isEnabled ? AppColor().blueBTN : Colors.grey.shade400,
            ),
            prefixText: label == "Price Per Share" ? "TZS " : null,
            prefixStyle: TextStyle(
              color: isEnabled ? AppColor().textColor : Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isEnabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor().blueBTN),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            suffixIcon: label == "Price Per Share" && !isEnabled
                ? Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade400,
                    size: 16,
                  )
                : null,
          ),
          validator: (value) {
            if (isEnabled && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            if (isShares && isEnabled) {
              final shares = int.tryParse(value ?? '');
              if (shares == null) {
                return 'Please enter a valid number';
              }
              if (shares < 10) {
                return 'Minimum order is 10 shares';
              }
              if (widget.orderType == 'sell' && shares > widget.qnty) {
                return 'You can only sell up to ${widget.qnty} shares';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
