import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/fund/fund_orders_list.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/screen/bond_orders_list.dart';
import 'package:iwealth/widgets/tabbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/providers/market.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/stocks/screen/stock_order_list.dart';

class OrdersListPage extends StatefulWidget {
  final bool? resetCache;
  const OrdersListPage({super.key, this.resetCache = false});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _fundOrders = [];
  List<dynamic> _subscriptions = [];
  bool _isLoading = true;
  final bool _isSubscriptionsView = true;

  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // _fetchOrders(); // Fetch both fund and stock orders
  }

  Future<void> _fetchOrders() async {
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);
    try {
      // Fetch fund orders
      var fundResponse = await StockWaiter().getFundOrderDetails(
        fundCode: '',
        mp: marketProvider,
        context: context,
      );
      if (fundResponse['status'] == 'success' && fundResponse['data'] != null) {
        setState(() {
          _fundOrders = fundResponse['data'];
          _subscriptions = _fundOrders
              .where((order) => order['transactionType'].toLowerCase() == 'buy')
              .toList();
        });
      } else {
        setState(() {
          _fundOrders = [];
          _subscriptions = [];
        });
      }

      // Fetch stock orders
      if (marketProvider.order.isEmpty) {
        await StockWaiter().getOrders(marketProvider);
      }
      setState(() {});

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fundOrders = [];
        _subscriptions = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBarWidget(
              context: context,
              tabs: const ['fund', 'stock', 'bond'],
              tabController: _tabController),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            FundOrdersListScreen(resetCache: widget.resetCache),
            const OrderListPage(),
            const BondOrderListPage(),
          ],
        ),
      ),
    );
  }
}
