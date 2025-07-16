import 'package:flutter/foundation.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/stocks/ui/portfolio.dart';
import 'package:iwealth/widgets/shimmer_loading.dart';

import 'package:flutter/material.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/widgets/app_bottom.dart';
import 'package:provider/provider.dart';

class StockOfficialScreen extends StatefulWidget {
  const StockOfficialScreen({super.key});

  @override
  State<StockOfficialScreen> createState() => _StockOfficialScreenState();
}

class _StockOfficialScreenState extends State<StockOfficialScreen> {
  // Add state variables for caching
  bool _isDataPreloaded = false;
  late Future<void> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = _preloadData();
  }

  Future<void> _preloadData() async {
    if (_isDataPreloaded) return;

    final marketProvider = Provider.of<MarketProvider>(context, listen: false);

    try {
      // Preload discover screen data
      await Future.wait<void>(<Future<void>>[
        StockWaiter().getStocks(mp: marketProvider, context: context),
        StockWaiter().stockPerformance(
            identity: "movers", provider: marketProvider, context: context),
        StockWaiter().stockPerformance(
            identity: "gainers", provider: marketProvider, context: context),
        StockWaiter().stockPerformance(
            identity: "losers", provider: marketProvider, context: context),
        StockWaiter().getMarketStatus(mp: marketProvider, context: context),
        StockWaiter().getIndex(marketProvider),
        StockWaiter().fundList(mp: marketProvider, context: context),
      ]);

      // Preload portfolio data
      if (marketProvider.eachStockPortfolio.isEmpty) {
        await StockWaiter().getOrders(marketProvider);
      }

      _isDataPreloaded = true;
    } catch (e) {
      if (kDebugMode) {
        print("Error preloading data: $e");
      }
    }
  }

  Widget _buildShimmerLayout() {
    return Column(
      children: [
        // Shimmer for tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Row(
            children: [
              ShimmerLoading(
                height: 32,
                width: 100,
                borderRadius: 16,
              ),
              SizedBox(width: 16),
              ShimmerLoading(
                height: 32,
                width: 100,
                borderRadius: 16,
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            elevation: 0,
            backgroundColor: AppColor().blueBTN,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomNavBarWidget(),
                  ),
                );
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                  labelStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  indicator: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 3.0,
                      ),
                    ),
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text("Discover"),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text("Portfolio"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: _dataLoadingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLayout(); // Replace CircularProgressIndicator with shimmer
            }

            return TabBarView(
              children: <Widget>[
                // DiscoverScreen(
                //   activeTab: "${marketProvider.currentScreen}",
                //   mp: marketProvider,
                //   isPreloaded: _isDataPreloaded,
                // ),
                Portfolio(
                  portfolio: marketProvider.eachStockPortfolio,
                  isPreloaded: _isDataPreloaded,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
