import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/User/screen/successfully.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/fundorder_form.dart';
import 'package:iwealth/screens/fund/fund_details_screen.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/screen/buy_stock.dart';
import 'package:iwealth/stocks/widgets/error_msg.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:iwealth/widgets/animation_wrapper.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:iwealth/widgets/custom_ftextfield.dart';
import 'package:iwealth/widgets/register_now_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart'; // Add this import

class Btmsheet {
  static const double borderRadius = 20.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Add a utility method for generating unique hero tags
  String _getUniqueHeroTag(String baseTag) {
    const uuid = Uuid();
    return '${baseTag}_${uuid.v4()}';
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColor().grayText.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildActionButton(
      {required String text,
      required Color color,
      required VoidCallback onPressed,
      required double width}) {
    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetContainer({
    required Widget child,
    required BuildContext context,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          // Clamp the opacity value between 0 and 1
          final safeOpacity = value.clamp(0.0, 1.0);

          return Transform.scale(
            scale: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: safeOpacity,
                child: child,
              ),
            ),
          );
        },
        child: child,
      ),
    );
  }

  Widget _buildAnimatedContainer({
    required Widget child,
    required BuildContext context,
  }) {
    // Generate a unique tag for this instance
    final heroTag = _getUniqueHeroTag('dialog_content');

    return Hero(
      tag: heroTag,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            // Ensure opacity is always between 0 and 1
            final safeOpacity = value.clamp(0.0, 1.0);
            final safeScale = 0.5 + (0.5 * value).clamp(0.0, 1.0);

            return Transform.scale(
              scale: safeScale,
              child: Opacity(
                opacity: safeOpacity,
                child: child,
              ),
            );
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor().bgLight,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetHeader(String title) {
    return Column(
      children: [
        _buildDragHandle(),
        Text(
          title,
          style: TextStyle(
            color: AppColor().textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColor().grayText,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContainer(String message, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColor().blueBTN.withOpacity(0.1)
            : AppColor().bgLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? AppColor().blueBTN.withOpacity(0.3)
              : AppColor().grayText.withOpacity(0.2),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isHighlighted ? AppColor().blueBTN : AppColor().textColor,
          fontSize: 16,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIconHeader(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 32,
      ),
    );
  }

  showComingFeature(context, msg, appWidths, appHeights) {
    return showDialog(
      barrierColor: AppColor().selected.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return _buildAnimatedContainer(
          context: context,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated logo with pulse effect
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: _buildIconHeader(
                        Icons.upcoming_rounded,
                        AppColor().blueBTN,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Animated message reveal
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: _buildMessageContainer(msg, isHighlighted: true),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  ErrorMsg().thanks,
                  style: TextStyle(
                    color: AppColor().grayText,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildActionButton(
                  text: "Got It",
                  color: AppColor().orangeApp,
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showConfirm(context, headerText, msg, appWidths, appHeights,
      {String? title, required VoidCallback onConfirm}) {
    return showDialog(
      barrierColor: AppColor().mainColor.withAlpha(100),
      context: context,
      builder: (BuildContext context) {
        return _buildAnimatedContainer(
          context: context,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headerText,
                  style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                if (title != null && title.isNotEmpty)
                  AnimationWrapper(
                    index: 1,
                    type: 'fadeIn',
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppColor().textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                AnimationWrapper(
                  index: 2,
                  type: 'fadeIn',
                  child: Text(
                    msg,
                    style: TextStyle(
                      color: AppColor().grayText,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('No'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColor().bgLight,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(
                            fontSize: 16,
                          ),
                          foregroundColor: AppColor().textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: onConfirm,
                      child: const Text('Yes'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ))
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  nidaQuestion(
      context, msg, formKey, onVal, btnPressed, appWidths, appHeights) {
    return showDialog(
      barrierColor: AppColor().selected.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return _buildAnimatedContainer(
          context: context,
          child: Container(
            width: appWidths,
            padding: const EdgeInsets.only(top: 20, left: 20.0, right: 20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      "assets/images/icon-top-itr-down.svg",
                      width: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "Please answer the following Identification question to verify your identity",
                      style: TextStyle(color: AppColor().textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextfield().name(
                        "Write Answer here", msg, TextInputType.name, onVal),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor().orangeApp),
                    onPressed: btnPressed,
                    child: Text(
                      "Submit",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                  ),
                  SizedBox(
                    height: appHeights * 0.05,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  errorSheet(context, String? errTitle, String? errDesc,
      {Function? onPressed, bool showRetry = false, VoidCallback? onRetry}) {
    final title = errTitle ?? 'Error';
    final description = errDesc ?? 'An error occurred';

    return showDialog(
      barrierColor: AppColor().selected.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return _buildAnimatedContainer(
          context: context,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: -1.0, end: 0.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 0.1,
                      child: _buildIconHeader(
                        Icons.error_outline_rounded,
                        AppColor().orangeApp,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: 1.0,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMessageContainer(description),
                const SizedBox(height: 24),
                if (showRetry && onRetry != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (onPressed != null) {
                                    onPressed();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColor().grayText),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Close",
                                  style: TextStyle(
                                    color: AppColor().grayText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: _buildActionButton(
                                text: "Retry",
                                color: AppColor().blueBTN,
                                onPressed: () {
                                  Navigator.pop(context);
                                  onRetry();
                                },
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: _buildActionButton(
                          text: "Got It",
                          color: AppColor().orangeApp,
                          onPressed: () {
                            Navigator.pop(context);
                            if (onPressed != null) {
                              onPressed();
                            }
                          },
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  stockPortfolioClickablel(
      {context,
      tickerSymbol,
      avgPrice,
      marketPrice,
      qnty,
      changeAmount,
      changePercentage,
      stockID,
      required String logoUrl,
      required double w,
      required double h}) {
    return showDialog(
      barrierColor: AppColor().selected.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return _buildAnimatedContainer(
          context: context,
          child: Container(
            padding: const EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetHeader(tickerSymbol),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor().bgLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColor().grayText.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Quantity", qnty),
                      _buildInfoRow("Market Price", "TZS $marketPrice"),
                      _buildInfoRow("Average Price",
                          "TZS ${currencyFormat(double.parse("$avgPrice"))}"),
                      _buildInfoRow("Change", "$changePercentage%"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColor().orangeApp.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColor().orangeApp),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuyStockScreen(
                                qnty: int.parse(qnty),
                                changeAmount: changeAmount,
                                changePercentage: changePercentage,
                                price: marketPrice,
                                tickerSymbol: tickerSymbol,
                                btnTxt: "Continue",
                                btnColor: AppColor().orangeApp,
                                stockID: stockID,
                                orderType: "sell",
                                logoUrl: logoUrl,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.trending_down,
                            color: AppColor().orangeApp),
                        label: Text(
                          "Sell Stock",
                          style: TextStyle(
                            color: AppColor().orangeApp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor().blueBTN,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuyStockScreen(
                                qnty: int.parse(qnty),
                                changeAmount: changeAmount,
                                changePercentage: changePercentage,
                                price: marketPrice,
                                tickerSymbol: tickerSymbol,
                                btnTxt: "Continue",
                                btnColor: AppColor().blueBTN,
                                stockID: stockID,
                                orderType: "buy",
                                logoUrl: logoUrl,
                              ),
                            ),
                          );
                        },
                        icon:
                            Icon(Icons.trending_up, color: AppColor().constant),
                        label: Text(
                          "Buy More",
                          style: TextStyle(
                            color: AppColor().constant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================== MUTUAL FUNDS ================================

  fundPortfolioClickablel(
      {context,
      tickerSymbol,
      avgPrice,
      currentVal,
      unitPrice,
      units,
      stockID,
      required String initialMinContribution,
      required String subsequentAmount,
      required double w,
      required double h}) {
    return showDialog(
      barrierColor: AppColor().selected.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return _buildAnimatedContainer(
          context: context,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fund info section
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColor().bgLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColor().grayText.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tickerSymbol,
                            style: TextStyle(
                              color: AppColor().textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColor().blueBTN.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${currencyFormat(double.parse(units))} Units",
                              style: TextStyle(
                                color: AppColor().blueBTN,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Unit Price(TZS)",
                                style: TextStyle(
                                  color: AppColor().grayText,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                double.parse(unitPrice.toString())
                                    .toStringAsFixed(4),
                                style: TextStyle(
                                  color: AppColor().textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Current Value(TZS)",
                                style: TextStyle(
                                  color: AppColor().grayText,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${currencyFormat(currentVal)}",
                                style: TextStyle(
                                  color: AppColor().textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColor().orangeApp.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: AppColor().orangeApp),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FundOrderForm(
                                curVal: "$currentVal",
                                isSubscripiton: false,
                                fundName: tickerSymbol,
                                chareClass: stockID,
                                initialMinContribution:
                                    initialMinContribution, // Add this
                                subsequentAmount: subsequentAmount, // Add this
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.swap_horizontal_circle,
                            color: AppColor().orangeApp),
                        label: Text(
                          "Redeem",
                          style: TextStyle(color: AppColor().orangeApp),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor().blueBTN,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FundOrderForm(
                                isSubscripiton: true,
                                fundName: tickerSymbol,
                                chareClass: stockID,
                                curVal: "$currentVal",
                                initialMinContribution: initialMinContribution,
                                subsequentAmount: subsequentAmount,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.add_circle_outline,
                            color: AppColor().constant),
                        label: Text(
                          "Invest Now",
                          style: TextStyle(color: AppColor().constant),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }

  void fundConfirmOrder({
    required double w,
    required double h,
    required String amount,
    required String tickerSymbol,
    required String shareClassCode,
    required String fundId,
    required BuildContext context,
    required MarketProvider mp,
  }) {
    try {
      // Find the fund details
      final fund = mp.fund.firstWhere(
        (f) => f.shareClassCode == shareClassCode,
        orElse: () => throw Exception('Fund not found'),
      );

      if (fund == null) {
        throw Exception('Fund details not available');
      }

      // Check if user has invested before
      bool hasInvestedBefore = false;
      hasInvestedBefore = mp.eachFundPortfolio!.any(
        (f) => f.stockID == shareClassCode,
      );

      // Validate minimum amount
      final cleanAmount = double.parse(amount.replaceAll(',', ''));
      final minRequired = hasInvestedBefore
          ? double.parse(fund.subsequentAmount)
          : double.parse(fund.initialMinContribution);

      if (cleanAmount < minRequired) {
        errorSheet(
          context,
          'Invalid Amount',
          hasInvestedBefore
              ? 'Subsequent investment must be at least TZS ${NumberFormat('#,##0.00').format(minRequired)}'
              : 'Initial investment must be at least TZS ${NumberFormat('#,##0.00').format(minRequired)}',
        );
        return;
      }

      // Continue with the existing confirmation dialog
      // Ensure any existing dialogs are dismissed
      Navigator.of(context, rootNavigator: true).popUntil((route) {
        return route.isFirst || route.settings.name == 'MainRoute';
      });

      // Show bottom sheet
      showDialog(
        barrierColor: AppColor().selected.withOpacity(0.5),
        context: context,
        builder: (BuildContext context) {
          return _buildAnimatedContainer(
            context: context,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      "Mutual Fund Name",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    subtitle: Text(
                      tickerSymbol,
                      style: TextStyle(color: AppColor().grayText),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Amount",
                      style: TextStyle(color: AppColor().textColor),
                    ),
                    subtitle: Text(
                      "TZS  ${currencyFormat(double.parse(amount))}",
                      style: TextStyle(color: AppColor().grayText),
                    ),
                  ),
                  Divider(
                    color: AppColor().grayText,
                  ),
                  orderBtn(w, 50.0, "Confirm & Place Order", AppColor().blueBTN,
                      () async {
                    if (double.parse(amount) < 500) {
                      Btmsheet().errorSheet(context, "Invalid Amount",
                          "The amount must be at least 500 TZS.");
                      return;
                    }
                    showDialog(
                        barrierColor: AppColor().selected,
                        context: context,
                        builder: (context) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColor().blueBTN,
                            ),
                          );
                        });
                    var fundOrderStatus = await StockWaiter().placeFundOrder(
                      shareClassCode: shareClassCode,
                      fundId: fundId, // Pass the fundId dynamically
                      purchasesValue: amount,
                      context: context,
                    );

                    if (fundOrderStatus == "1") {
                      var fundPortfolioStatus = await StockWaiter()
                          .fundPortfolio(context: context, mp: mp);
                      await StockWaiter()
                          .getPortfolio(provider: mp, context: context);
                      if (fundPortfolioStatus == "1") {
                        var fundOrderStatus = await StockWaiter()
                            .getFundOrders(mp: mp, context: context);
                        if (fundOrderStatus == "1" ||
                            fundOrderStatus == "success") {
                          var fundDetails =
                              await StockWaiter().getFundOrderDetails(
                            fundCode: shareClassCode,
                            context: context,
                            mp: mp,
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BottomNavBarWidget(
                                currentIndex: 2,
                              ),
                            ),
                            (route) => false,
                          );
                        } else {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SuccessScreen(
                                      btn: const Text(""),
                                      successMessage:
                                          "Failed to retrive order information for now But You have successfully purchased Funds Units",
                                      txtDesc:
                                          "Visit your fund order list later to see changes",
                                      screen: const BottomNavBarWidget())),
                              (route) => false);
                        }
                      } else {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SuccessScreen(
                                    btn: const Text(""),
                                    successMessage:
                                        " You have successfully purchases Funds Units",
                                    txtDesc:
                                        "Check your order in ordelist screen, and check later on your potfolio to view changes",
                                    screen: const BottomNavBarWidget(
                                      currentIndex: 2,
                                    ))),
                            (route) => false);
                      }
                    } else {
                      Navigator.pop(context);
                      Btmsheet().errorSheet(
                        context,
                        "Failed to purchase a Fund",
                        "Something went wrong please try again",
                      );
                    }
                  }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  )
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      errorSheet(
        context,
        'Error',
        'Unable to process your investment request. Please try again later.',
      );
      if (kDebugMode) {
        print('Error in fundConfirmOrder: $e');
      }
    }
  }

  //  =========== CONTACT US ===============

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> _launchWhatsApp(String whatsAppPhoneNumber) async {
    // Remove any spaces or special characters from phone number
    whatsAppPhoneNumber = whatsAppPhoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri uri = Uri.parse('whatsapp://send?phone=$whatsAppPhoneNumber');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch WhatsApp');
    }
  }
}

class ContactBottomSheet {
  static const String phoneNumber = "+255 659 071 777";
  static const String whatsAppPhoneNumber = "+255 710 422 427";
  static const String email = "customerservice@itrust.co.tz";

  static void _launchPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static void _launchEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(launchUri);
  }

  static void _launchWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/$phoneNumber');
    await launchUrl(launchUri);
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Contact Options",
                style: TextStyle(
                  color: AppColor().blueBTN,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.call, color: AppColor().blueBTN),
                title: Text("Call Us",
                    style: TextStyle(color: AppColor().textColor)),
                subtitle: Text(phoneNumber,
                    style: TextStyle(color: AppColor().blueBTN)),
                onTap: () {
                  Navigator.pop(context);
                  _launchPhoneCall(phoneNumber);
                },
              ),
              ListTile(
                leading: Icon(Icons.email, color: AppColor().blueBTN),
                title: Text("Mail Us",
                    style: TextStyle(color: AppColor().textColor)),
                subtitle:
                    Text(email, style: TextStyle(color: AppColor().blueBTN)),
                onTap: () {
                  Navigator.pop(context);
                  _launchEmail(email);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: Text("WhatsApp Us",
                    style: TextStyle(color: AppColor().textColor)),
                subtitle: Text(phoneNumber,
                    style: TextStyle(color: AppColor().blueBTN)),
                onTap: () {
                  Navigator.pop(context);
                  _launchWhatsApp(whatsAppPhoneNumber);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
