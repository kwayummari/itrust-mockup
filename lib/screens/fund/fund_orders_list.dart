import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/widgets/order_list_widget.dart';
import 'package:iwealth/screens/fund/widgets/orders_filter_card_widget.dart';
import 'package:iwealth/screens/fund/widgets/show_datepicker.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FundOrdersListScreen extends StatefulWidget {
  final bool? resetCache;
  const FundOrdersListScreen({super.key, this.resetCache = false});

  @override
  State<FundOrdersListScreen> createState() => _FundOrdersListScreenState();
}

class _FundOrdersListScreenState extends State<FundOrdersListScreen> {
  List<IPOSubscription>? subscriptionOrders = [];
  Map<String, List<IPOSubscription>> groupedSubscriptions = {};
  bool _isLoading = false;
  bool _isCached = false; // Add caching state
  bool filterOpened = false;

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMore = true;

  int subscriptionPage = 1;
  bool isLoadingMoreSubscriptions = false;
  bool hasMoreSubscriptions = true;
  final ScrollController _subscriptionScrollController = ScrollController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  String? category;
  List categories = [
    {'value': 'buy', 'label': 'Subscription'},
    {'value': 'sale', 'label': 'Redemption'},
  ];
  String? status;
  List<String> statuses = [
    'pending',
    'submitted',
    'failed',
  ];

  List<IPOSubscription> allFetchedOrders = [];
  int totalPages = 1;
  int currentApiPage = 1;
  final bool _isInitialLoading = true; // Add this variable
  int totalApiPages = 1;

  List<IPOSubscription> orders = [];

  int itemsPerPage = 25;

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Will load once and then be kept alive
  }

  Future<void> _loadInitialData() async {
    print("=============cached data");
    if (_isCached) return; // Skip loading if data is already cached
    print("=============passed cached data");

    print("=============starting fetching");
    try {
      await _fetchAllOrders();
      setState(() {
        _isCached = true; // Mark data as cached
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading initial data: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop shimmer after loading
        });
      }
    }
  }

  Future<void> _fetchAllOrders() async {
    print("=============cached cached data");
    if (_isCached) return;
    print("=============passed cached data");
    final mp = Provider.of<MarketProvider>(context, listen: false);
    if (mp.fundOrders.isEmpty) {
      setState(() {
        _isLoading = true; // Show shimmer while loading
      });
    }
    print("=============mp $mp");
    final result = await StockWaiter().getCombinedFundOrders(
      fundCode: '',
      context: context,
      mp: mp,
      page: 1,
    );
    print("=============funds $result");

    setState(() {
      _isLoading = false; // Stop shimmer after loading
      subscriptionOrders = result['data'].toList();
      allFetchedOrders = result['data'].toList();
      _groupOrdersByDate(subscriptionOrders!, groupedSubscriptions);
    });
  }

  void _groupOrdersByDate(List<IPOSubscription> orders,
      Map<String, List<IPOSubscription>> groupedOrders) {
    groupedOrders.clear();
    for (var order in orders) {
      DateTime? parsedDate = DateTime.tryParse(order.date);
      String formattedDate = parsedDate != null
          ? DateFormat('dd MMM yyyy').format(parsedDate)
          : order.date;
      if (groupedOrders.containsKey(formattedDate)) {
        groupedOrders[formattedDate]!.add(order);
      } else {
        groupedOrders[formattedDate] = [order];
      }
    }

    // Sort the orders within each date group by date in descending order
    groupedOrders.forEach((date, ordersList) {
      ordersList.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
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
      onRefresh: () async {
        setState(() {
          // _isLoading = true;
          _isCached = false; // Reset cached state to fetch new data
        });
        await _fetchAllOrders();
        setState(() {
          _isLoading = false;
        });
      },
      child: OrderListWidget.buildStickyOrderList(
        context: context,
        groupedFundsOrders: groupedSubscriptions,
        isLoading: _isLoading,
        scrollController: _subscriptionScrollController,
        filterWidget: OrdersFilterCardWidget(
          filterOpened: filterOpened,
          orders: allFetchedOrders,
          onReset: toggleFilter,
          onApply: (filteredData) {
            setState(() {
              _groupOrdersByDate(filteredData, groupedSubscriptions);
              // toggleFilter();
            });
          },
        ),
        filterOpened: filterOpened,
        onFilterToggle: toggleFilter,
      ),
    );
  }
}
