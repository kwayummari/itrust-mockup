import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/fund/fundorder_form.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/screens/stocks/orders/product_details_widgets.dart';
import 'package:iwealth/screens/stocks/orders/products_ticker.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/stocks/models/portfolio.dart';
import 'package:iwealth/stocks/screen/buy_stock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iwealth/widgets/app_snackbar.dart';
import 'package:iwealth/widgets/tabbar_widget.dart';
import 'package:provider/provider.dart';

class StockDetailScreen extends StatefulWidget {
  final String? logo;
  final String? companyName;
  final String? tickerSymbol;
  final String? price;
  final String? change;
  final String? changeAmount;
  final String? stockID;
  final String? volume;
  final String? volOrLaunchLabel;
  final String? mcap;
  final String? mcapOrEntryLabel;
  final String? screen;
  final String? lowPrice;
  final String? lowOrInitLabel;
  final String? highPrice;
  final String? highOrNAVLabel;

  const StockDetailScreen({
    super.key,
    this.companyName,
    this.logo = 'assets/images/ic_launcher.png',
    this.tickerSymbol,
    this.change = '0',
    this.price = '0',
    this.changeAmount = '0',
    this.stockID = '',
    this.highPrice = '0',
    this.lowPrice = '0',
    this.mcap = '0',
    this.volume = '0',
    this.highOrNAVLabel = 'High Price',
    this.lowOrInitLabel = 'Low Price',
    this.mcapOrEntryLabel = 'Market Cap',
    this.volOrLaunchLabel = 'Volume',
    this.screen = 'stock',
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  bool rotate = false;
  int qnty = 0;
  final currFormat = NumberFormat("#,##0.00", "en_US");
  late TabController _tabController;

  final tabs = [
    "Overview",
    "Performance",
    "About",
  ];

  String leftLabel = '';
  String rightLabel = '';
  String leftValue = '';
  String rightValue = '';
  String leftSymbol = '';
  String rightSymbol = '';
  double profitLoss = 0.0;
  List<ProductsTickerItem> products = [];
  List<Widget> overviewRows = [];
  List<Widget> fundAccountRows = [];
  String description = '';
  List<Widget> aboutRows = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isProfileComplete() {
    final status = SessionPref.getUserProfile()![6];
    final kycStatus = SessionPref.getUserProfile()![7];
    return status == "finished" && kycStatus == "active";
  }

  void _showFundActionDialog(
      BuildContext context, String fundName, String shareClassCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final marketProvider = Provider.of<MarketProvider>(context);
        final fund = marketProvider.fund.firstWhere(
          (fund) => fund.shareClassCode == shareClassCode,
        );
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: screenSize.height * 0.02,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenSize.width * 0.92,
              maxHeight: screenSize.height * 0.85,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FundOrderForm(
                fundName: fundName,
                chareClass: shareClassCode,
                isSubscripiton: true,
                isDialog: true,
                initialMinContribution: fund.initialMinContribution,
                subsequentAmount: fund.subsequentAmount,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    _generateProductDetailsData(marketProvider);

    try {
      // Try to find the stock by ticker symbol and retrieve its quantity
      qnty = int.parse(marketProvider.eachStockPortfolio
          .firstWhere((stock) => stock.stockName == widget.tickerSymbol)
          .qnty
          .toString());
      print("Quantity for ${widget.tickerSymbol}: $qnty");
    } catch (e) {
      print("Exception on Qnty Calculation: due to: $e");
      qnty = 0; // Ensure qnty is set to a fallback value if an exception occurs
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ProductsTicker(
          products: products,
        ),
        leadingWidth: 40,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Background
            ProductDetailsWidgets.buildProductHeader(
              logoUrl: widget.logo ?? '',
              title: widget.tickerSymbol ?? '',
              subtitle: widget.companyName ?? '',
              profitLoss: profitLoss,
            ),
            ProductDetailsWidgets.buildProductValueItem(
              context: context,
              leftLabel: leftLabel,
              leftValue: leftValue,
              leftSymbol: leftSymbol,
              rightLabel: rightLabel,
              rightValue: rightValue,
              rightSymbol: rightSymbol,
            ),
            TabBarWidget(
              context: context,
              tabs: tabs,
              tabController: _tabController,
            ),
            const SizedBox(height: 8),
            // Main Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(marketProvider),
                  _buildPerformanceTab(),
                  _buildAboutTab(marketProvider),
                ],
              ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: widget.screen == "stock"
                  ? _buildStockActions(marketProvider)
                  : _buildFundAction(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    MarketProvider marketProvider,
  ) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      children: [
        _buildInfoCard(overviewRows),
        const SizedBox(height: 16),
        if (fundAccountRows.isNotEmpty) _buildInfoCard(fundAccountRows),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    return const Center(child: Text("Performance data coming soon"));
  }

  Widget _buildAboutTab(MarketProvider marketProvider) {
    if (widget.screen == "stock") {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _buildInfoCard(
          [
            _buildStatItem(
              "Company Name",
              widget.companyName ?? "",
              isDescription: true,
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              "Symbol",
              widget.tickerSymbol ?? "",
              isDescription: false,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            [
              _buildStatItem(
                "Description",
                description,
                isDescription: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (aboutRows.isNotEmpty) _buildInfoCard(aboutRows),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor().lowerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildStatItem(String label, String value,
      {bool isDescription = false}) {
    if (isDescription) {
      return Text(
        value,
        style: const TextStyle(
            color: Color.fromRGBO(86, 86, 86, 1),
            height: 1.5,
            fontSize: 15,
            fontWeight: FontWeight.w400),
        textAlign: TextAlign.justify,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        value,
        style: TextStyle(
          color: AppColor().textColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildStockActions(MarketProvider marketProvider) {
    final bool isComplete = _isProfileComplete();
    return Row(
      children: [
        if (marketProvider.tickerIOwn.contains(widget.tickerSymbol))
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isComplete ? AppColor().blueBTN : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isComplete
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyStockScreen(
                            qnty: qnty,
                            changeAmount: "${widget.changeAmount}",
                            changePercentage: "${widget.change}",
                            price: "${widget.price}",
                            tickerSymbol: "${widget.tickerSymbol}",
                            btnTxt: "Confirm Sell Order",
                            btnColor: AppColor().orangeApp,
                            stockID: "${widget.stockID}",
                            orderType: "sell",
                            logoUrl: widget.logo ?? '',
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text(
                "Sell",
                style: TextStyle(
                  fontSize: 16,
                  color: isComplete ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        if (marketProvider.tickerIOwn.contains(widget.tickerSymbol))
          const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isComplete ? AppColor().orangeApp : Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isComplete
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyStockScreen(
                          qnty: 10,
                          changeAmount: "${widget.changeAmount}",
                          changePercentage: "${widget.change}",
                          price: "${widget.price}",
                          tickerSymbol: "${widget.tickerSymbol}",
                          btnTxt: "Confirm Buy Order",
                          btnColor: AppColor().blueBTN,
                          stockID: "${widget.stockID}",
                          orderType: "buy",
                          logoUrl: widget.logo ?? '',
                        ),
                      ),
                    );
                  }
                : null,
            child: Text(
              "Buy",
              style: TextStyle(
                fontSize: 16,
                color: isComplete ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFundAction(BuildContext context) {
    final bool isComplete = _isProfileComplete();
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isComplete ? AppColor().blueBTN : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: isComplete
          ? () => _showFundActionDialog(
                context,
                widget.tickerSymbol.toString(),
                widget.stockID.toString(),
              )
          : () {
              AppSnackbar(
                isError: true,
                response:
                    "Please complete your profile to start investing in funds.",
              ).show(context);
            },
      child: Text(
        "Invest Now",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isComplete ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  void _generateProductDetailsData(MarketProvider mp) {
    if (widget.screen == 'fund') {
      //add portfolio data
      final portfolio = mp.eachFundPortfolio.firstWhere(
        (portfolio) => portfolio.stockID == widget.stockID,
        orElse: () => PortfolioModel(
            stockID: widget.stockID ?? '',
            stockName: widget.tickerSymbol ?? '',
            investedValue: 0.0,
            currentValue: 0.0,
            qnty: '0',
            profitLoss: 0,
            profitLossPercentage: '0'),
      );
      overviewRows = [
        ProductDetailsWidgets.buildOverviewRowItem(
          label: 'Amount invested',
          value: currFormat.format(portfolio.investedValue),
          symbol: 'TZS',
        ),
        ProductDetailsWidgets.buildOverviewRowItem(
          label: 'Current Value',
          value: currFormat.format(portfolio.currentValue),
          symbol: 'TZS',
        ),
        ProductDetailsWidgets.buildOverviewRowItem(
            label: 'My Units',
            value: portfolio.qnty ?? '0',
            symbol: '',
            hideBorder: true),
      ];
//add fund data

      mp.fund.forEach((fund) {
        double navCalculated = ((double.parse(fund.nav) - 100) / 100) * 100;
        if (fund.shareClassCode == widget.stockID) {
          leftValue =
              currFormat.format(double.parse(fund.initialMinContribution));
          rightValue = double.parse(fund.nav).toStringAsFixed(4);
          leftLabel = 'Min. Investment';
          rightLabel = 'Net Asset Value';
          leftSymbol = 'TZS';
          rightSymbol = 'NAV';
          profitLoss = navCalculated;
          description = fund.description;

          aboutRows = [
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Minimum investment',
              value: leftValue,
              symbol: 'TZS',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Minimum additional investment',
              value: currFormat.format(double.parse(fund.subsequentAmount)),
              symbol: 'TZS',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Entry Fee',
              value: fund.entryFee,
              symbol: '',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Exit Fee',
              value: fund.exitFee,
              symbol: '',
            ),
          ];

          final subscriptions = SessionPref.getUserSubscriptions();
          if (subscriptions != null && subscriptions.isNotEmpty) {
            final fundSubs = subscriptions.firstWhere(
              (sub) => sub['fundId'] == widget.stockID,
              orElse: () => subscriptions.isNotEmpty ? subscriptions[0] : null,
            );
            fundAccountRows = [
              ProductDetailsWidgets.buildFundAccountRow(
                  context: context, label: 'Bank Name', value: fund.bankName),
              ProductDetailsWidgets.buildFundAccountRow(
                  context: context,
                  label: 'Account Number',
                  value: fund.accountNumber,
                  isReference: true),
              ProductDetailsWidgets.buildFundAccountRow(
                  context: context,
                  label: 'Control Number',
                  value: fundSubs?['client_code'] ?? 'N/A',
                  isReference: true),
            ];
          }
        }
        products.add(
          ProductsTickerItem(
            name: fund.name,
            price: double.parse(fund.nav),
            change: navCalculated,
          ),
        );
      });
    }
    if (widget.screen == 'stock') {
      final portfolio = mp.eachStockPortfolio.firstWhere(
        (portfolio) => portfolio.stockID == widget.stockID,
        orElse: () => PortfolioModel(
            stockID: '',
            stockName: '',
            investedValue: 0.0,
            currentValue: 0.0,
            qnty: '0',
            profitLoss: 0,
            profitLossPercentage: '0'),
      );

      mp.stock?.forEach((stock) {
        if (stock.stockID == widget.stockID) {
          leftValue = double.parse(stock.closePrice ?? '0').toStringAsFixed(2);
          rightValue = currFormat.format(double.parse(stock.marketCap ?? '0'));
          leftLabel = 'Closing Price';
          rightLabel = 'Market Cap';
          leftSymbol = 'TZS';
          rightSymbol = 'TZS`B';
          profitLoss = double.parse(stock.changePercentage ?? '0');
          description = stock.description ?? '';

          overviewRows = [
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'My Shares',
              value: currFormat.format(portfolio.investedValue),
              symbol: '',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'High',
              value: currFormat.format(double.parse(stock.highPrice ?? '0')),
              symbol: 'TZS',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Low',
              value: currFormat.format(double.parse(stock.lowPrice ?? '0')),
              symbol: 'TZS',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
                label: 'Today’s Change',
                value: currFormat
                    .format(double.parse(portfolio.changeAmount ?? '0')),
                symbol: 'TZS',
                hideBorder: true),
          ];
        }
        products.add(
          ProductsTickerItem(
            name: stock.name ?? '',
            price: double.parse(stock.price ?? '0'),
            change: double.parse(stock.changePercentage ?? '0'),
          ),
        );
      });
    }

    if (widget.screen == 'bond') {
      final portfolio = mp.eachStockPortfolio.firstWhere(
        (portfolio) => portfolio.stockID == widget.stockID,
        orElse: () => PortfolioModel(
            stockID: '',
            stockName: '',
            investedValue: 0.0,
            currentValue: 0.0,
            qnty: '0',
            profitLoss: 0,
            profitLossPercentage: '0'),
      );
      mp.bonds.forEach((bond) {
        if (bond.id == widget.stockID) {
          rightValue = currFormat.format(bond.issuedAmount);
          leftValue = bond.price.toStringAsFixed(4);
          rightLabel = 'Issued Amount';
          leftLabel = 'Price';
          leftSymbol = 'TZS';
          rightSymbol = 'TZS`B';
          profitLoss = bond.coupon;

          overviewRows = [
            ProductDetailsWidgets.buildOverviewRowItem(
              label: '${bond.market.name} Market',
              value: '',
              symbol: '',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Invested Amount',
              value: currFormat.format(portfolio.investedValue),
              symbol: 'TZS',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Issue Date',
              value: '${bond.issueDate}',
              symbol: '',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Maturity Date',
              value: '${bond.maturityDate}',
              symbol: '',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Yield to Maturity',
              value: '${bond.yieldToMaturity.toStringAsFixed(2)}%',
              symbol: '',
            ),
            ProductDetailsWidgets.buildOverviewRowItem(
              label: 'Tenure',
              value: '${bond.tenure}',
              symbol: 'Years',
              hideBorder: true,
            ),
          ];
        }
        products.add(
          ProductsTickerItem(
            name: bond.securityName ?? '',
            price: bond.price,
            change: bond.coupon,
          ),
        );
      });
    }
  }
}
