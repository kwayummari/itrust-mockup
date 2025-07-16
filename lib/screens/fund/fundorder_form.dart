import 'package:flutter/foundation.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/widgets/loading.dart';
import 'package:iwealth/utility/number_formatter.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/widgets/btmSheet.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class FundOrderForm extends StatefulWidget {
  String fundName, chareClass;
  String? curVal;
  bool isSubscripiton;
  final String? subscriptionId;
  final bool isDialog;
  final String initialMinContribution;
  final String subsequentAmount;

  FundOrderForm({
    super.key,
    required this.fundName,
    required this.chareClass,
    required this.isSubscripiton,
    required this.initialMinContribution,
    required this.subsequentAmount,
    this.curVal,
    this.subscriptionId,
    this.isDialog = false,
  });

  @override
  State<FundOrderForm> createState() => _FundOrderFormState();
}

class _FundOrderFormState extends State<FundOrderForm>
    with SingleTickerProviderStateMixin {
  final currFormat = NumberFormat("#,##0.00", "en_US");
  final formKey = GlobalKey<FormState>();
  final redeemForm = GlobalKey<FormState>();
  bool isChecked = false;
  bool isRedeemRotate = false;
  TextEditingController amountController = TextEditingController();
  TextEditingController redeemAmount = TextEditingController();

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _redeemFocusNode = FocusNode();
  bool hasInvestedBefore = false;

  @override
  void initState() {
    super.initState();
    _checkPreviousInvestment();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  void _checkPreviousInvestment() {
    final mp = Provider.of<MarketProvider>(context, listen: false);
    hasInvestedBefore = mp.eachFundPortfolio.any(
      (fund) => fund.stockID == widget.chareClass,
    );
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _redeemFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void placeFund({appWidth, appHeight, required mp}) {
    if (formKey.currentState!.validate()) {
      final cleanAmount = amountController.text.replaceAll(',', '');
      if (double.tryParse(cleanAmount) != null) {
        if (kDebugMode) {
          print('${widget.fundName} Code is: ${widget.chareClass}');
        }
        Btmsheet().fundConfirmOrder(
            w: appWidth,
            h: appHeight,
            amount: cleanAmount,
            tickerSymbol: widget.fundName,
            shareClassCode: widget.chareClass,
            fundId: widget.chareClass,
            context: context,
            mp: mp);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount format')),
        );
      }
    }
  }

  void redempt(MarketProvider mp) async {
    var fundOrderStatus = await StockWaiter().placeRedemptionOrder(
      shareClassCode: widget.chareClass,
      salesValue: redeemAmount.text.replaceAll(',', ''),
      context: context,
    );

    if (fundOrderStatus['status'] == true) {
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              btn: const Text(""),
              successMessage: "Request have sent successfully",
              txtDesc: "Check your order in order list screen",
              screen: const BottomNavBarWidget(),
            ),
          ),
          (route) => false);
    }
  }

  Widget _buildHeader() {
    if (widget.isDialog) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor().blueBTN,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fundName,
                    style: TextStyle(
                      color: AppColor().constant,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isSubscripiton ? "New Investment" : "Redemption",
                    style: TextStyle(
                      color: AppColor().constant.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: AppColor().constant),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }
    // Return existing header for full screen
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColor().blueBTN,
        boxShadow: [
          BoxShadow(
            color: AppColor().blueBTN.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _buildBackButton(),
            const SizedBox(width: 16),
            Expanded(child: _buildHeaderTitle()),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.arrow_back_ios_new,
              color: AppColor().constant, size: 20),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.fundName,
          style: TextStyle(
            color: AppColor().constant,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.isSubscripiton ? "New Investment" : "Redemption",
          style: TextStyle(
            color: AppColor().constant.withOpacity(0.9),
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(bool isSubscription) {
    final controller = isSubscription ? amountController : redeemAmount;
    final focusNode = isSubscription ? _amountFocusNode : _redeemFocusNode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor().blueBTN.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSubscription ? "Investment Amount" : "Redemption Amount",
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSubscription
                ? "Enter the amount you wish to invest.\nYour order will be completed in 1 working day."
                : "Enter the amount you wish to redeem.\nYour order will be completed in 3 working days.",
            style: TextStyle(
              color: AppColor().textColor.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
              _numberFormatter,
            ],
            onChanged: (value) {
              if (isSubscription) {
                formKey.currentState?.validate();
              } else {
                redeemForm.currentState?.validate();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final cleanValue = value.replaceAll(',', '');
              if (double.tryParse(cleanValue) == null) {
                return 'Please enter a valid number';
              }
              final amount = double.parse(cleanValue);
              if (isSubscription) {
                final minRequired = hasInvestedBefore
                    ? double.parse(widget.subsequentAmount)
                    : double.parse(widget.initialMinContribution);

                if (amount >= minRequired) {
                  return null;
                }
                return hasInvestedBefore
                    ? 'Subsequent investment must be at least \n TZS ${NumberFormat('#,##0.00').format(minRequired)}'
                    : 'Initial investment must be at least \n TZS ${NumberFormat('#,##0.00').format(minRequired)}';
              } else {
                double minRedemption =
                    widget.fundName.toLowerCase() == 'iincome' ? 100000 : 10000;
                if (amount < minRedemption) {
                  return 'Minimum redemption amount is TZS ${NumberFormat('#,##0.00').format(minRedemption)}';
                }
                if (double.parse(widget.curVal!) < amount) {
                  return "Insufficient balance: TZS ${NumberFormat('#,##0.00').format(
                    double.parse(
                      widget.curVal!,
                    ),
                  )}";
                }
              }
              return null;
            },
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColor().bgLight.withOpacity(0.05),
              hintText: "Enter Amount",
              hintStyle: TextStyle(
                color: AppColor().grayText.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor().blueBTN.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "TZS",
                  style: TextStyle(
                    color: AppColor().blueBTN,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColor().blueBTN.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColor().blueBTN,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
          ),
          if (!isSubscription) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (val) => setState(() => isChecked = !isChecked),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: AppColor().blueBTN,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "I confirm this redemption request",
                  style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(MarketProvider mp) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor().blueBTN.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.isSubscripiton
            ? () => placeFund(
                appHeight: MediaQuery.of(context).size.height,
                appWidth: MediaQuery.of(context).size.width,
                mp: mp)
            : isChecked
                ? () async {
                    if (redeemForm.currentState!.validate()) {
                      setState(() => isRedeemRotate = true);
                      redempt(mp);
                      if (isRedeemRotate) loading(context);
                    }
                  }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor().blueBTN,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.isSubscripiton ? "Invest Now" : "Redeem Now",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<MarketProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    Widget content = Column(
      mainAxisSize: widget.isDialog ? MainAxisSize.min : MainAxisSize.max,
      children: [
        _buildHeader(),
        if (widget.isDialog)
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Form(
                  key: widget.isSubscripiton ? formKey : redeemForm,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAmountInput(widget.isSubscripiton),
                      SizedBox(height: screenSize.height * 0.02),
                      _buildActionButton(mp),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Form(
                  key: widget.isSubscripiton ? formKey : redeemForm,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildAmountInput(widget.isSubscripiton),
                      ),
                      _buildActionButton(mp),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.isDialog) {
      return content;
    }

    return GestureDetector(
      onTap: () {
        _amountFocusNode.unfocus();
        _redeemFocusNode.unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppColor().appGradient),
          child: content,
        ),
      ),
    );
  }
}
