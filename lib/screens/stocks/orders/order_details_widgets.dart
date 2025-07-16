import 'package:flutter/services.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrderDetailsWidgets {
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

  static PreferredSizeWidget buildHeader(
      {required String logoUrl,
      required String title,
      required bool isBuyOrder,
      String? subtitle,
      Color? bgColor,
      EdgeInsets? margin,
      Widget? rightWidget}) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 70),
      child: Container(
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
                child: Image.network(
                  logoUrl,
                  fit: BoxFit.contain,
                  height: 56,
                  width: 56,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance,
                      size: 44,
                      color: Colors.grey),
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    return Stack(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: child,
                        ),
                        child
                      ],
                    );
                  },
                )),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
      ),
    );
  }
}
