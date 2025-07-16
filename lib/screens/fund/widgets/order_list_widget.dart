import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/screens/IPO/view_subsc.dart';
import 'package:iwealth/stocks/models/bond_orders_model.dart';
import 'package:iwealth/stocks/screen/bond_order_details.dart';
import 'package:iwealth/utility/device_info_helper.dart';
import 'package:shimmer/shimmer.dart';

import '../../../stocks/models/order.dart';
import '../../stocks/orders/details_order.dart';

class OrderListWidget {
  static final currencyFormat = NumberFormat("#,##0.00", "en_US");

  static DateTime parsedDate(dynamic date) {
    try {
      return date is DateTime ? date : DateTime.parse(date);
    } catch (e) {
      // Handle parsing error, return a default date or rethrow
      return DateTime.now();
    }
  }

  static Widget buildStickyOrderList({
    required BuildContext context,
    required ScrollController scrollController,
    Map<String, List<IPOSubscription>>? groupedFundsOrders,
    Map<String, List<BondOrder>>? groupedBondsOrders,
    Map<String, List<Order>>? groupedStockOrders,
    required bool isLoading,
    Widget? filterWidget,
    bool filterOpened = false,
    VoidCallback? onFilterToggle,
  }) {
    if (isLoading) {
      return _buildShimmerLoading(); // Show shimmer while loading
    }

    var groupedOrders =
        groupedFundsOrders ?? groupedBondsOrders ?? groupedStockOrders;
    List<String> sortedDates =
        groupedOrders == null ? [] : groupedOrders.keys.toList()
          ..sort((a, b) {
            DateTime dateA = DateFormat('dd MMM yyyy').parse(a);
            DateTime dateB = DateFormat('dd MMM yyyy').parse(b);
            return dateB.compareTo(dateA);
          });

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Column(
          children: [
            if (filterWidget != null) filterWidget,
            if (groupedOrders == null || groupedOrders.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/no_orders.svg',
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No orders found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    for (final date in sortedDates)
                      SliverMainAxisGroup(
                        slivers: [
                          SliverAppBar(
                            automaticallyImplyLeading: false,
                            title: Text(
                              textAlign: TextAlign.start,
                              DateFormat.yMMMEd().format(
                                  DateFormat('dd MMM yyyy').parse(date)),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColor().textColor,
                              ),
                            ),
                            centerTitle: false,
                            expandedHeight: 50.0,
                            pinned: true,
                            backgroundColor: AppColor().mainColor,
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, idx) {
                                final isFirst = idx == 0;
                                final isLast = groupedOrders[date] == null ||
                                    idx == groupedOrders[date]!.length - 1;
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 0),
                                  padding: EdgeInsets.only(
                                      top: isFirst ? 8 : 0,
                                      bottom: isLast ? 8 : 0),
                                  decoration: BoxDecoration(
                                    color: AppColor().lowerBg,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(isFirst ? 15 : 0),
                                      bottom: Radius.circular(isLast ? 15 : 0),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      if (groupedFundsOrders != null)
                                        _buildFundOrderCard(
                                          context: context,
                                          fundOrder:
                                              groupedFundsOrders[date]![idx],
                                        ),
                                      if (groupedStockOrders != null)
                                        _buildStockOrderCard(
                                          context: context,
                                          order: groupedStockOrders[date]![idx],
                                        ),
                                      if (groupedBondsOrders != null)
                                        _buildBondOrderCard(
                                            context: context,
                                            order:
                                                groupedBondsOrders[date]![idx]),
                                      if (!isLast)
                                        Divider(
                                          endIndent: 16,
                                          indent: 16,
                                          color: AppColor().divider,
                                        ),
                                    ],
                                  ),
                                );
                              },
                              childCount: groupedOrders[date]!.length,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
        if (onFilterToggle != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: onFilterToggle,
              child: Container(
                height: 38,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColor().lowerBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  Icons.filter_alt_outlined,
                  size: 24,
                  color:
                      filterOpened ? AppColor().orangeApp : AppColor().blueBTN,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3, // Show fewer items while shimmer loading
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date shimmer
              Container(
                width: 120,
                height: 24,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Card shimmer
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          height: 20,
                          color: Colors.white,
                        ),
                        Container(
                          width: 80,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 100,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFundOrderCard({
    required BuildContext context,
    required IPOSubscription fundOrder,
  }) {
    final order = fundOrder;
    final friendly = order.getFriendlyStatus();
    final isBuy = order.transactionType.toLowerCase() == 'buy';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: _buildTitle(
        name: order.name,
        amount: order.amount,
        leftMidText: '',
        rightMidText: '',
      ),
      subtitle: _buildSubtitle(
          statusLabel: friendly['label'] ?? '',
          statusColor: friendly['color'],
          typeLabel: isBuy ? 'buy' : 'sale',
          useMainColor: isBuy,
          date: DateTime.parse(order.date)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSubscription(
              fundOrder: order,
            ),
          ),
        );
      },
    );
  }

  static Widget _buildStockOrderCard({
    required BuildContext context,
    required Order order,
  }) {
    final friendly = order.getFriendlyStatus();
    final bool isNew = order.status?.toLowerCase() == 'new';
    final isBuy = order.orderType?.toLowerCase() == 'buy';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: _buildTitle(
        name: order.stockName ?? 'Unknown Stock',
        amount: order.payout ?? '0',
        leftMidText: 'Quantity: ${order.volume}',
        rightMidText:
            'Price: TZS.${currencyFormat.format(double.tryParse(order.price ?? '0') ?? 0)}',
      ),
      subtitle: _buildSubtitle(
          statusLabel: friendly['label'] ?? '',
          statusColor: friendly['color'],
          typeLabel: isBuy ? 'buy' : 'sale',
          useMainColor: isBuy,
          date: parsedDate(order.date)),
      onTap: () {
        // if (isNew && order.orderType != 'sell') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => OrderPaymentDetailsPage(order: order),
        //     ),
        //   );
        // } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(order: order),
          ),
        );
        // }
      },
    );
  }

  static Widget _buildBondOrderCard(
      {required BuildContext context, required BondOrder order}) {
    final bool isBuyOrder = order.type.toLowerCase() == 'buy';

    final friendly = order.getFriendlyStatus();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: _buildTitle(
          name: order.security,
          amount: order.amount,
          leftMidText: '${order.marketType.capitalize()} Market',
          rightMidText:
              'Price: TZS.${currencyFormat.format(double.tryParse(order.price) ?? 0)}'),
      subtitle: _buildSubtitle(
          statusLabel: friendly['label'] ?? '',
          statusColor: friendly['color'],
          typeLabel: order.type,
          useMainColor: isBuyOrder,
          date: order.date),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BondOrderDetailsPage(order: order),
          ),
        );
      },
    );
  }

  static Widget _buildTitle({
    required String name,
    required String amount,
    required String leftMidText,
    required String rightMidText,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TZS.${NumberFormat('#,##0.00').format(double.tryParse(amount) ?? 0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                // color: AppColor().textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (leftMidText.isNotEmpty && rightMidText.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  leftMidText,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                rightMidText,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
      ],
    );
  }

  static Widget _buildSubtitle({
    required String statusLabel,
    required Color statusColor,
    required String typeLabel,
    required bool useMainColor,
    required DateTime date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColor().neutralTextMedium,
              ),
              Text(
                DateFormat(' HH:mm').format(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColor().neutralTextMedium,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      (useMainColor ? AppColor().blueBTN : AppColor().orangeApp)
                          .withAlpha(10),
                ),
                child: Text(
                  typeLabel.capitalize(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: useMainColor
                        ? AppColor().blueBTN
                        : AppColor().orangeApp,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Text(
            statusLabel.toUpperCase(),
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: statusColor),
          ),
        ],
      ),
    );
  }

  // New helper to convert color string to a Color object.
  static Color mapFriendlyColor(String? colorStr) {
    switch (colorStr) {
      case 'grey':
        return Colors.grey;
      case 'cyan':
        return Colors.cyan;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'lightblue':
        return Colors.lightBlue;
      case 'darkred':
        return Colors.red[900]!;
      case 'lightorange':
        return Colors.orangeAccent;
      default:
        return Colors.black;
    }
  }
}
