// import 'package:flutter/foundation.dart';
// import 'package:iwealth/User/providers/metadata.dart';
// import 'package:iwealth/constants/app_color.dart';
// import 'package:iwealth/providers/market.dart';
// import 'package:iwealth/screens/fund/all_funds.dart';
// import 'package:iwealth/screens/fund/fund_orders_list.dart';
// import 'package:iwealth/screens/home/home_screen_status_banner.dart';
// import 'package:iwealth/screens/user/biometric_verification_screen.dart';
// import 'package:iwealth/services/session/app_session.dart';
// import 'package:iwealth/services/stocks/apis_request.dart';
// import 'package:iwealth/stocks/models/bond_holdings_model.dart';
// import 'package:iwealth/stocks/models/bond_portfolio_model.dart';
// import 'package:iwealth/stocks/models/portfolio.dart';
// import 'package:iwealth/stocks/screen/stock_order_list.dart';
// import 'package:iwealth/stocks/services/pull_metadata.dart';
// import 'package:iwealth/stocks/widgets/portfcard.dart';
// import 'package:iwealth/utility/number_fomatter.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class Portfolio extends StatefulWidget {
//   List<PortfolioModel> portfolio;
//   final bool isPreloaded;

//   Portfolio({
//     super.key,
//     required this.portfolio,
//     this.isPreloaded = false,
//   });

//   @override
//   State<Portfolio> createState() => _PortfolioState();
// }

// class _PortfolioState extends State<Portfolio> with TickerProviderStateMixin {
//   final currFormat = NumberFormat("#,##0.00", "en_US");
//   String activeTab = "stock";
//   Color stockActiveColor = AppColor().blueBTN;
//   Color fundColor = Colors.transparent;
//   bool _isRefreshDebounced = false;
//   bool rotate = false;
//   bool _showShimmer = true;
//   final tabs = ["all", "funds", "stocks", "bonds"];

//   List<PortfolioModel> _currentPortfolio = [];
//   List<PortfolioModel> _currentStocks = [];

//   late AnimationController _statusBannerController;
//   late Animation<double> _statusBannerAnimation;
//   bool _isStatusBannerVisible = false;

//   late TabController _tabController;

//   String safeFormat(dynamic value) {
//     if (value == null) return "0.00";
//     try {
//       if (value is String) {
//         value = double.tryParse(value) ?? 0.0;
//       }
//       return currFormat.format(value);
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error formatting value: $e");
//       }
//       return "0.00";
//     }
//   }

//   String safeCurrencyFormat(dynamic value) {
//     if (value == null) return "0.00";
//     try {
//       if (value is String) {
//         value = double.tryParse(value) ?? 0.0;
//       }
//       return currencyFormat(value);
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error formatting currency: $e");
//       }
//       return "0.00";
//     }
//   }

//   Future<void> onManualRefresh() async {
//     if (_isRefreshDebounced) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please wait before refreshing again.'),
//           duration: Duration(seconds: 1),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isRefreshDebounced = true;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Refreshing portfolio data...'),
//         duration: Duration(seconds: 1),
//       ),
//     );

//     await _loadAllInitialData();

//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           _isRefreshDebounced = false;
//         });
//       }
//     });
//   }

//   final ScrollController _scrollController = ScrollController();
//   final PageController _pageController = PageController(viewportFraction: 0.9);
//   int _currentPage = 0;

//   @override
//   void dispose() {
//     _statusBannerController.dispose();
//     _pageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: tabs.length, vsync: this);

//     activeTab = "all";
//     stockActiveColor = Colors.grey.shade200;
//     fundColor = Colors.transparent;

//     _currentPortfolio = [];
//     _currentStocks = [];

//     _statusBannerController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _statusBannerAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _statusBannerController,
//       curve: Curves.easeInOut,
//     ));

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final marketProvider =
//           Provider.of<MarketProvider>(context, listen: false);
//       setState(() {
//         _currentPortfolio = marketProvider.eachFundPortfolio;
//         _currentStocks = marketProvider.eachStockPortfolio;
//       });

//       if (!widget.isPreloaded) {
//         _loadAllInitialData();
//       }

