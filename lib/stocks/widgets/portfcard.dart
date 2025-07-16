import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/fund/fundorder_form.dart';
import 'package:iwealth/stocks/screen/buy_stock.dart';
import 'package:iwealth/utility/number_fomatter.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/btmSheet.dart';
import 'package:iwealth/widgets/shimmer_loading.dart';

Widget generalPortfolioCard(
  appHeight,
  appWidth,
  invValue,
  currValue,
  profitLoss,
  profitLossPercentage,
  type,
) {
  final bool isLoading = invValue == "0.00" && currValue == "0.00";

  return Container(
    height: appHeight * 0.21, // Reduced height
    width: appWidth,
    decoration: BoxDecoration(
      color: AppColor().blueBTN,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // Add this
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          // Wrap the content in Expanded
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$type Portfolio Overview ",
                    style: TextStyle(
                        color: AppColor().constant,
                        fontSize: 18.0,
                        letterSpacing: 1.0,
                        wordSpacing: 5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Divider(
                    color: AppColor().constant,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Invested Value(TZS)",
                            style: TextStyle(color: AppColor().constant),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: isLoading
                                ? ShimmerLoading(
                                    width: appWidth * 0.3,
                                    height: 20,
                                    borderRadius: 4,
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "$invValue",
                                      style: TextStyle(
                                        color: AppColor().constant,
                                        fontSize: 14.0,
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current Value(TZS)",
                            style: TextStyle(color: AppColor().constant),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: isLoading
                                ? ShimmerLoading(
                                    width: appWidth * 0.3,
                                    height: 20,
                                    borderRadius: 4,
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "$currValue",
                                      style: TextStyle(
                                        color: AppColor().constant,
                                        fontSize: 14.0,
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColor().selected,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Row(
            children: [
              Text(
                "Overall Profit/Loss(TZS)",
                style: TextStyle(color: AppColor().constant),
              ),
              const Spacer(),
              isLoading
                  ? ShimmerLoading(
                      width: appWidth * 0.3,
                      height: 20,
                      borderRadius: 4,
                    )
                  : double.parse("$profitLoss") > 0
                      ? Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                "${currencyFormat(profitLoss)}",
                                style: TextStyle(color: AppColor().constant),
                              ),
                            ),
                          ],
                        )
                      : double.parse("$profitLoss") < 0
                          ? Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "${currencyFormat(profitLoss)}",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "${currencyFormat(profitLoss)}",
                                    style:
                                        TextStyle(color: AppColor().constant),
                                  ),
                                ),
                                Text(
                                  "$profitLossPercentage%",
                                  style: TextStyle(color: AppColor().constant),
                                )
                              ],
                            )
            ],
          ),
        )
      ],
    ),
  );
}

Widget specificPortfolioCard({
  appHeight,
  appWidth,
  required bool isStock,
  qnty,
  avgPrice,
  invVal,
  currentVal,
  marketPrice,
  changeAmount,
  changePercentage,
  stockID,
  context,
  required String logoUrl,
  required String title,
  String? initialMinContribution,
  String? subsequentAmount,
  double profitLoss = 0,
}) {
  final bool isPositive = profitLoss > 0;
  final bool isNegative = profitLoss < 0;

  void showFundActionDialog(BuildContext context, bool isSubscription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: screenSize.height * 0.02,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenSize.width * 0.92,
              maxHeight: screenSize.height * 0.85,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FundOrderForm(
                fundName: title,
                chareClass: stockID,
                isSubscripiton: isSubscription,
                curVal: "$currentVal",
                isDialog: true,
                initialMinContribution: initialMinContribution ?? '100000',
                subsequentAmount: subsequentAmount ?? '100000',
              ),
            ),
          ),
        );
      },
    );
  }

  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: () {
      isStock
          ? Btmsheet().stockPortfolioClickablel(
              avgPrice: avgPrice,
              context: context,
              marketPrice: marketPrice,
              qnty: qnty,
              tickerSymbol: title,
              changeAmount: changeAmount,
              changePercentage: changePercentage,
              stockID: stockID,
              h: appHeight,
              w: appWidth,
              logoUrl: logoUrl,
            )
          : Btmsheet().fundPortfolioClickablel(
              avgPrice: avgPrice,
              context: context,
              currentVal: currentVal,
              units: qnty,
              unitPrice: avgPrice,
              tickerSymbol: title,
              stockID: stockID,
              initialMinContribution: initialMinContribution ?? '10000',
              subsequentAmount: subsequentAmount ?? '10000',
              h: appHeight,
              w: appWidth);
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor().grayText.withAlpha(100),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColor().grayText.withAlpha(100))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: logoUrl.isNotEmpty
                            ? Image.network(
                                logoUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                isStock
                                    ? Icons.show_chart
                                    : Icons.account_balance,
                                color: AppColor().blueBTN,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColor().textColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricItem(
                        "Invested(TZS)",
                        "$invVal",
                        Icons.account_balance_wallet,
                      ),
                      _buildMetricItem(
                        "Current(TZS)",
                        "${currencyFormat(currentVal)}",
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ),
                // if (!isStock) ...[
                //   const SizedBox(height: 20),
                //   Row(
                //     children: [
                //       Expanded(
                //         child: _buildActionButton(
                //           "Redeem",
                //           Icons.swap_horizontal_circle,
                //           AppColor().orangeApp,
                //           true,
                //           () => showFundActionDialog(context, false),
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: _buildActionButton(
                //           "Invest Now",
                //           Icons.add_circle_outline,
                //           AppColor().blueBTN,
                //           false,
                //           () => showFundActionDialog(context, true),
                //         ),
                //       ),
                //     ],
                //   ),
                // ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: AppColor().lowerBg,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profit/Loss",
                  style: TextStyle(
                    color: AppColor().textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up
                          : isNegative
                              ? Icons.trending_down
                              : Icons.trending_flat,
                      color: isPositive
                          ? Colors.green
                          : isNegative
                              ? Colors.red
                              : AppColor().blueBTN,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${isPositive ? '+' : ''}TZS ${currencyFormat(profitLoss)}",
                      style: TextStyle(
                        color: isPositive
                            ? Colors.green
                            : isNegative
                                ? Colors.red
                                : AppColor().blueBTN,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMetricItem(String label, String value, IconData icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: AppColor().grayText,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget _buildActionButton(String label, IconData icon, Color color,
    bool isOutlined, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.white : color,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOutlined ? BorderSide(color: color) : BorderSide.none,
      ),
      elevation: isOutlined ? 0 : 2,
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isOutlined ? color : Colors.white,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isOutlined ? color : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
