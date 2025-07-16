import 'package:flutter/material.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/widgets/order_list_widget.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/models/bond_orders_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../screens/fund/widgets/orders_filter_card_widget.dart';

class BondOrderListPage extends StatefulWidget {
  const BondOrderListPage({super.key});
  @override
  State<BondOrderListPage> createState() => _BondOrderListPageState();
}

class _BondOrderListPageState extends State<BondOrderListPage> {
  bool _isLoading = true;
  final currencyFormat = NumberFormat("#,##0.00", "en_US");
  Map<String, List<BondOrder>> groupedOrders = {};
  List<BondOrder> allOrders = [];
  final ScrollController _scrollController = ScrollController();
  bool filterOpened = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool hideloading = false}) async {
    setState(() => _isLoading = !hideloading);

    try {
      final mp = Provider.of<MarketProvider>(context, listen: false);
      if (mp.bondOrders.isEmpty) {
        await StockWaiter().getBondOrders(mp: mp, context: context);
      }
      // setState(() {
      allOrders = mp.bondOrders;
      _groupOrdersByDate(mp.bondOrders, groupedOrders);
      // });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void toggleFilter() {
    setState(() {
      filterOpened = !filterOpened;
    });
  }

  void _groupOrdersByDate(
      List<BondOrder> orders, Map<String, List<BondOrder>> groupedOrders) {
    groupedOrders.clear();
    for (var order in orders) {
      String formattedDate = DateFormat('dd MMM yyyy').format(order.date);
      if (groupedOrders.containsKey(formattedDate)) {
        groupedOrders[formattedDate]!.add(order);
      } else {
        groupedOrders[formattedDate] = [order];
      }
    }

    // Sort the orders within each date group by date in descending order
    groupedOrders.forEach((date, ordersList) {
      ordersList.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadOrders(hideloading: true),
      child: OrderListWidget.buildStickyOrderList(
        context: context,
        groupedBondsOrders: groupedOrders,
        isLoading: _isLoading,
        scrollController: _scrollController,
        filterWidget: OrdersFilterCardWidget(
          filterOpened: filterOpened,
          orders: allOrders,
          onReset: toggleFilter,
          onApply: (filteredData) {
            setState(() {
              _groupOrdersByDate(filteredData, groupedOrders);
              // toggleFilter();
            });
          },
        ),
        filterOpened: filterOpened,
        onFilterToggle: toggleFilter,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