//       _checkAndShowStatusBanner();
//     });

//     _pageController.addListener(() {
//       int next = _pageController.page!.round();
//       if (_currentPage != next) {
//         setState(() {
//           _currentPage = next;
//         });
//       }
//     });

//     Future.delayed(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           _showShimmer = false;
//         });
//       }
//     });
//   }

//   void _checkAndShowStatusBanner() {
//     StatusBannerHelper.checkAndShowStatusBanner(
//       context: context,
//       mounted: mounted,
//       showStatusBanner: _showStatusBanner,
//       hideStatusBanner: _hideStatusBanner,
//       updated: '',
//     );
//   }

//   void _showStatusBanner() {
//     StatusBannerHelper.showStatusBanner(
//       mounted: mounted,
//       isStatusBannerVisible: _isStatusBannerVisible,
//       setState: setState,
//       statusBannerController: _statusBannerController,
//       setStatusBannerVisible: (visible) => _isStatusBannerVisible = visible,
//     );
//   }

//   void _hideStatusBanner() {
//     StatusBannerHelper.hideStatusBanner(
//       mounted: mounted,
//       isStatusBannerVisible: _isStatusBannerVisible,
//       statusBannerController: _statusBannerController,
//       setState: setState,
//       setStatusBannerVisible: (visible) => _isStatusBannerVisible = visible,
//     );
//   }

//   Future<void> _loadAllInitialData() async {
//     if (!mounted) return;

//     final marketProvider = Provider.of<MarketProvider>(context, listen: false);

//     setState(() {});

//     try {
//       await Future.wait([
//         _loadInitialPortfolioData(),
//         _loadInitialStocksData(),
//         _loadSubscriptionData(marketProvider),
//         _loadCombinedPortfolioData(marketProvider),
//       ]);
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error loading initial data: $e");
//       }
//     } finally {
//       if (mounted) {
//         setState(() {});
//       }
//     }
//   }

//   Future<void> _loadCombinedPortfolioData(MarketProvider marketProvider) async {
//     try {
//       var combinedPortfolio = await StockWaiter().getCombinedPortfolio(
//         mp: marketProvider,
//         context: context,
//       );

//       if (mounted && combinedPortfolio.isNotEmpty) {
//         setState(() {
//           marketProvider.combinedPortfolio = PortfolioModel(
//             investedValue: combinedPortfolio['investedValue'],
//             currentValue: combinedPortfolio['currentValue'],
//             wallet: combinedPortfolio['wallet'],
//             profitLoss: combinedPortfolio['profitLoss'],
//             profitLossPercentage: '',
//           );
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error loading combined portfolio data: $e");
//       }
//     }
//   }

//   Future<void> _loadSubscriptionData(MarketProvider marketProvider) async {
//     try {
//       var response = await StockWaiter().getFundOrderDetails(
//         fundCode: '',
//         mp: marketProvider,
//         context: context,
//       );

//       if (mounted && response['status'] == 'success') {
//         setState(() {});
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error loading subscription data: $e");
//       }
//     }
//   }

//   Future<void> _loadInitialPortfolioData() async {
//     if (!mounted) return;

//     final marketProvider = Provider.of<MarketProvider>(context, listen: false);

//     var userProfile = SessionPref.getUserProfile();
//     if (userProfile == null || userProfile.length < 6) {
//       if (mounted) {
//         setState(() {
//           _currentPortfolio = [];
//         });
//       }
//       return;
//     }

//     if (userProfile[6] == "pending") {
//       if (mounted) {
//         setState(() {
//           _currentPortfolio = [];
//         });
//       }
//       return;
//     }

//     try {
//       if (marketProvider.eachFundPortfolio.isEmpty) {
//         await StockWaiter().fundPortfolio(context: context, mp: marketProvider);
//       }

//       if (mounted) {
//         setState(() {
//           _currentPortfolio = marketProvider.eachFundPortfolio;
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error loading initial portfolio data: $e");
//       }
//     }
//   }

//   Future<void> _loadInitialStocksData() async {
//     if (!mounted) return;

//     final marketProvider = Provider.of<MarketProvider>(context, listen: false);

