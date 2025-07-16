import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/models/fund/fund_model.dart';
import 'package:iwealth/stocks/models/bond_model.dart';
import 'package:iwealth/stocks/screen/stockdetails.dart';
import 'package:iwealth/stocks/screen/bonddetails.dart';
import 'package:iwealth/screens/fund/all_funds.dart';
import 'package:iwealth/screens/fund/fund_orders_list.dart';
import 'package:iwealth/stocks/screen/stock_order_list.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'widgets/profile_status_card.dart';

class InvestmentWidgets {
  // static Widget buildInvestmentSection({
  //   required BuildContext context,
  //   required MarketProvider marketProvider,
  //   required String selectedInvestmentType,
  //   required Function(String) onInvestmentTypeChanged,
  // }) {
  //   return SingleChildScrollView(
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const SizedBox(
  //           height: 20,
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //           child: Text(
  //             "Investments",
  //             style: TextStyle(
  //               color: AppColor().textColor,
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 2),
  //         Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[200],
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: const [
  //               BoxShadow(
  //                 color: Colors.white,
  //                 blurRadius: 8,
  //                 offset: Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: _buildInvestmentOption(
  //                   context: context,
  //                   title: 'Funds',
  //                   imagePath: 'assets/images/mutual_funds.png',
  //                   bgColor: Colors.white,
  //                   isDisabled: false,
  //                   onTap: () => onInvestmentTypeChanged('funds'),
  //                   isSelected: selectedInvestmentType == 'funds',
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: _buildInvestmentOption(
  //                   context: context,
  //                   title: 'Stocks',
  //                   imagePath: 'assets/images/stocks.png',
  //                   bgColor: Colors.white,
  //                   isDisabled: false,
  //                   onTap: () {
  //                     onInvestmentTypeChanged('stocks');
  //                     final mp =
  //                         Provider.of<MarketProvider>(context, listen: false);
  //                     if (mp.stock == null || mp.stock!.isEmpty) {
  //                       StockWaiter().getStocks(mp: mp, context: context);
  //                     }
  //                   },
  //                   isSelected: selectedInvestmentType == 'stocks',
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: _buildInvestmentOption(
  //                   context: context,
  //                   title: 'Bonds',
  //                   imagePath: 'assets/images/bonds.png',
  //                   bgColor: Colors.white,
  //                   isDisabled: false,
  //                   onTap: () => onInvestmentTypeChanged('bonds'),
  //                   isSelected: selectedInvestmentType == 'bonds',
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // Modify _buildInvestmentSection to handle selection
  static Widget buildInvestmentSection({
    required BuildContext context,
    required MarketProvider marketProvider,
    required String selectedInvestmentType,
    required Function(String) onInvestmentTypeChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Force minimum height
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "Investments",
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 0), // Reduced vertical margin
          padding: const EdgeInsets.all(12), // Reduced padding
          decoration: BoxDecoration(
            color: AppColor().lowerBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildInvestmentOption(
                  context,
                  'Funds',
                  'assets/images/mutual_funds.svg',
                  Colors.white,
                  false,
                  () => onInvestmentTypeChanged('funds'),
                  isSelected: selectedInvestmentType == 'funds',
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: _buildInvestmentOption(
                  context,
                  'Stocks',
                  'assets/images/stock.svg',
                  Colors.white,
                  false,
                  () => onInvestmentTypeChanged('stocks'),
                  isSelected: selectedInvestmentType == 'stocks',
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: _buildInvestmentOption(
                  context,
                  'Bonds',
                  'assets/images/bonds.svg',
                  Colors.white,
                  false,
                  () => onInvestmentTypeChanged('bonds'),
                  isSelected: selectedInvestmentType == 'bonds',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Update _buildInvestmentOption to show selection state
  static Widget _buildInvestmentOption(
    BuildContext context,
    String title,
    String imagePath,
    Color bgColor,
    bool isDisabled,
    VoidCallback? onTap, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
          // Load stocks data when stocks tab is selected
          if (title.contains('Stocks')) {
            final mp = Provider.of<MarketProvider>(context, listen: false);
            if (mp.stock == null || mp.stock!.isEmpty) {
              StockWaiter().getStocks(mp: mp, context: context);
            }
          }
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Reduced padding
            decoration: BoxDecoration(
              color: isSelected ? AppColor().orangeApp.withAlpha(40) : bgColor,
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(
              //   color: isSelected
              //       ? AppColor().blueBTN
              //       : isDisabled
              //           ? Colors.grey.shade300
              //           : AppColor().blueBTN.withAlpha(20),
              // ),
            ),
            child: SvgPicture.asset(
              imagePath,
              color: isSelected ? AppColor().orangeApp : AppColor().blueBTN,
            ),
          ),
          if (isDisabled)
            Container(
              margin: const EdgeInsets.only(top: 4), // Reduced margin
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2), // Reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 9, // Reduced font size
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 4), // Reduced spacing
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDisabled
                  ? Colors.grey
                  : isSelected
                      ? AppColor().orangeApp
                      : AppColor().blueBTN,

              // color: isDisabled ? Colors.grey : AppColor().textColor,
              fontSize: 13, // Reduced font size
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // static Widget buildFundsGrid(BuildContext context, MarketProvider mp) {
  //   if (mp.fund.isEmpty) {
  //     return _buildGridShimmer();
  //   }
  //
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       _buildGridHeader(
  //         context: context,
  //         title: "Funds",
  //         onExploreMore: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const AllFundsScreen(initialTabIndex: 2),
  //             ),
  //           );
  //         },
  //       ),
  //       _buildGrid(
  //         context: context,
  //         itemCount: mp.fund.length,
  //         itemBuilder: (context, index) {
  //           final fund = mp.fund[index];
  //           return _buildFundCard(context, fund, mp);
  //         },
  //       ),
  //     ],
  //   );
  // }
  //
  // static Widget buildStocksGrid(BuildContext context, MarketProvider mp) {
  //   if (mp.stock == null || mp.stock!.isEmpty) {
  //     return _buildGridShimmer();
  //   }
  //
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       _buildGridHeader(
  //         context: context,
  //         title: "Stocks",
  //         onExploreMore: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const AllFundsScreen(initialTabIndex: 0),
  //             ),
  //           );
  //         },
  //       ),
  //       _buildGrid(
  //         context: context,
  //         itemCount: mp.stock!.length > 3 ? 6 : mp.stock!.length,
  //         itemBuilder: (context, index) {
  //           final stock = mp.stock![index];
  //           return _buildStockCard(context, stock);
  //         },
  //       ),
  //     ],
  //   );
  // }

  // static Widget buildBondsGrid(BuildContext context, MarketProvider mp) {
  //   if (mp.bonds.isEmpty) {
  //     return _buildGridShimmer();
  //   }
  //
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       _buildGridHeader(
  //         context: context,
  //         title: "Bonds",
  //         onExploreMore: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const AllFundsScreen(initialTabIndex: 1),
  //             ),
  //           );
  //         },
  //       ),
  //       _buildGrid(
  //         context: context,
  //         itemCount: mp.bonds.length,
  //         itemBuilder: (context, index) {
  //           final bond = mp.bonds[index];
  //           return _buildBondCard(context, bond);
  //         },
  //       ),
  //     ],
  //   );
  // }

  static Widget _buildGridHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onExploreMore,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColor().textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onExploreMore,
            child: Text(
              "Explore More",
              style: TextStyle(
                color: AppColor().blueBTN,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGrid({
    required BuildContext context,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height * 0.27,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }

  static Widget _buildGridShimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildFundCard(
      BuildContext context, FundModel fund, MarketProvider mp) {
    return Hero(
      tag: _getUniqueHeroTag('fund_${fund.shareClassCode}'),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailScreen(
                          companyName: fund.name,
                          logo: fund.logoUrl,
                          tickerSymbol: fund.name,
                          stockID: fund.shareClassCode,
                          screen: "fund",
                        ),
                      )
                      // PageRouteBuilder(
                      //   transitionDuration: const Duration(milliseconds: 500),
                      //   reverseTransitionDuration:
                      //       const Duration(milliseconds: 500),
                      //   pageBuilder: (context, animation, secondaryAnimation) {
                      //     return FadeTransition(
                      //       opacity: animation,
                      //       child: StockDetailScreen(
                      //         companyName: fund.name,
                      //         logo: fund.logoUrl,
                      //         tickerSymbol: fund.name,
                      //         stockID: fund.shareClassCode,
                      //         screen: "fund",
                      //       ),
                      //     );
                      // },
                      // ),
                      );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Center(
                    child: fund.logoUrl.isNotEmpty
                        ? Image.network(
                            fund.logoUrl,
                            fit: BoxFit.contain,
                            height: 75,
                            width: 75,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.account_balance_wallet,
                                    size: 44, color: Colors.grey),
                          )
                        : const Icon(Icons.account_balance_wallet,
                            size: 44, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStockCard(BuildContext context, dynamic stock) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(
                    companyName: stock.fullname,
                    logo: "assets/images/tickerLogo/${stock.name}.jpg",
                    tickerSymbol: stock.name,
                    price: stock.price,
                    change: stock.changePercentage,
                    changeAmount: stock.changeAmount,
                    stockID: stock.stockID,
                    volume: stock.volume,
                    mcap: stock.marketCap,
                    highPrice: stock.highPrice,
                    lowPrice: stock.lowPrice,
                    screen: "stock",
                    highOrNAVLabel: "High Price",
                    lowOrInitLabel: "Low Price",
                    mcapOrEntryLabel: "Market Cap",
                    volOrLaunchLabel: "Volume",
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Center(
                child: Image.asset(
                  "assets/images/tickerLogo/${stock.name}.jpg",
                  fit: BoxFit.contain,
                  height: 44,
                  width: 44,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stock.name ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColor().textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFundsGrid(
      {required MarketProvider mp, required BuildContext context}) {
    if (mp.fund.isEmpty) {
      return FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)), // Wait 3 seconds
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildFundsGridShimmer(); // Show shimmer while waiting
          } else {
            return _buildNoDataMessage(
                "No funds available", context); // Show message after timeout
          }
        },
      );
    }

    final boxHeight = MediaQuery.of(context).size.height * 0.35;

    final headerHeight = (boxHeight * 0.15);
    final cardBoxHeight = (boxHeight * 0.85);
    final cardHeight = (cardBoxHeight - 24) * 0.45;

    return SizedBox(
      height: boxHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: headerHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Funds ",
                    style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AllFundsScreen(initialTabIndex: 2),
                        ),
                      );
                    },
                    child: Text(
                      "Explore More",
                      style: TextStyle(
                        color: AppColor().blueBTN,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            padding: const EdgeInsets.all(12),
            height: cardBoxHeight,
            decoration: BoxDecoration(
              color: AppColor().lowerBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
                runSpacing: cardBoxHeight * 0.05,
                spacing: 12,
                children: mp.fund
                    .sublist(0, mp.fund.length > 6 ? 6 : mp.fund.length)
                    .map((fund) {
                  return _buildStockBondCard(
                    context: context,
                    cardHeight: cardHeight,
                    name: fund.name ?? '',
                    logoUrl: fund.logoUrl ?? '',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StockDetailScreen(
                                    companyName: fund.name,
                                    logo: fund.logoUrl,
                                    tickerSymbol: fund.name,
                                    stockID: fund.shareClassCode,
                                    screen: "fund",
                                  ))
                          //     PageRouteBuilder(
                          //       transitionDuration: const Duration(milliseconds: 500),
                          //       reverseTransitionDuration:
                          //           const Duration(milliseconds: 500),
                          //       pageBuilder:
                          //           (context, animation, secondaryAnimation) {
                          //         return FadeTransition(
                          //           opacity: animation,
                          //           child: StockDetailScreen(
                          //             companyName: fund.name,
                          //             logo: fund.logoUrl,
                          //             tickerSymbol: fund.name,
                          //             stockID: fund.shareClassCode,
                          //             screen: "fund",
                          //           ),
                          //         );
                          //       },
                          //     ),
                          );
                    },
                  );
                }).toList()),
          ),
        ],
      ),
    );
  }

  static Widget buildFundsGridShimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Add new method for stocks grid
  static Widget buildStocksGrid(
      {required MarketProvider mp, required BuildContext context}) {
    if (mp.stock == null || mp.stock!.isEmpty) {
      return FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildFundsGridShimmer();
          } else {
            return _buildNoDataMessage("No Stocks available", context);
          }
        },
      );
    }
    final boxHeight = MediaQuery.of(context).size.height * 0.35;

    final headerHeight = (boxHeight * 0.15);
    final cardBoxHeight = (boxHeight * 0.85);
    final cardHeight = (cardBoxHeight - 24) * 0.45;

    return SizedBox(
      height: boxHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: headerHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Stocks ",
                    style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AllFundsScreen(initialTabIndex: 0),
                        ),
                      );
                    },
                    child: Text(
                      "Explore More",
                      style: TextStyle(
                        color: AppColor().blueBTN,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            padding: const EdgeInsets.all(12),
            height: cardBoxHeight,
            decoration: BoxDecoration(
              color: AppColor().lowerBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
                runSpacing: cardBoxHeight * 0.05,
                spacing: 12,
                children: mp.stock!
                    .sublist(0, mp.stock!.length > 6 ? 6 : mp.stock!.length)
                    .map((stock) {
                  return _buildStockBondCard(
                      context: context,
                      cardHeight: cardHeight,
                      name: stock.name ?? '',
                      logoUrl: "assets/images/tickerLogo/${stock.name}.jpg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockDetailScreen(
                              companyName: stock.fullname,
                              logo:
                                  "assets/images/tickerLogo/${stock.name}.jpg",
                              tickerSymbol: stock.name,
                              price: stock.price,
                              change: stock.changePercentage,
                              changeAmount: stock.changeAmount,
                              stockID: stock.stockID,
                              volume: stock.volume,
                              mcap: stock.marketCap,
                              highPrice: stock.highPrice,
                              lowPrice: stock.lowPrice,
                              screen: "stock",
                              highOrNAVLabel: "High Price",
                              lowOrInitLabel: "Low Price",
                              mcapOrEntryLabel: "Market Cap",
                              volOrLaunchLabel: "Volume",
                            ),
                          ),
                        );
                      });
                }).toList()),
          ),
        ],
      ),
    );
  }

  static Widget buildBondsGrid(
      {required MarketProvider mp, required BuildContext context}) {
    if (mp.bonds.isEmpty) {
      return FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildFundsGridShimmer();
          } else {
            return _buildNoDataMessage("No Bonds available", context);
          }
        },
      );
    }
    final boxHeight = MediaQuery.of(context).size.height * 0.35;

    final headerHeight = (boxHeight * 0.15);
    final cardBoxHeight = (boxHeight * 0.85);
    final cardHeight = (cardBoxHeight - 24) * 0.45;

    return SizedBox(
      height: boxHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: headerHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bonds ",
                    style: TextStyle(
                      color: AppColor().textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AllFundsScreen(initialTabIndex: 1),
                        ),
                      );
                    },
                    child: Text(
                      "Explore More",
                      style: TextStyle(
                        color: AppColor().blueBTN,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            padding: const EdgeInsets.all(12),
            height: cardBoxHeight,
            decoration: BoxDecoration(
              color: AppColor().lowerBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
                runSpacing: cardBoxHeight * 0.05,
                spacing: 12,
                children: mp.bonds
                    .sublist(0, mp.bonds.length > 6 ? 6 : mp.bonds.length)
                    .map((bond) {
                  return _buildStockBondCard(
                      context: context,
                      cardHeight: cardHeight,
                      name: bond.securityName ?? '',
                      logoUrl: bond.logoUrl ?? '',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BondDetailsScreen(bond: bond)
                              // StockDetailScreen(
                              //   companyName: bond.securityName,
                              //   logo: bond.logoUrl,
                              //   tickerSymbol: bond.securityName,
                              //   stockID: bond.id,
                              //   screen: "bond",
                              // )

                              ),
                        );
                      });
                }).toList()),
          ),
        ],
      ),
    );
  }

  static Widget _buildStockBondCard({
    required BuildContext context,
    required double cardHeight,
    required String name,
    required String logoUrl,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: cardHeight,
        width: (MediaQuery.of(context).size.width - 80) /
            3, // Adjust width for 3 columns
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: cardHeight * 0.7,
                width: cardHeight * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Center(
                  child: logoUrl.isNotEmpty
                      ? logoUrl.contains('http')
                          ? Image.network(
                              logoUrl,
                              fit: BoxFit.contain,
                              height: cardHeight * 0.4,
                              width: cardHeight * 0.4,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.account_balance,
                                      size: 44, color: Colors.grey),
                            )
                          : Image.asset(
                              logoUrl,
                              fit: BoxFit.contain,
                              height: cardHeight * 0.4,
                              width: cardHeight * 0.4,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.account_balance,
                                      size: cardHeight * 0.4,
                                      color: Colors.grey),
                            )
                      : Icon(Icons.account_balance,
                          size: cardHeight * 0.4, color: Colors.grey),
                ),
              ),
              // const SizedBox(height: 8),
              SizedBox(
                height: cardHeight * 0.2,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor().textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildActionButton({
    required BuildContext context,
    required MarketProvider marketProvider,
    required String selectedInvestmentType,
    required bool hasSubscriptions,
    required bool hasOrders,
    required ProfileStatus Function() getProfileStatus,
  }) {
    if (getProfileStatus() == ProfileStatus.pending ||
        (!hasSubscriptions && selectedInvestmentType == 'funds') ||
        (!hasOrders && selectedInvestmentType == 'stocks')) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _goToOrders(
            context: context,
            marketProvider: marketProvider,
            selectedInvestmentType: selectedInvestmentType,
          ),
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor().blueBTN,
                  AppColor().blueBTN.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColor().blueBTN.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedInvestmentType == "stocks"
                        ? Icons.list_alt
                        : Icons.description_outlined,
                    color: AppColor().constant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedInvestmentType == "stocks"
                        ? "View Orders"
                        : "View Subscriptions",
                    style: TextStyle(
                      color: AppColor().constant,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildNoDataMessage(String message, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColor().lowerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _goToOrders({
    required BuildContext context,
    required MarketProvider marketProvider,
    required String selectedInvestmentType,
  }) async {
    String? profileStatus = SessionPref.getUserProfile()?[6];
    String? kycStatus = SessionPref.getUserProfile()?[7];

    if (profileStatus == "pending") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Complete your profile to start investing.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else if (profileStatus == "submitted" || kycStatus == "pending") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Your KYC is under review. Please wait.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (selectedInvestmentType == "stocks") {
      if (marketProvider.order.isEmpty) {
        var orderStatus = await StockWaiter().getOrders(marketProvider);
        if (orderStatus == "1") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderListPage()),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderListPage()),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FundOrdersListScreen()),
      );
    }
  }

  static String _getUniqueHeroTag(String baseTag) {
    const uuid = Uuid();
    return '${baseTag}_${uuid.v4()}';
  }
}
