import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/models/fund/fund_model.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/stocks/models/bond_model.dart';
import 'package:iwealth/stocks/models/stock.model.dart';
import 'package:iwealth/stocks/screen/stocksPAges/all_bonds.dart';
import 'package:iwealth/stocks/screen/stocksPAges/all_stock.dart';
import 'package:iwealth/widgets/tabbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/widgets/fund_card.dart';
import 'package:advanced_search/advanced_search.dart';

class AllFundsScreen extends StatefulWidget {
  final int initialTabIndex;
  const AllFundsScreen({super.key, this.initialTabIndex = 0});

  @override
  _AllFundsScreenState createState() => _AllFundsScreenState();
}

class _AllFundsScreenState extends State<AllFundsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  String searchQuery = "";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  void _updateScrollProgress() {
    if (_scrollController.position.maxScrollExtent > 0) {
      setState(() {
        _scrollProgress = _scrollController.position.pixels /
            _scrollController.position.maxScrollExtent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    final marketProvider = Provider.of<MarketProvider>(context);

    final combinedItems = [
      ...marketProvider.fund.map((fund) => {'type': 'Fund', 'item': fund}),
      ...?marketProvider.stock
          ?.map((stock) => {'type': 'Stock', 'item': stock}),
      ...marketProvider.bonds.map((bond) => {'type': 'Bond', 'item': bond}),
    ];

    final searchLower = searchQuery.toLowerCase();
    final filteredItems = combinedItems.where((entry) {
      final name = entry['type'] == 'Fund'
          ? (entry['item'] as FundModel).name.toLowerCase()
          : entry['type'] == 'Stock'
              ? (entry['item'] as Stock).name?.toLowerCase() ?? ''
              : entry['type'] == 'Bond'
                  ? (entry['item'] as Bond).securityName?.toLowerCase() ?? ''
                  : '';
      if (searchLower.isEmpty) return true;
      return name.contains(searchLower);
    }).toList();

    if (searchQuery.isNotEmpty && filteredItems.isNotEmpty) {
      final firstItemType = filteredItems.first['type'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (firstItemType == 'Fund') {
          _tabController.animateTo(0);
        } else if (firstItemType == 'Stock') {
          _tabController.animateTo(1);
        } else if (firstItemType == 'Bond') {
          _tabController.animateTo(2);
        }
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            _buildAppBar(marketProvider, combinedItems),
            TabBarWidget(
              context: context,
              tabs: const ['funds', 'stocks', 'bonds'],
              tabController: _tabController,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const AllStockScreen(),
                  const AllBondScreen(),
                  _buildFundsList(
                    filteredItems
                        .where((entry) => entry['type'] == 'Fund')
                        .toList(),
                    appWidth,
                    marketProvider,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundsList(List<dynamic> filteredFunds, double appWidth,
      MarketProvider marketProvider) {
    if (filteredFunds.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filteredFunds.length,
      itemBuilder: (context, i) {
        final fund = filteredFunds[i]['item'] as FundModel;
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: fundCard(
            cardColor: AppColor().cardColor,
            fund: fund,
            appWidth: appWidth,
            context: context,
            tagColor: const Color.fromARGB(255, 133, 177, 213),
            tagShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            tagText: 'Medium Volatility',
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
      MarketProvider marketProvider, List<dynamic> combinedItems) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Explore',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AdvancedSearch(
                  searchItems: combinedItems.map((entry) {
                    if (entry['type'] == 'Fund') {
                      return (entry['item'] as FundModel).name ?? '';
                    } else if (entry['type'] == 'Stock') {
                      return (entry['item'] as Stock).name ?? '';
                    } else if (entry['type'] == 'Bond') {
                      return (entry['item'] as Bond).securityName ?? '';
                    }
                    return '';
                  }).toList(),
                  maxElementsToDisplay: 10,
                  singleItemHeight: 50,
                  minLettersForSearch: 1,
                  fontSize: 16,
                  borderRadius: 30.0,
                  hintText: 'Search for Funds, Stocks, or Bonds',
                  cursorColor: Colors.black,
                  focusedBorderColor: Colors.transparent,
                  enabledBorderColor: Colors.transparent,
                  inputTextFieldBgColor: Colors.transparent,
                  clearSearchEnabled: true,
                  searchMode: SearchMode.CONTAINS,
                  showListOfResults: true,
                  unSelectedTextColor: Colors.black,
                  searchResultsBgColor: Colors.transparent,
                  hintTextColor: Colors.grey,
                  onItemTap: (index, value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  onSearchClear: () {
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  onEditingProgress: (searchText, listOfResults) {
                    setState(() {
                      searchQuery = searchText;
                    });
                  },
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 1,
              child: LinearProgressIndicator(
                value: _scrollProgress,
                backgroundColor: Colors.transparent,
                color: AppColor().blueBTN,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor().constant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 64, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(
            'No items found for "$searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() => searchQuery = '');
            },
            child: Text(
              'Clear Search',
              style: TextStyle(color: AppColor().constant),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
