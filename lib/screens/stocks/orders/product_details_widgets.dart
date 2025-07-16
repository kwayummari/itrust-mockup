import 'package:flutter/services.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/utility/device_info_helper.dart';
import 'package:iwealth/utility/number_fomatter.dart';

class OverviewRowItemData {
  final String label;
  final String value;
  final String symbol;
  OverviewRowItemData({
    required this.label,
    required this.value,
    required this.symbol,
  });
}

class ProductDetailsWidgets {
  static Widget buildDetailItem(
      {required BuildContext context,
      required String leftLabel,
      required String leftValue,
      String? rightLabel,
      String? rightValue,
      bool isStatus = false,
      Color? statusColor,
      bool showCopyButton = false,
      bool hideBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: hideBorder ? Colors.transparent : AppColor().divider,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(2, (index) {
          if (showCopyButton && index == 1) {
            return Expanded(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.copy, color: AppColor().blueBTN),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: leftValue));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (index == 1 && rightLabel == null && rightValue == null) {
            return const SizedBox.shrink();
          }

          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isStatus)
                  Text(
                    index == 0 ? leftLabel : rightLabel!,
                    style: TextStyle(
                      color: AppColor().grayText,
                      fontSize: 14,
                    ),
                  ),
                Text(
                  index == 0 ? leftValue : rightValue!,
                  style: TextStyle(
                    color: index == 1
                        ? statusColor ?? AppColor().textColor
                        : AppColor().textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  static Widget buildProductValueItem({
    required BuildContext context,
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    required String leftSymbol,
    required String rightSymbol,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColor().lowerBg,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(2, (index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 1 ? 16.0 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0 ? leftLabel : rightLabel,
                  style: TextStyle(
                    color: AppColor().grayText,
                    fontSize: 14,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (index == 0 ? leftSymbol : rightSymbol).toUpperCase(),
                      style: TextStyle(
                        color: AppColor().grayText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      index == 0 ? leftValue : rightValue,
                      style: TextStyle(
                        color: AppColor().textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  static Widget buildProductHeader(
      {required String logoUrl,
      required String title,
      required String subtitle,
      required double profitLoss}) {
    final bool isPositive = profitLoss >= 0;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      // padding: const EdgeInsets.symmetric(
      //   horizontal: 20.0,
      // ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              // color: AppColor().lowerBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: logoUrl.isNotEmpty
                    ? logoUrl.contains('http')
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.contain,
                            height: 56,
                            width: 56,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.account_balance,
                                    size: 44, color: Colors.grey),
                          )
                        : Image.asset(
                            logoUrl,
                            fit: BoxFit.contain,
                            height: 56,
                            width: 56,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.account_balance,
                                    size: 56, color: Colors.grey),
                          )
                    : const Icon(Icons.account_balance,
                        size: 56, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor().grayText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up
                    : isPositive
                        ? Icons.trending_flat
                        : Icons.trending_down,
                color: isPositive
                    ? Colors.green
                    : isPositive
                        ? Colors.green
                        : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "${isPositive ? '+' : ''} ${currencyFormat(profitLoss)}%",
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildProductValue(
      {required String logoUrl,
      required String title,
      bool isBuyOrder = false,
      String? subtitle,
      Color? bgColor,
      EdgeInsets? margin,
      Widget? rightWidget}) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor ?? AppColor().lowerBg,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: logoUrl.isNotEmpty
                  ? logoUrl.contains('http')
                      ? Image.network(
                          logoUrl,
                          fit: BoxFit.contain,
                          height: 56,
                          width: 56,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.account_balance,
                                  size: 44, color: Colors.grey),
                        )
                      : Image.asset(
                          logoUrl,
                          fit: BoxFit.contain,
                          height: 56,
                          width: 56,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.account_balance,
                                  size: 56, color: Colors.grey),
                        )
                  : const Icon(Icons.account_balance,
                      size: 56, color: Colors.grey),
            ),
          ),

          //  Image.network(
          //   logoUrl,
          //   fit: BoxFit.contain,
          //   height: 56,
          //   width: 56,
          //   errorBuilder: (context, error, stackTrace) => const Icon(
          //       Icons.account_balance,
          //       size: 44,
          //       color: Colors.grey),
          //   loadingBuilder: (BuildContext context, Widget child,
          //       ImageChunkEvent? loadingProgress) {
          //     return Stack(
          //       children: [
          //         Shimmer.fromColors(
          //           baseColor: Colors.grey[300]!,
          //           highlightColor: Colors.grey[100]!,
          //           child: child,
          //         ),
          //         child
          //       ],
          //     );
          //   },
          // )),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 2),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: (isBuyOrder
                              ? AppColor().blueBTN
                              : AppColor().orangeApp)
                          .withAlpha(10),
                    ),
                    child: Text(
                      '${isBuyOrder ? 'Buy' : 'Sale'} Order',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isBuyOrder
                            ? AppColor().primaryBlue
                            : AppColor().orangeApp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (rightWidget != null) rightWidget,
        ],
      ),
    );
  }

  static Widget buildOverviewRowItem({
    required String label,
    required String value,
    required String symbol,
    bool hideBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      // decoration: hideBorder
      //     ? null
      //     : BoxDecoration(
      //         border: Border(
      //           bottom: BorderSide(
      //             color: AppColor().divider,
      //           ),
      //         ),
      //       ),
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
          Row(
            children: [
              Text(
                symbol,
                style: TextStyle(
                  color: AppColor().grayText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: AppColor().textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildFundAccountRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isReference = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColor().grayText,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              if (isReference && value.isNotEmpty && value != 'N/A')
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 20,
                    color: AppColor().blueBTN,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: AppColor().textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
