import 'package:flutter/material.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/widgets/order_list_widget.dart';
import 'package:iwealth/screens/fund/widgets/orders_filter_card_widget.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/models/order.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});
  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  bool _isLoading = true;
  final currencyFormat = NumberFormat("#,##0.00", "en_US");
  Map<String, List<Order>> groupedOrders = {};
  List<Order> allOrders = [];
  final ScrollController _scrollController = ScrollController();
  bool filterOpened = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final mp = Provider.of<MarketProvider>(context, listen: false);
      if (mp.order.isEmpty) {
        await StockWaiter().getOrders(mp);
      }
      // setState(() {

      allOrders = mp.order;
      _groupOrdersByDate(mp.order, groupedOrders);
      // });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _groupOrdersByDate(
      List<Order> orders, Map<String, List<Order>> groupedOrders) {
    groupedOrders.clear();
    for (var order in orders) {
      String formattedDate = DateFormat('dd MMM yyyy')
          .format(OrderListWidget.parsedDate(order.date));
      if (groupedOrders.containsKey(formattedDate)) {
        groupedOrders[formattedDate]!.add(order);
      } else {
        groupedOrders[formattedDate] = [order];
      }
    }

    groupedOrders.forEach((date, ordersList) {
      ordersList.sort((a, b) => OrderListWidget.parsedDate(b.date)
          .compareTo(OrderListWidget.parsedDate(a.date)));
    });
  }

  void toggleFilter() {
    setState(() {
      filterOpened = !filterOpened;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return _loadOrders();
      },
      child: OrderListWidget.buildStickyOrderList(
        context: context,
        groupedStockOrders: groupedOrders,
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