//     var userProfile = SessionPref.getUserProfile();
//     if (userProfile == null || userProfile.length < 6) {
//       if (mounted) {
//         setState(() {
//           _currentStocks = [];
//         });
//       }
//       return;
//     }

//     if (userProfile[6] == "pending") {
//       if (mounted) {
//         setState(() {
//           _currentStocks = [];
//         });
//       }
//       return;
//     }

//     try {
//       if (marketProvider.eachStockPortfolio.isEmpty) {
//         await StockWaiter().getStocks(context: context, mp: marketProvider);
//       }

//       if (mounted) {
//         setState(() {
//           _currentStocks = marketProvider.eachStockPortfolio;
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error loading initial stocks data: $e");
//       }
//     }
//   }

//   void goToOrders({required MarketProvider marketProvider}) async {
//     if (SessionPref.getUserProfile()![6] == "pending") {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Complete your profile to start investing.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     } else if (SessionPref.getUserProfile()![6] == "submitted" ||
//         SessionPref.getUserProfile()![7] == "pending") {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Your KYC is under review. Please wait.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//     if (activeTab == "stock") {
//       if (marketProvider.order.isEmpty) {
//         var orderStatus = await StockWaiter().getOrders(marketProvider);
//         if (orderStatus == "1") {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (context) => const OrderListPage()));
//         }
//       } else {
//         Navigator.push(context,
//             MaterialPageRoute(builder: (context) => const OrderListPage()));
//       }
//     } else {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => FundOrdersListScreen()));
//     }
//   }

//   void _debugPrintFundPortfolio(MarketProvider provider) {
//     if (kDebugMode) {
//       print("\n=== DEBUG: FUND PORTFOLIO ===");

//       print("Total Funds in Portfolio: ${provider.eachFundPortfolio.length}");
//       for (var fund in provider.eachFundPortfolio) {
//         if (kDebugMode) {
//           print("""
//           Fund Details:
//           - Name: ${fund.stockName}
//           - Quantity: ${fund.qnty} (Type: ${fund.qnty.runtimeType})
//           - Invested Value: ${fund.investedValue} (Type: ${fund.investedValue.runtimeType})
//           - Current Value: ${fund.currentValue}
//           - Profit/Loss: ${fund.profitLoss}
//           - P/L %: ${fund.profitLossPercentage}
//           """);
//         }
//       }
//     }
//   }

