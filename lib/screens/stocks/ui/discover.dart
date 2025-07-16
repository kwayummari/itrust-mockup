import 'package:flutter/foundation.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/fund.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/services/waiter_service.dart';
import 'package:iwealth/stocks/screen/stockdetails.dart';
import 'package:iwealth/stocks/screen/stocksPAges/all_stock.dart';

import 'package:iwealth/stocks/services/pull_metadata.dart';
import 'package:iwealth/stocks/widgets/error_msg.dart';
import 'package:flutter/material.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:iwealth/widgets/shimmer_loading.dart';

class DiscoverScreen extends StatefulWidget {
  final String activeTab;
  final MarketProvider mp;
  final bool isPreloaded;

  const DiscoverScreen({
    super.key,
    required this.activeTab,
    required this.mp,
    this.isPreloaded = false,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  int index = 0;

  Color stockActiveColor = AppColor().inputFieldColor;
  Color fundColor = AppColor().blueBTN;
  bool rotate = false;
  bool fundrotate = false;
  bool stockrotate = false;
  bool _isLoading = false; // Track data loading status
  TabController? _tabController;

  bool _isStockDataLoaded = false;

  final ScrollController _scrollController = ScrollController();
  String _selectedInvestmentType = 'funds'; // NEW state variable

  void nidabtnPressed(provider) {
    Waiter().getSectors("bank", provider);
    Waiter().getSectors("sector", provider);
    Waiter().getSourceOfIncome("kin", provider);
    Waiter().getSourceOfIncome("source", provider);
  }

  void _handleError(
      String header, String message, MarketProvider mp, String screen) {
        AppSnackbar(
      isError: true,
      response: "Something went wrong, Please try again",
    ).show(context);
    setState(() {
      mp.currentScreen = screen;
      stockActiveColor =
          screen == "funds" ? AppColor().inputFieldColor : AppColor().blueBTN;
      fundColor = screen == "funds" ? AppColor().blueBTN : Colors.white;
      stockrotate = false;
      fundrotate = false;
      _isLoading = false;
    });
  }

  // Modify initiateStockScreen to check for cached data
  Future<void> initiateStockScreen(
      {required MarketProvider mp, bool forceRefresh = false}) async {
    if (_isLoading) return;

    // If data is already loaded and no force refresh, just switch view
    if (_isStockDataLoaded && !forceRefresh) {
      setState(() {
        mp.currentScreen = "stock";
        stockActiveColor = AppColor().blueBTN;
        fundColor = Colors.white;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      stockrotate = true;
      stockActiveColor = AppColor().blueBTN;
      fundColor = Colors.white;
    });

    try {
      // Load stock data if not already loaded
      if (!_isStockDataLoaded || forceRefresh) {
        var stockStatus =
            await StockWaiter().getStocks(mp: mp, context: context);
        if (stockStatus != "1") {
          _handleError(ErrorMsg().maintenanceHeader, ErrorMsg().maintainanceMsg,
              mp, "funds");
          return;
        }

        // Load other stock data in parallel
        List<Future<dynamic>> futures = [
          StockWaiter().stockPerformance(
              identity: "movers", provider: mp, context: context),
          StockWaiter().stockPerformance(
              identity: "gainers", provider: mp, context: context),
          StockWaiter().stockPerformance(
              identity: "losers", provider: mp, context: context),
          StockWaiter().getMarketStatus(mp: mp, context: context),
          StockWaiter().getIndex(mp),
        ];
        await Future.wait(futures);

        _isStockDataLoaded = true;
      }

      setState(() {
        mp.currentScreen = "stock";
        stockrotate = false;
        stockActiveColor = AppColor().blueBTN;
        fundColor = Colors.white;
      });
    } catch (e) {
      _handleError(ErrorMsg().maintenanceHeader, ErrorMsg().maintainanceMsg, mp,
          "funds");
      if (kDebugMode) {
        print("Error during stock data load: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> initiateFundScreen(MarketProvider mp) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      fundColor = AppColor().blueBTN;
      stockActiveColor = Colors.white;
      fundrotate = true;
    });

    try {
      // Load fund list without profile check
      if (mp.fund.isEmpty) {
        var fundStatus = await StockWaiter().fundList(mp: mp, context: context);
        if (fundStatus != "1") {
          _handleError(
              "Maintainance", "Something went wrong: $fundStatus", mp, "funds");
          return;
        }
      }

      // Defer state update to the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            mp.currentScreen = "funds";
            fundrotate = false;
          });
        }
      });
    } catch (e) {
      _handleError("Maintainance", "Something went wrong: $e", mp, "funds");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.mp.currentScreen == "funds") {
        await initiateFundScreen(widget.mp);
      } else {
        await initiateStockScreen(mp: widget.mp);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
// Set initial tab

    // Remove direct provider state modification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mp = Provider.of<MarketProvider>(context, listen: false);
      mp.currentScreen = "funds";
    });

    // Initialize colors
    fundColor = AppColor().blueBTN;
    stockActiveColor = Colors.grey.shade200;

    if (!widget.isPreloaded) {
      _preloadFundsOnly();
    }
    _selectedInvestmentType = widget.activeTab; // or default 'funds'
  }

  // Modify to only load funds data
  Future<void> _preloadFundsOnly() async {
    try {
      if (!mounted) return;

      final mp = Provider.of<MarketProvider>(context, listen: false);
      await initiateFundScreen(mp);

      if (mounted) {
        setState(() {
          fundColor = AppColor().blueBTN;
          stockActiveColor = Colors.grey.shade200;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error preloading data: $e");
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Widget _buildShimmerLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for KYC Card
          const Padding(
            padding: EdgeInsets.all(16),
            child: ShimmerLoading(
              height: 140,
              width: double.infinity,
              borderRadius: 20,
            ),
          ),

          // Shimmer for Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  height: 24,
                  width: 150,
                  borderRadius: 4,
                ),
                SizedBox(height: 8),
                ShimmerLoading(
                  height: 16,
                  width: 200,
                  borderRadius: 4,
                ),
              ],
            ),
          ),

          // Shimmer for Investment Options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  const Expanded(
                    child: ShimmerLoading(
                      height: 120,
                      width: double.infinity,
                      borderRadius: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Shimmer for Fund Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                3,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: ShimmerLoading(
                    height: 160,
                    width: double.infinity,
                    borderRadius: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentSection(
      MarketProvider marketProvider, double appHeights, double appWidths) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Take Your Pick",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Explore from our range of offerings",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  'Funds',
                  false,
                  _selectedInvestmentType == 'funds'
                      ? AppColor().blueBTN
                      : Colors.grey.shade200,
                  () {
                    setState(() {
                      _selectedInvestmentType = 'funds';
                    });
                    // Load mutual funds data as before
                    initiateFundScreen(marketProvider);
                  },
                  false, // pass loader flag if needed
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionButton(
                  'Stocks',
                  false,
                  _selectedInvestmentType == 'stocks'
                      ? AppColor().blueBTN
                      : Colors.grey.shade200,
                  () {
                    setState(() {
                      _selectedInvestmentType = 'stocks';
                    });
                    // Load stocks data when stocks is selected
                    initiateStockScreen(mp: marketProvider);
                  },
                  false, // pass loader flag if needed
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionButton(
                  'Bonds',
                  true,
                  Colors.grey.shade200,
                  null,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget creativeStocksScreen(MarketProvider mp) {
    if (mp.stock == null || mp.stock!.isEmpty) {
      return Center(
        child: Text(
          "No stocks available",
          style: TextStyle(color: AppColor().textColor),
        ),
      );
    }
    // Show only first 5 stocks in a horizontal slider
    final stocksToShow = mp.stock!.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200, // fixed height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stocksToShow.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final stock = stocksToShow[index];
              final bool isPositiveChange =
                  double.tryParse(stock.changePercentage ?? '0')?.isNegative ==
                      false;
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockDetailScreen(
                            companyName: stock.fullname,
                            logo: "assets/images/tickerLogo/${stock.name}.jpg",
                            tickerSymbol: stock.name,
                            change: stock.changePercentage,
                            price: stock.price,
                            changeAmount: stock.changeAmount,
                            stockID: stock.stockID,
                            highPrice: stock.highPrice,
                            lowPrice: stock.lowPrice,
                            mcap: stock.marketCap,
                            highOrNAVLabel: "High Price",
                            lowOrInitLabel: "Low Price",
                            volOrLaunchLabel: "Volume",
                            screen: "stock",
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            stock.name ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "TZS ${stock.price}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${isPositiveChange ? '+' : ''}${stock.changePercentage}%",
                            style: TextStyle(
                              color:
                                  isPositiveChange ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // "View All" button aligned to the end
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllStockScreen(),
                    ),
                  );
                },
                child: Text(
                  "View All Stocks",
                  style: TextStyle(
                    color: AppColor().blueBTN,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // NEW: Build Stocks Discovery Section for Stocks tab
  Widget _buildStocksDiscoverySection(MarketProvider mp) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market Status Card with Live Animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mp.market?.toLowerCase() == "open"
                          ? Colors.green.withOpacity(0.8)
                          : Colors.orange.withOpacity(0.8),
                      AppColor().blueBTN,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (mp.market?.toLowerCase() == "open")
                          TweenAnimationBuilder(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        Icon(
                          mp.market?.toLowerCase() == "open"
                              ? Icons.wb_sunny
                              : Icons.nightlight_round,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DSE Market Status",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: mp.market?.toLowerCase() == "open"
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                mp.market?.toUpperCase() ?? "UNKNOWN",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (mp.market?.toLowerCase() == "open")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "LIVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Market Performance Sections
          _buildMarketSection(
            "Top Movers",
            mp.marketMovers ?? [],
            Colors.blue,
          ),
          _buildMarketSection(
            "Top Gainers",
            mp.marketGainers ?? [],
            Colors.green,
          ),
          _buildMarketSection(
            "Top Losers",
            mp.marketLoosers ?? [],
            Colors.red,
          ),

          // Market Insights Card
          if (mp.marketIndex.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Market Indices",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...mp.marketIndex.map((index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        index.code ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        index.description ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      index.closePrice ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${index.change}%",
                                      style: TextStyle(
                                        color:
                                            double.tryParse(index.change ?? '0')
                                                        ?.isNegative ??
                                                    false
                                                ? Colors.red
                                                : Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarketSection(String title, List<dynamic> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                title.contains("Gainers")
                    ? Icons.trending_up
                    : title.contains("Losers")
                        ? Icons.trending_down
                        : Icons.show_chart,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100, // Reduced height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final change = double.tryParse(item.change ?? '0') ?? 0;
              final isPositive = change >= 0;

              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigation code remains the same
                      final stockData =
                          Provider.of<MarketProvider>(context, listen: false)
                              .stock
                              ?.firstWhere(
                                (stock) =>
                                    stock.name?.toLowerCase() ==
                                    item.name?.toLowerCase(),
                              );

                      if (stockData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockDetailScreen(
                              companyName: stockData.fullname ?? '',
                              logo:
                                  "assets/images/tickerLogo/${stockData.name}.jpg",
                              tickerSymbol: stockData.name ?? '',
                              change: stockData.changePercentage,
                              price: stockData.price,
                              changeAmount: stockData.changeAmount,
                              stockID: stockData.stockID,
                              highPrice: stockData.highPrice,
                              lowPrice: stockData.lowPrice,
                              mcap: stockData.marketCap,
                              highOrNAVLabel: "High Price",
                              lowOrInitLabel: "Low Price",
                              volOrLaunchLabel: "Volume",
                              screen: "stock",
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top row with name and arrow icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                isPositive
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isPositive ? Colors.green : Colors.red,
                                size: 16,
                              ),
                            ],
                          ),

                          // Bottom row with price and change
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Price column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Price",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "TZS ${item.close}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // Change percentage
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isPositive ? Colors.green : Colors.red)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${isPositive ? '+' : ''}${item.change}%",
                                      style: TextStyle(
                                        color: isPositive
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appHeight = MediaQuery.of(context).size.height;
    final appWidth = MediaQuery.of(context).size.width;
    final marketProvider = Provider.of<MarketProvider>(context);
    final metadataProvider = Provider.of<MetadataProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Main scrolling content
          Positioned.fill(
            top:
                marketProvider.stock != null && marketProvider.stock!.isNotEmpty
                    ? 40
                    : 0, // Add space for ticker
            child: _isLoading
                ? _buildShimmerLayout()
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColor().blueBTN,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KYC Status Section
                          if (SessionPref.getUserProfile()![6] == "pending")
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor().blueBTN,
                                    AppColor().blueBTN.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor().blueBTN.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/profile.gif",
                                        height: 40,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Complete Your Profile",
                                              style: TextStyle(
                                                color: AppColor().constant,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Complete your KYC to start investing",
                                              style: TextStyle(
                                                color: AppColor()
                                                    .constant
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: MaterialButton(
                                      onPressed: () {
                                        setState(() => rotate = true);
                                        setState(() async {
                                          rotate = await PullMetadata()
                                              .nidabtnPressed(
                                                  metadataProvider, context);
                                        });
                                      },
                                      height: 40.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      color: AppColor().selected,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Complete Profile",
                                            style: TextStyle(
                                              color: AppColor().constant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (rotate) ...[
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                color: AppColor().constant,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (SessionPref.getUserProfile()![6] ==
                                  "submitted" ||
                              SessionPref.getUserProfile()![7] == "pending")
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor().orangeApp,
                                    AppColor().orangeApp.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColor().orangeApp.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.pending_actions,
                                        color: AppColor().constant,
                                        size: 40,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "KYC Under Review",
                                              style: TextStyle(
                                                color: AppColor().constant,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "We're reviewing your KYC form. Please wait for verification.",
                                              style: TextStyle(
                                                color: AppColor()
                                                    .constant
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColor().constant.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: AppColor().constant,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Verification in progress",
                                          style: TextStyle(
                                            color: AppColor().constant,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Investment Options Section
                          _buildInvestmentSection(
                              marketProvider, appHeight * 0.2, appWidth),

                          // Conditionally display Mutual Funds or Stocks view:
                          _selectedInvestmentType == 'funds'
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: fundScreen(
                                    appHeight: appHeight,
                                    appWidth: appWidth,
                                    marketProvider: marketProvider,
                                    context: context,
                                  ),
                                )
                              : _buildStocksDiscoverySection(marketProvider),
                        ],
                      ),
                    ),
                  ),
          ),

          // Fixed position ticker strip
          if (marketProvider.stock != null && marketProvider.stock!.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StockTickerStrip(
                stocks: marketProvider.stock!,
                marketProvider: marketProvider,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    String label,
    bool isDisabled,
    Color color,
    VoidCallback? onPressed,
    bool showLoader,
  ) {
    return Expanded(
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: color == AppColor().blueBTN ? color : Colors.white,
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : color == AppColor().blueBTN
                          ? Colors.transparent
                          : AppColor().blueBTN.withOpacity(0.3),
                  width: 1.5,
                ),
                gradient: !isDisabled && color == AppColor().blueBTN
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.8),
                        ],
                      )
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isDisabled
                            ? Colors.grey
                            : color == AppColor().blueBTN
                                ? Colors.white
                                : AppColor().blueBTN,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (showLoader) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: color == AppColor().blueBTN
                              ? Colors.white
                              : AppColor().blueBTN,
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add this new widget class just before the _DiscoverScreenState class
class StockTickerStrip extends StatefulWidget {
  final List<dynamic> stocks;
  final MarketProvider marketProvider;

  const StockTickerStrip({
    super.key,
    required this.stocks,
    required this.marketProvider,
  });

  @override
  State<StockTickerStrip> createState() => _StockTickerStripState();
}

class _StockTickerStripState extends State<StockTickerStrip>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _scrollOffset = 0;
  final double _scrollSpeed = 1.0; // Reduced speed for better readability
  final int _multiplier = 3;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50), // Smoother animation updates
    )..repeat();

    // Add delayed start for better UX
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _animationController.addListener(_updateScroll);
      }
    });
  }

  void _updateScroll() {
    _scrollOffset += _scrollSpeed * _animationController.value;

    if (_scrollController.hasClients) {
      if (_scrollOffset >= _scrollController.position.maxScrollExtent) {
        _scrollOffset = 0; // Reset position smoothly
      }
      _scrollController.jumpTo(_scrollOffset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColor().blueBTN.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(
            _multiplier,
            (index) => Row(
              children: widget.stocks.map((stock) {
                final bool isPositive =
                    double.tryParse(stock.changePercentage ?? '0')
                            ?.isNegative ==
                        false;
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailScreen(
                          companyName: stock.fullname,
                          logo: "assets/images/tickerLogo/${stock.name}.jpg",
                          tickerSymbol: stock.name,
                          change: stock.changePercentage,
                          price: stock.price,
                          changeAmount: stock.changeAmount,
                          stockID: stock.stockID,
                          highPrice: stock.highPrice,
                          lowPrice: stock.lowPrice,
                          mcap: stock.marketCap,
                          highOrNAVLabel: "High Price",
                          lowOrInitLabel: "Low Price",
                          volOrLaunchLabel: "Volume",
                          screen: "stock",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          stock.name ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColor().textColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPositive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${isPositive ? '+' : ''}${stock.changePercentage}%",
                            style: TextStyle(
                              color: isPositive ? Colors.green : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 16,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
