import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/stocks/models/stock.model.dart';
import 'package:iwealth/stocks/screen/stockdetails.dart';
import 'package:provider/provider.dart';

class AllStockScreen extends StatefulWidget {
  const AllStockScreen({super.key});

  @override
  State<AllStockScreen> createState() => _AllStockScreenState();
}

class _AllStockScreenState extends State<AllStockScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
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

    final filteredStocks = marketProvider.stock
        ?.where((stock) =>
            stock.name!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Stocks List
        Expanded(
          child: filteredStocks == null || filteredStocks.isEmpty
              ? _buildEmptyState()
              : _buildStocksList(filteredStocks, appWidth, marketProvider),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(
            'No stocks found for "$searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
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
              style: TextStyle(color: AppColor().blueBTN),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStocksList(List<Stock> filteredStocks, double appWidth,
      MarketProvider marketProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filteredStocks.length,
      itemBuilder: (context, i) {
        final stock = filteredStocks[i];
        final bool isPositiveChange =
            double.tryParse(stock.changePercentage ?? '0')?.isNegative == false;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
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
                  highOrNAVLabel: "High Price",
                  lowPrice: stock.lowPrice,
                  lowOrInitLabel: "Low Price",
                  mcap: stock.marketCap,
                  mcapOrEntryLabel: "Market Capital( In Billions )",
                  volume: stock.volume,
                  volOrLaunchLabel: "Volume",
                  screen: "stock",
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor().blueBTN.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/tickerLogo/${stock.name}.jpg",
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stock.name ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stock.fullname ?? '',
                                style: TextStyle(
                                  color: AppColor().grayText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12),
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      height: 0,
                    ),
                  ),
                  // Titles outside the colored background
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Price",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Change",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom section: price left, change right, light blue background
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F0FB),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    child: Row(
                      children: [
                        // Price column (left)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              "TZS ${stock.price}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor().blueBTN,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        // Change column (right)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${isPositiveChange ? '+' : ''}${stock.changeAmount}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPositiveChange
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "(${isPositiveChange ? '+' : ''}${stock.changePercentage}%)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPositiveChange
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