//   Widget buildAllButton() {
//     final isSelected = activeTab == "all";
//     return MaterialButton(
//       onPressed: () {
//         setState(() {
//           activeTab = "all";
//         });
//       },
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(
//           color: isSelected
//               ? const Color(0xff1A82CF)
//               : const Color.fromARGB(248, 218, 216, 216),
//           width: 2,
//         ),
//       ),
//       color:
//           isSelected ? const Color.fromARGB(255, 172, 220, 244) : Colors.white,
//       child: const Text(
//         "All",
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   MaterialButton buildFundsButton(MarketProvider marketProvider) {
//     final isSelected = activeTab == "funds";
//     return MaterialButton(
//       onPressed: () {
//         setState(() {
//           activeTab = "funds";
//         });
//       },
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(
//           color: isSelected
//               ? const Color(0xff1A82CF)
//               : const Color.fromARGB(248, 218, 216, 216),
//           width: 2,
//         ),
//       ),
//       color:
//           isSelected ? const Color.fromARGB(255, 172, 220, 244) : Colors.white,
//       child: const Text(
//         "Funds",
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget buildStockButton(MarketProvider marketProvider) {
//     final isSelected = activeTab == "stock";
//     return MaterialButton(
//       onPressed: () {
//         setState(() {
//           activeTab = "stock";
//         });
//       },
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(
//           color: isSelected
//               ? const Color(0xff1A82CF)
//               : const Color.fromARGB(248, 218, 216, 216),
//           width: 2,
//         ),
//       ),
//       color:
//           isSelected ? const Color.fromARGB(255, 172, 220, 244) : Colors.white,
//       child: const Text(
//         "Stocks",
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget buildBondsButton(MarketProvider marketProvider) {
//     final isSelected = activeTab == "bonds";
//     return MaterialButton(
//       onPressed: () {
//         setState(() {
//           activeTab = "bonds";
//           _debugPrintFundPortfolio(marketProvider);
//         });
//       },
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(
//           color: isSelected
//               ? const Color(0xff1A82CF)
//               : const Color.fromARGB(248, 218, 216, 216),
//           width: 2,
//         ),
//       ),
//       color:
//           isSelected ? const Color.fromARGB(255, 172, 220, 244) : Colors.white,
//       disabledColor: Colors.white,
//       child: const Text(
//         "Bonds",
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget _buildNewTabBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColor().lowerBg,
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: TabBar(
//         controller: _tabController,
//         indicatorColor: AppColor().orangeApp,
//         dividerColor: Colors.transparent,
//         labelColor: AppColor().orangeApp,
//         overlayColor: WidgetStateProperty.all<Color>(
//           Colors.transparent,
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//         indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//         indicator: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: AppColor().orangeApp,
//               width: 1.0,
//             ),
//           ),
//         ),
//         tabs: tabs
//             .map(
//               (item) => Tab(text: item.capitalize()),
//             )
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Expanded(
//             child: Center(child: buildAllButton()),
//           ),
//           Expanded(
//             child: Center(
//                 child: buildFundsButton(Provider.of<MarketProvider>(context))),
//           ),
//           Expanded(
//               child: Center(
//                   child:
//                       buildStockButton(Provider.of<MarketProvider>(context)))),
//           Expanded(
//             child: Center(
//                 child: buildBondsButton(Provider.of<MarketProvider>(context))),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPortfolioList(MarketProvider marketProvider) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF5F7FA),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         //switched from rawscrollbar to sizedBox //just for now
//         child: SizedBox(
//           // radius: const Radius.circular(20),
//           // thickness: 6,
//           // thumbColor: AppColor().blueBTN.withOpacity(0.3),
//           // padding: const EdgeInsets.only(right: 2),
//           // thumbVisibility: true,
//           // controller: _scrollController,
//           child: activeTab == "all"
//               ? _buildAllPortfolioList(marketProvider)
//               : activeTab == "funds"
//                   ? _buildFundsPortfolioList(marketProvider)
//                   : activeTab == "stock"
//                       ? _buildStocksPortfolioList(marketProvider)
//                       : _buildBondsPortfolioList(marketProvider),
//         ),
//       ),
//     );
//   }

//   Widget _buildAllPortfolioList(MarketProvider marketProvider) {
//     final allPortfolio = [
//       ...marketProvider.eachFundPortfolio,
//       ...marketProvider.eachStockPortfolio
//     ];

//     if (allPortfolio.isEmpty) {
//       return Container(
//         color: const Color(0xFFF0F2F5),
//         child: _buildEmptyState(),
//       );
//     }

//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: allPortfolio.length,
//       itemBuilder: (context, i) {
//         final portfolio = allPortfolio[i];
//         final isStock = marketProvider.eachStockPortfolio.contains(portfolio);

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 6,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: specificPortfolioCard(
//               isStock: isStock,
//               appHeight: MediaQuery.of(context).size.height,
//               appWidth: MediaQuery.of(context).size.width,
//               stockName: portfolio.stockName ?? "",
//               stockID: portfolio.stockID ?? "",
//               qnty: portfolio.qnty ?? "0",
//               avgPrice: portfolio.closePrice ?? "0",
//               invVal: safeFormat(portfolio.investedValue),
//               currentVal: portfolio.currentValue ?? 0,
//               marketPrice: portfolio.closePrice ?? "0",
//               context: context,
//               changeAmount: portfolio.changeAmount ?? "0",
//               changePercentage: portfolio.changePercentage ?? "0",
//               logoUrl: portfolio.logoUrl ?? "",
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFundsPortfolioList(MarketProvider marketProvider) {
//     if (_currentPortfolio.isNotEmpty) {
//       return ListView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
//         physics: const AlwaysScrollableScrollPhysics(),
//         itemCount: marketProvider.eachFundPortfolio.length,
//         itemBuilder: (context, i) {
//           final portfolio = marketProvider.eachFundPortfolio[i];

//           final fundDetails = marketProvider.fund.firstWhere(
//             (fund) => fund.shareClassCode == portfolio.stockID,
//           );

//           return Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: 4,
//               horizontal: 8,
//             ),
//             child: specificPortfolioCard(
//               isStock: false,
//               appHeight: MediaQuery.of(context).size.height,
//               appWidth: MediaQuery.of(context).size.width,
//               stockName: portfolio.stockName ?? "",
//               stockID: portfolio.stockID ?? "",
//               qnty: portfolio.qnty ?? "0",
//               avgPrice: portfolio.closePrice ?? "0",
//               invVal: safeFormat(portfolio.investedValue),
//               currentVal: portfolio.currentValue ?? 0,
//               marketPrice: portfolio.closePrice ?? "0",
//               context: context,
//               changeAmount: portfolio.changeAmount ?? "0",
//               changePercentage: portfolio.changePercentage ?? "0",
//               initialMinContribution: fundDetails.initialMinContribution,
//               subsequentAmount: fundDetails.subsequentAmount,
//               logoUrl: portfolio.logoUrl ?? "",
//             ),
//           );
//         },
//       );
//     } else {
//       return Container(
//         color: const Color(0xFFF0F2F5),
//         child: _buildEmptyState(),
//       );
//     }
//   }

//   Widget _buildStocksPortfolioList(MarketProvider marketProvider) {
//     if (_currentStocks.isNotEmpty) {
//       return ListView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
//         physics: const AlwaysScrollableScrollPhysics(),
//         itemCount: marketProvider.eachStockPortfolio.length,
//         itemBuilder: (context, i) {
//           final portfolio = marketProvider.eachStockPortfolio[i];

//           return Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: 4,
//               horizontal: 8,
//             ),
//             child: specificPortfolioCard(
//               isStock: true,
//               appHeight: MediaQuery.of(context).size.height,
//               appWidth: MediaQuery.of(context).size.width,
//               stockName: portfolio.stockName ?? "",
//               stockID: portfolio.stockID ?? "",
//               qnty: portfolio.qnty ?? "0",
//               avgPrice: portfolio.closePrice ?? "0",
//               invVal: safeFormat(portfolio.investedValue),
//               currentVal: portfolio.currentValue ?? 0,
//               marketPrice: portfolio.closePrice ?? "0",
//               context: context,
//               changeAmount: portfolio.changeAmount ?? "0",
//               changePercentage: portfolio.changePercentage ?? "0",
//               logoUrl: portfolio.logoUrl ?? "",
//             ),
//           );
//         },
//       );
//     } else {
//       return Container(
//         color: const Color(0xFFF0F2F5),
//         child: _buildEmptyState(),
//       );
//     }
//   }

//   Widget _buildBondsPortfolioList(MarketProvider marketProvider) {
//     final bonds = marketProvider.myBonds;
//     if (bonds.isEmpty) {
//       return Container(
//         color: const Color(0xFFF0F2F5),
//         child: _buildEmptyStateBonds(),
//       );
//     }
//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: bonds.length,
//       itemBuilder: (context, i) {
//         final bond = bonds[i];
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: _bondPortfolioCard(bond),
//         );
//       },
//     );
//   }

//   Widget _bondPortfolioCard(MyBond bond) {
//     // bond is MyBond
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//         child: Row(
//           children: [
//             // Icon or placeholder for bond
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: AppColor().blueBTN.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.account_balance,
//                   color: Color(0xff1A82CF), size: 32),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     bond.bondName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Color(0xff1A82CF),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       const Text(
//                         "Type: ",
//                         style: TextStyle(fontSize: 13, color: Colors.black54),
//                       ),
//                       Text(
//                         bond.bondType,
//                         style: const TextStyle(
//                             fontSize: 13, color: Colors.black87),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         "Market: ",
//                         style: TextStyle(fontSize: 13, color: Colors.black54),
//                       ),
//                       Text(
//                         bond.market,
//                         style: const TextStyle(
//                             fontSize: 13, color: Colors.black87),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       const Text(
//                         "Coupon: ",
//                         style: TextStyle(fontSize: 13, color: Colors.black54),
//                       ),
//                       Text(
//                         bond.couponRate,
//                         style: const TextStyle(
//                             fontSize: 13, color: Colors.black87),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         "Face Value: ",
//                         style: TextStyle(fontSize: 13, color: Colors.black54),
//                       ),
//                       Text(
//                         bond.faceValue.toString(),
//                         style: const TextStyle(
//                             fontSize: 13, color: Colors.black87),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       const Text(
//                         "Maturity: ",
//                         style: TextStyle(fontSize: 13, color: Colors.black54),
//                       ),
//                       Text(
//                         "${bond.maturityDate.year}-${bond.maturityDate.month.toString().padLeft(2, '0')}-${bond.maturityDate.day.toString().padLeft(2, '0')}",
//                         style: const TextStyle(
//                             fontSize: 13, color: Colors.black87),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.account_balance_wallet_outlined,
//             size: 48,
//             color: AppColor().blueBTN.withOpacity(0.5),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             activeTab == "stock"
//                 ? "Start Investing Now"
//                 : "Build Your Portfolio",
//             style: TextStyle(
//               color: AppColor().textColor,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             activeTab == "stock"
//                 ? "Explore DSE Stocks"
//                 : "Buy units to grow your portfolio",
//             style: TextStyle(
//               color: AppColor().textColor.withOpacity(0.6),
//               fontSize: 16,
//             ),
//           ),
//           if (activeTab == "stock")
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AllFundsScreen(),
//                   ),
//                 );
//               },
//               child: Text(
//                 "View Stocks",
//                 style: TextStyle(
//                   color: AppColor().blueBTN,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyStateBonds() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.account_balance,
//             size: 48,
//             color: AppColor().blueBTN.withOpacity(0.5),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             "No Bonds in Portfolio",
//             style: TextStyle(
//               color: Colors.black87,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Buy bonds to grow your portfolio",
//             style: TextStyle(
//               color: Colors.black54,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPortfolioOverview(MarketProvider marketProvider) {
//     PortfolioModel? selectedPortfolio;
//     String title;

//     if (activeTab == "bonds") {
//       // Render a dedicated bond portfolio card
//       return Column(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.25,
//             child: _buildBondPortfolioCard(
//               marketProvider.bondPortfolio,
//               AppColor().portfolio,
//             ),
//           ),
//         ],
//       );
//     }

//     switch (activeTab) {
//       case "funds":
//         selectedPortfolio = marketProvider.fundPortfolio;
//         title = "Fund Portfolio";
//         break;
//       case "stock":
//         selectedPortfolio = marketProvider.portfolio;
//         title = "Stock Portfolio";
//         break;
//       default:
//         selectedPortfolio = marketProvider.combinedPortfolio;
//         title = "My Portfolio";
//     }

//     return Column(
//       children: [
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.25,
//           child: _buildPortfolioCard(
//             title,
//             selectedPortfolio,
//             AppColor().portfolio,
//             activeTab == "all",
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBondPortfolioCard(
//       BondPortfolioSummary? bondPortfolio, Color gradientColor) {
//     String safeCurrencyFormat(dynamic value) {
//       if (value == null) return "0.00";
//       try {
//         if (value is String) value = double.tryParse(value) ?? 0.0;
//         return currencyFormat(value);
//       } catch (_) {
//         return "0.00";
//       }
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: gradientColor.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   gradientColor,
//                   gradientColor.withOpacity(0.85),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             height: MediaQuery.of(context).size.height * 0.25,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Bonds Portfolio",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   height: 1,
//                   width: double.infinity,
//                   color: Colors.white.withOpacity(0.5),
//                 ),
//                 const SizedBox(height: 8),
//                 if (bondPortfolio != null)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Invested Value(TZS)",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             safeCurrencyFormat(bondPortfolio.investedValue),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         width: 1,
//                         height: 40,
//                         color: Colors.white.withOpacity(0.5),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Current Value(TZS)",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             safeCurrencyFormat(bondPortfolio.currentValue),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   )
//                 else
//                   const Text(
//                     "No data available",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPortfolioCard(String title, PortfolioModel? portfolio,
//       Color gradientColor, bool isCombined) {
//     final bool isProfit = (portfolio?.profitLoss ?? 0) >= 0;
//     final bool showShimmer = _showShimmer &&
//         (portfolio == null ||
//             portfolio.investedValue == null ||
//             portfolio.currentValue == null ||
//             portfolio.profitLoss == null ||
//             portfolio.profitLossPercentage == null);

//     T fallbackZero<T>(T? value, T zero) => showShimmer ? zero : (value ?? zero);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: gradientColor.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   gradientColor,
//                   gradientColor.withOpacity(0.85),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             height: MediaQuery.of(context).size.height * 0.25,
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                 color: AppColor().cardBottom,
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(20),
//                   bottomRight: Radius.circular(20),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Overall Profit/Loss",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         if (portfolio != null)
//                           Icon(
//                             isProfit ? Icons.add : Icons.remove,
//                             color: isProfit
//                                 ? Colors.greenAccent
//                                 : Colors.redAccent,
//                             size: 14,
//                           ),
//                         const SizedBox(width: 4),
//                         Text(
//                           portfolio != null
//                               ? "TZS ${isProfit ? '' : ''}${safeCurrencyFormat((portfolio.profitLoss ?? 0).abs())}"
//                               : "N/A",
//                           style: TextStyle(
//                             color: isProfit
//                                 ? Colors.greenAccent
//                                 : Colors.redAccent,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (portfolio?.profitLossPercentage != null)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: isProfit
//                                   ? Colors.greenAccent.withOpacity(0.2)
//                                   : Colors.redAccent.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               "${isProfit ? '' : ''}${portfolio?.profitLossPercentage}%",
//                               style: TextStyle(
//                                 color: isProfit
//                                     ? Colors.greenAccent
//                                     : Colors.redAccent,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   height: 1,
//                   width: double.infinity,
//                   color: Colors.white.withOpacity(0.5),
//                 ),
//                 const SizedBox(height: 8),
//                 if (portfolio != null || !showShimmer)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Invested Value(TZS)",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             safeCurrencyFormat(
//                                 fallbackZero(portfolio?.investedValue, 0.0)),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         width: 1,
//                         height: 40,
//                         color: Colors.white.withOpacity(0.5),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Current Value(TZS)",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             safeCurrencyFormat(
//                                 fallbackZero(portfolio?.currentValue, 0.0)),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   )
//                 else
//                   const Text(
//                     "No data available",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final marketProvider = Provider.of<MarketProvider>(context);
//     final metadataProvider = Provider.of<MetadataProvider>(context);
//     final double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.account_circle_sharp),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.notification_add,
//               color: AppColor().blueBTN,
//             ),
//             onPressed: () {
//               // Handle notification button press
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           SafeArea(
//             child: RefreshIndicator(
//               onRefresh: onManualRefresh,
//               child: Column(
//                 children: [
//                   if (_isStatusBannerVisible)
//                     SizedBox(height: screenHeight * 0.08),
//                   if (SessionPref.getUserProfile()![6] == "finished" &&
//                       SessionPref.getUserProfile()![7] == "active")
//                     _buildPortfolioOverview(marketProvider)
//                   else
//                     SizedBox(height: screenHeight * 0.02),
//                   _buildNewTabBar(),
//                   _buildTabBar(),
//                   _buildPortfolioList(marketProvider),
//                 ],
//               ),
//             ),
//           ),
//           if (_isStatusBannerVisible)
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: StatusBannerHelper.buildStatusBanner(
//                 context: context,
//                 statusBannerAnimation: _statusBannerAnimation,
//                 rotate: rotate,
//                 metadataProvider: metadataProvider,
//                 onCompletePressed: () {
//                   setState(() => rotate = true);
//                   setState(() async {
//                     rotate = await PullMetadata()
//                         .nidabtnPressed(metadataProvider, context);
//                   });
//                 },
//                 onClosePressed: _hideStatusBanner,
//                 updated: '',
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
