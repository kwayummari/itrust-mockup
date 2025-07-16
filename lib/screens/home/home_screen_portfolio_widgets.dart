import 'package:flutter/material.dart';
import 'package:iwealth/stocks/models/bond_holdings_model.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/stocks/models/portfolio.dart';

class PortfolioWidgets {
  static PortfolioModel _createEmptyFundPortfolio() {
    return PortfolioModel(
      stockID: '',
      stockName: '',
      qnty: '0',
      closePrice: '0',
      investedValue: 0.0,
      currentValue: 0.0,
      profitLoss: 0.0,
      profitLossPercentage: '0',
      changeAmount: '0',
      changePercentage: '0',
    );
  }

  static Widget buildPortfolioOverview({
    required BuildContext context,
    required MarketProvider marketProvider,
    required PageController pageController,
    required bool isPortfolioVisible,
    required bool showShimmer,
    required String Function(dynamic) safeCurrencyFormat,
    required VoidCallback onVisibilityToggle,
  }) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: PageView(
            controller: pageController,
            children: [
              buildPortfolioCard(
                  context: context,
                  title: "My Wallet",
                  portfolio: marketProvider.portfolio,
                  gradientColor: AppColor().portfolio,
                  isCombined: true,
                  showShimmer: showShimmer,
                  isPortfolioVisible: isPortfolioVisible,
                  onVisibilityToggle: onVisibilityToggle,
                  safeCurrencyFormat: safeCurrencyFormat),
              buildPortfolioCard(
                  context: context,
                  title: "My Portfolio",
                  isCombined: false,
                  portfolio: marketProvider.combinedPortfolio,
                  isPortfolioVisible: isPortfolioVisible,
                  gradientColor: AppColor().portfolio,
                  showShimmer: showShimmer,
                  onVisibilityToggle: onVisibilityToggle,
                  safeCurrencyFormat: safeCurrencyFormat),
              buildPortfolioCard(
                  context: context,
                  title: "Fund Portfolio",
                  portfolio: marketProvider.fundPortfolio ??
                      _createEmptyFundPortfolio(),
                  isCombined: false,
                  isPortfolioVisible: isPortfolioVisible,
                  gradientColor: AppColor().portfolio,
                  showShimmer: showShimmer,
                  onVisibilityToggle: onVisibilityToggle,
                  safeCurrencyFormat: safeCurrencyFormat),
              buildPortfolioCard(
                  context: context,
                  title: "Stock Portfolio",
                  portfolio: marketProvider.portfolio,
                  isCombined: false,
                  isPortfolioVisible: isPortfolioVisible,
                  gradientColor: AppColor().portfolio,
                  showShimmer: showShimmer,
                  onVisibilityToggle: onVisibilityToggle,
                  safeCurrencyFormat: safeCurrencyFormat),
              buildPortfolioCard(
                  context: context,
                  title: "Bond Portfolio",
                  portfolio: marketProvider.portfolio,
                  bondPortfolio: marketProvider.bondPortfolio,
                  isCombined: false,
                  isPortfolioVisible: isPortfolioVisible,
                  gradientColor: AppColor().portfolio,
                  showShimmer: showShimmer,
                  onVisibilityToggle: onVisibilityToggle,
                  safeCurrencyFormat: safeCurrencyFormat),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16.0), // Align with portfolio cards
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: pageController.hasClients &&
                          pageController.page?.round() == index
                      ? 24
                      : 8,
                  decoration: BoxDecoration(
                    color: pageController.hasClients &&
                            pageController.page?.round() == index
                        ? AppColor().portfolio
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildPortfolioCard({
    required BuildContext context,
    required String title,
    required PortfolioModel? portfolio,
    BondPortfolioSummary? bondPortfolio,
    required Color gradientColor,
    required bool isCombined,
    required bool isPortfolioVisible,
    required bool showShimmer,
    required String Function(dynamic) safeCurrencyFormat,
    required VoidCallback onVisibilityToggle,
  }) {
    final bool isProfit = (portfolio?.profitLoss ?? 0) >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor().portfolio,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.white.withAlpha(100), height: 1),
                        if (!showShimmer)
                          Expanded(
                            child: buildPortfolioCardData(
                                context: context,
                                showShimmer: showShimmer,
                                isPortfolioVisible: isPortfolioVisible,
                                safeCurrencyFormat: safeCurrencyFormat,
                                portfolio: portfolio,
                                bondPortfolio: bondPortfolio,
                                isCombined: title == "My Wallet",
                                isBond: title == "Bond Portfolio",
                                onVisibilityToggle: onVisibilityToggle),
                          )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.06,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor().cardBottom, // Darker blue color
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!showShimmer && title == "My Portfolio")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              "Overall Profit/Loss",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                if (isPortfolioVisible)
                                  Icon(
                                    isProfit ? Icons.add : Icons.remove,
                                    color: isProfit
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    size: 14,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  isPortfolioVisible
                                      ? (showShimmer
                                          ? "Loading..."
                                          : ("${isProfit ? '' : ''}${safeCurrencyFormat((portfolio?.profitLoss ?? 0).abs())}"))
                                      : " ********************",
                                  style: TextStyle(
                                    color: isProfit
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 14, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (isPortfolioVisible)
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isProfit
                                            ? Colors.greenAccent.withAlpha(20)
                                            : Colors.redAccent.withAlpha(20),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "${isProfit ? '' : ''}${(portfolio?.profitLossPercentage ?? 0.0)} %",
                                        style: TextStyle(
                                          color: isProfit
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontSize: 14, // Reduced font size
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ))
                                else
                                  Text(
                                    " **",
                                    style: TextStyle(
                                      color: isProfit
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 14, // Reduced font size
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      if (portfolio != null && title == "Fund Portfolio")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Profit/Loss",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                if (isPortfolioVisible)
                                  Icon(
                                    isProfit ? Icons.add : Icons.remove,
                                    color: isProfit
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    size: 14,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  isPortfolioVisible
                                      ? (showShimmer
                                          ? "Loading..."
                                          : (portfolio.profitLoss != null
                                              ? "${isProfit ? '' : ''}${safeCurrencyFormat((portfolio.profitLoss ?? 0).abs())}"
                                              : "---"))
                                      : " ********************",
                                  style: TextStyle(
                                    color: isProfit
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 14, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (isPortfolioVisible)
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isProfit
                                            ? Colors.greenAccent.withAlpha(20)
                                            : Colors.redAccent.withAlpha(20),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "${isProfit ? '' : ''}${(portfolio.profitLossPercentage ?? 0.0)} %",
                                        style: TextStyle(
                                          color: isProfit
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontSize: 14, // Reduced font size
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ))
                                else
                                  Text(
                                    " **",
                                    style: TextStyle(
                                      color: isProfit
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 14, // Reduced font size
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      if (portfolio != null && title == "Stock Portfolio")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Profit/Loss",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                if (isPortfolioVisible)
                                  Icon(
                                    isProfit ? Icons.add : Icons.remove,
                                    color: isProfit
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    size: 14,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  isPortfolioVisible
                                      ? (showShimmer
                                          ? "Loading..."
                                          : (portfolio.profitLoss != null
                                              ? "${isProfit ? '' : ''}${safeCurrencyFormat((portfolio.profitLoss ?? 0.0).abs())}"
                                              : "---"))
                                      : " ********************",
                                  style: TextStyle(
                                    color: isProfit
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 14, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (isPortfolioVisible)
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isProfit
                                            ? Colors.greenAccent.withAlpha(20)
                                            : Colors.redAccent.withAlpha(20),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "${isProfit ? '' : ''}${(portfolio.profitLossPercentage ?? 0.0)} %",
                                        style: TextStyle(
                                          color: isProfit
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontSize: 14, // Reduced font size
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ))
                                else
                                  Text(
                                    " **",
                                    style: TextStyle(
                                      color: isProfit
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 14, // Reduced font size
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (showShimmer)
              Positioned(
                  bottom: 8,
                  left: 16,
                  right: 16,
                  child: buildPortfolioDataShimmer()),
          ],
        ),
      ),
    );
  }

  static Widget buildPortfolioCardData({
    required BuildContext context,
    required PortfolioModel? portfolio,
    required BondPortfolioSummary? bondPortfolio,
    required bool isCombined,
    required bool isBond,
    required bool showShimmer,
    required bool isPortfolioVisible,
    required String Function(dynamic) safeCurrencyFormat,
    required VoidCallback onVisibilityToggle,
  }) {
    if (isCombined) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Text(
                    "Trading Balance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "(TZS)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    isPortfolioVisible
                        ? (showShimmer
                            ? "Loading..."
                            : safeCurrencyFormat(portfolio?.wallet ?? 0.0))
                        : "************",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: onVisibilityToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                isPortfolioVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      );
    }

    if (isBond) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Text(
                    "Invested Value",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "(TZS)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isPortfolioVisible
                    ? (showShimmer
                        ? "Loading..."
                        : (bondPortfolio?.investedValue != null
                            ? safeCurrencyFormat(bondPortfolio?.investedValue)
                            : "---"))
                    : " ****",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              children: [
                Text(
                  "Invested Value",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "(TZS)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isPortfolioVisible
                  ? (showShimmer
                      ? "Loading..."
                      : (safeCurrencyFormat(portfolio?.investedValue ?? 0.0)))
                  : " ****",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 1, // Thin vertical line
          height: MediaQuery.of(context).size.height * 0.075,
          color: Colors.white.withAlpha(100),
          margin: const EdgeInsets.symmetric(horizontal: 4),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              children: [
                Text(
                  "Current Value",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "(TZS)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isPortfolioVisible
                  ? (showShimmer
                      ? "Loading..."
                      : (safeCurrencyFormat(portfolio?.currentValue ?? 0.0)))
                  : " ****",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildPortfolioDataShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Value Shimmer
        Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 150,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(height: 20),

        // Details Shimmer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Invested Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            // Profit/Loss
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  //
  // static Widget buildPortfolioOverview({
  //   required BuildContext context,
  //   required MarketProvider marketProvider,
  //   required PageController pageController,
  //   required bool isPortfolioVisible,
  //   required bool showShimmer,
  //   required String Function(dynamic) safeCurrencyFormat,
  //   required VoidCallback onVisibilityToggle,
  // }) {
  //   return Column(
  //     children: [
  //       SizedBox(
  //         height: MediaQuery.of(context).size.height * 0.2,
  //         child: PageView(
  //           controller: pageController,
  //           children: [
  //             _buildPortfolioCard(
  //               context: context,
  //               title: "My Wallet",
  //               portfolio: marketProvider.portfolio,
  //               gradientColor: AppColor().portfolio,
  //               isCombined: true,
  //               isPortfolioVisible: isPortfolioVisible,
  //               showShimmer: showShimmer,
  //               safeCurrencyFormat: safeCurrencyFormat,
  //               onVisibilityToggle: onVisibilityToggle,
  //             ),
  //             _buildPortfolioCard(
  //               context: context,
  //               title: "My Portfolio",
  //               portfolio: marketProvider.combinedPortfolio,
  //               gradientColor: AppColor().portfolio,
  //               isCombined: true,
  //               isPortfolioVisible: isPortfolioVisible,
  //               showShimmer: showShimmer,
  //               safeCurrencyFormat: safeCurrencyFormat,
  //               onVisibilityToggle: onVisibilityToggle,
  //             ),
  //             _buildPortfolioCard(
  //               context: context,
  //               title: "Fund Portfolio",
  //               portfolio: marketProvider.fundPortfolio,
  //               gradientColor: AppColor().portfolio,
  //               isCombined: false,
  //               isPortfolioVisible: isPortfolioVisible,
  //               showShimmer: showShimmer,
  //               safeCurrencyFormat: safeCurrencyFormat,
  //               onVisibilityToggle: onVisibilityToggle,
  //             ),
  //             _buildPortfolioCard(
  //               context: context,
  //               title: "Stock Portfolio",
  //               portfolio: marketProvider.portfolio,
  //               gradientColor: AppColor().portfolio,
  //               isCombined: false,
  //               isPortfolioVisible: isPortfolioVisible,
  //               showShimmer: showShimmer,
  //               safeCurrencyFormat: safeCurrencyFormat,
  //               onVisibilityToggle: onVisibilityToggle,
  //             ),
  //           ],
  //         ),
  //       ),
  //       Align(
  //         alignment: Alignment.centerLeft,
  //         child: Padding(
  //           padding: const EdgeInsets.only(left: 16.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: List.generate(4, (index) {
  //               return AnimatedContainer(
  //                 duration: const Duration(milliseconds: 300),
  //                 margin: const EdgeInsets.symmetric(horizontal: 4),
  //                 height: 8,
  //                 width: pageController.hasClients &&
  //                         pageController.page?.round() == index
  //                     ? 24
  //                     : 8,
  //                 decoration: BoxDecoration(
  //                   color: pageController.hasClients &&
  //                           pageController.page?.round() == index
  //                       ? AppColor().portfolio
  //                       : Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               );
  //             }),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // static Widget _buildPortfolioCard({
  //   required BuildContext context,
  //   required String title,
  //   required PortfolioModel? portfolio,
  //   required Color gradientColor,
  //   required bool isCombined,
  //   required bool isPortfolioVisible,
  //   required bool showShimmer,
  //   required String Function(dynamic) safeCurrencyFormat,
  //   required VoidCallback onVisibilityToggle,
  // }) {
  //   final bool isProfit = (portfolio?.profitLoss ?? 0) >= 0;
  //   final bool shouldShowShimmer = showShimmer &&
  //       (portfolio == null ||
  //           portfolio.investedValue == null ||
  //           portfolio.currentValue == null ||
  //           portfolio.profitLoss == null ||
  //           portfolio.profitLossPercentage == null);
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     width: double.infinity,
  //     child: Stack(
  //       children: [
  //         Stack(
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: title == "Stock Portfolio"
  //                     ? AppColor().portfolio
  //                     : title == "Fund Portfolio"
  //                         ? AppColor().portfolio
  //                         : isCombined
  //                             ? AppColor().portfolio
  //                             : gradientColor,
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               height: MediaQuery.of(context).size.height * 0.25,
  //             ),
  //             if (title == "My Wallet")
  //               Positioned(
  //                 bottom: 0,
  //                 left: 0,
  //                 right: 0,
  //                 child: Container(
  //                   height: 50,
  //                   decoration: BoxDecoration(
  //                     color: AppColor().cardBottom,
  //                     borderRadius: const BorderRadius.only(
  //                       bottomLeft: Radius.circular(15),
  //                       bottomRight: Radius.circular(15),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             if (title == "My Portfolio")
  //               _buildProfitLossFooter(
  //                 portfolio: portfolio,
  //                 isProfit: isProfit,
  //                 isPortfolioVisible: isPortfolioVisible,
  //                 safeCurrencyFormat: safeCurrencyFormat,
  //                 showShimmer: shouldShowShimmer,
  //                 label: "Overall Profit/Loss",
  //               ),
  //             if (title == "Fund Portfolio")
  //               _buildProfitLossFooter(
  //                 portfolio: portfolio,
  //                 isProfit: isProfit,
  //                 isPortfolioVisible: isPortfolioVisible,
  //                 safeCurrencyFormat: safeCurrencyFormat,
  //                 showShimmer: shouldShowShimmer,
  //                 label: "Profit/Loss",
  //               ),
  //             if (title == "Stock Portfolio")
  //               _buildProfitLossFooter(
  //                 portfolio: portfolio,
  //                 isProfit: isProfit,
  //                 isPortfolioVisible: isPortfolioVisible,
  //                 safeCurrencyFormat: safeCurrencyFormat,
  //                 showShimmer: shouldShowShimmer,
  //                 label: "Profit/Loss",
  //               ),
  //           ],
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(10),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     title,
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   if (title == "My Wallet")
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 12),
  //                       child: SvgPicture.asset(
  //                         "assets/images/Logo_left_with_name.svg",
  //                         height: 28,
  //                         color: AppColor().constant,
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //               const SizedBox(height: 6),
  //               Container(
  //                 height: 1,
  //                 width: double.infinity,
  //                 color: Colors.white.withOpacity(0.5),
  //               ),
  //               const SizedBox(height: 8),
  //               if (portfolio != null || !shouldShowShimmer)
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: _buildPortfolioCardData(
  //                         portfolio: portfolio,
  //                         isCombined: title == "My Wallet",
  //                         showShimmer: shouldShowShimmer,
  //                         isPortfolioVisible: isPortfolioVisible,
  //                         safeCurrencyFormat: safeCurrencyFormat,
  //                       ),
  //                     ),
  //                     if (title == "My Wallet")
  //                       InkWell(
  //                         onTap: onVisibilityToggle,
  //                         child: Padding(
  //                           padding: const EdgeInsets.only(right: 10),
  //                           child: Icon(
  //                             isPortfolioVisible
  //                                 ? Icons.visibility
  //                                 : Icons.visibility_off,
  //                             color: Colors.white,
  //                             size: 40,
  //                           ),
  //                         ),
  //                       ),
  //                   ],
  //                 )
  //               else
  //                 _buildPortfolioDataShimmer(),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // static Widget _buildProfitLossFooter({
  //   required PortfolioModel? portfolio,
  //   required bool isProfit,
  //   required bool isPortfolioVisible,
  //   required String Function(dynamic) safeCurrencyFormat,
  //   required bool showShimmer,
  //   required String label,
  // }) {
  //   return Positioned(
  //     bottom: 0,
  //     left: 0,
  //     right: 0,
  //     child: Container(
  //       height: 50,
  //       decoration: BoxDecoration(
  //         color: AppColor().cardBottom,
  //         borderRadius: const BorderRadius.only(
  //           bottomLeft: Radius.circular(15),
  //           bottomRight: Radius.circular(15),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           Text(
  //             label,
  //             style: const TextStyle(
  //               color: Colors.white,
  //               fontSize: 14,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //           const SizedBox(width: 30),
  //           Row(
  //             children: [
  //               if (isPortfolioVisible)
  //                 Icon(
  //                   isProfit ? Icons.add : Icons.remove,
  //                   color: isProfit ? Colors.greenAccent : Colors.redAccent,
  //                   size: 14,
  //                 ),
  //               const SizedBox(width: 4),
  //               Text(
  //                 isPortfolioVisible
  //                     ? "${isProfit ? '' : ''}${safeCurrencyFormat((portfolio?.profitLoss ?? 0).abs())}"
  //                     : " ********************",
  //                 style: TextStyle(
  //                   color: isProfit ? Colors.greenAccent : Colors.redAccent,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               const SizedBox(width: 4),
  //               if (isPortfolioVisible)
  //                 Container(
  //                   padding:
  //                       const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                   decoration: BoxDecoration(
  //                     color: isProfit
  //                         ? Colors.greenAccent.withAlpha(20)
  //                         : Colors.redAccent.withAlpha(20),
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                   child: portfolio?.profitLossPercentage != null
  //                       ? Text(
  //                           "${isProfit ? '' : ''}${(portfolio?.profitLossPercentage)} %",
  //                           style: TextStyle(
  //                             color: isProfit
  //                                 ? Colors.greenAccent
  //                                 : Colors.redAccent,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         )
  //                       : Shimmer.fromColors(
  //                           baseColor: Colors.grey[300]!,
  //                           highlightColor: Colors.grey[100]!,
  //                           period: const Duration(seconds: 2),
  //                           child: Container(
  //                             width: 40,
  //                             height: 14,
  //                             decoration: BoxDecoration(
  //                               color: Colors.grey[300],
  //                               borderRadius: BorderRadius.circular(4),
  //                             ),
  //                           ),
  //                         ),
  //                 )
  //               else
  //                 Text(
  //                   " **",
  //                   style: TextStyle(
  //                     color: isProfit ? Colors.greenAccent : Colors.redAccent,
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // static Widget _buildPortfolioCardData({
  //   required PortfolioModel? portfolio,
  //   required bool isCombined,
  //   required bool showShimmer,
  //   required bool isPortfolioVisible,
  //   required String Function(dynamic) safeCurrencyFormat,
  // }) {
  //   T fallbackZero<T>(T? value, T zero) =>
  //       showShimmer ? (value ?? zero) : (value ?? zero);
  //
  //   if (isCombined) {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Text(
  //               "Trading Balance",
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(0.9),
  //                 fontSize: 18,
  //               ),
  //             ),
  //             const SizedBox(width: 4),
  //             Text(
  //               "(TZS)",
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(0.7),
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 4),
  //         Row(
  //           children: [
  //             Text(
  //               isPortfolioVisible
  //                   ? safeCurrencyFormat(fallbackZero(portfolio?.wallet, 0.0))
  //                   : "************",
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 35,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     );
  //   }
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "Invested Value",
  //                       style: TextStyle(
  //                         color: Colors.white.withOpacity(0.9),
  //                         fontSize: 18,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Text(
  //                       "(TZS)",
  //                       style: TextStyle(
  //                         color: Colors.white.withOpacity(0.7),
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   isPortfolioVisible
  //                       ? safeCurrencyFormat(
  //                           fallbackZero(portfolio?.investedValue, 0.0))
  //                       : " ****",
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Container(
  //             width: 1,
  //             height: 80,
  //             color: Colors.white.withOpacity(0.5),
  //             margin: const EdgeInsets.symmetric(horizontal: 8),
  //           ),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "Current Value",
  //                       style: TextStyle(
  //                         color: Colors.white.withOpacity(0.9),
  //                         fontSize: 18,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Text(
  //                       "(TZS)",
  //                       style: TextStyle(
  //                         color: Colors.white.withOpacity(0.7),
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 6),
  //                 Text(
  //                   isPortfolioVisible
  //                       ? safeCurrencyFormat(
  //                           fallbackZero(portfolio?.currentValue, 0.0))
  //                       : " ****",
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  //
  // static Widget _buildPortfolioDataShimmer() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         width: 100,
  //         height: 16,
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.3),
  //           borderRadius: BorderRadius.circular(4),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         width: 150,
  //         height: 24,
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.3),
  //           borderRadius: BorderRadius.circular(4),
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                 width: 80,
  //                 height: 12,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.3),
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Container(
  //                 width: 100,
  //                 height: 18,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.3),
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               Container(
  //                 width: 80,
  //                 height: 12,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.3),
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Container(
  //                 width: 120,
  //                 height: 18,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.3),
  //                   borderRadius: BorderRadius.circular(4),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  //
}
