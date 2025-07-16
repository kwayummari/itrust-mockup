import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwealth/User/providers/metadata.dart';
import 'package:iwealth/screens/user/account_settings.dart';
import 'package:iwealth/constants/app_color.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/screens/user/profile_image_widget.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/http_client.dart';
import 'package:iwealth/services/stocks/apis_request.dart';
import 'package:iwealth/stocks/models/portfolio.dart';
import 'package:iwealth/stocks/services/pull_metadata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_status_card.dart';

import 'home_screen_status_banner.dart';
import 'home_screen_portfolio_widgets.dart';
import 'home_screen_investment_widgets.dart';

class HomeScreen extends StatefulWidget {
  final String? updated;
  const HomeScreen({super.key, this.updated});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  String balance = "45,678";
  bool isVisible = false;
  bool rotate = false;
  // final bool _showFunds = true;
  late PageController _pageController;
  late MetadataProvider metadataProvider;
  final currFormat = NumberFormat("#,##0.00", "en_US");

  Timer? _profileRefreshTimer;
  bool _isRefreshing = false;

  bool _isLoadingVideos = false;

  bool _isPortfolioVisible = false;

  String _selectedInvestmentType = 'funds';

  bool _hasSubscriptions = false;
  bool _hasOrders = false;

  bool _isRefreshDebounced = false;

  bool _showShimmer = true;

  late AnimationController _statusBannerController;
  late Animation<double> _statusBannerAnimation;
  bool _isStatusBannerVisible = false;

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:
                Text('Exit App', style: TextStyle(color: AppColor().textColor)),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    metadataProvider = Provider.of<MetadataProvider>(context, listen: false);

    // Add lifecycle observer to detect app state changes
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_onPageChanged);

    _statusBannerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _statusBannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statusBannerController,
      curve: Curves.easeInOut,
    ));

    // Initialize everything
    _initializeApp();

    _setupProfileRefresh();
    _checkSubscriptionsAndOrders();

    // Reduce shimmer delay for faster perceived loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
  }

// Add this new method
  Future<void> _initializeApp() async {
    await Future.delayed(Duration.zero); // Ensure widget is built

    final mp = Provider.of<MarketProvider>(context, listen: false);

    if (kDebugMode) {
      print('🚀 Initializing app...');
    }

    // Load market data first (always runs)
    await _loadAllMarketData(mp);

    // Then load initial data (profile-dependent)
    await _loadInitialData();
    _checkAndShowStatusBanner();
  }

  @override
  void dispose() {
    _profileRefreshTimer?.cancel();
    _statusBannerController.dispose();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Clear portfolio cache when app resumes to ensure fresh data
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('🔄 App resumed - clearing portfolio cache for fresh data');
      }
      HttpClientService.clearAllPortfolioCache();

      // Refresh portfolio data if profile is complete
      if (_isProfileComplete() && mounted) {
        _loadInitialData();
      }
    }
  }

  void _onPageChanged() {
    if (_pageController.hasClients) {
      setState(() {});
    }
  }

  void _checkAndShowStatusBanner() {
    StatusBannerHelper.checkAndShowStatusBanner(
      context: context,
      mounted: mounted,
      showStatusBanner: _showStatusBanner,
      hideStatusBanner: _hideStatusBanner,
      updated: widget.updated == 'submitted' ? 'submitted' : '',
    );
  }

  void _showStatusBanner() {
    StatusBannerHelper.showStatusBanner(
      mounted: mounted,
      isStatusBannerVisible: _isStatusBannerVisible,
      setState: setState,
      statusBannerController: _statusBannerController,
      setStatusBannerVisible: (visible) => _isStatusBannerVisible = visible,
    );
  }

  void _hideStatusBanner() {
    StatusBannerHelper.hideStatusBanner(
      mounted: mounted,
      isStatusBannerVisible: _isStatusBannerVisible,
      statusBannerController: _statusBannerController,
      setState: setState,
      setStatusBannerVisible: (visible) => _isStatusBannerVisible = visible,
    );
  }

  Future<void> _checkSubscriptionsAndOrders() async {
    final mp = Provider.of<MarketProvider>(context, listen: false);

    // Check subscriptions and orders in parallel, non-blocking
    Future.wait<dynamic>([
      StockWaiter().getFundOrderDetails(fundCode: '', mp: mp, context: context),
      StockWaiter().getOrders(mp),
    ]).then((results) {
      if (!mounted) return;

      var subscriptions = results[0];
      if (subscriptions['status'] == 'success' &&
          subscriptions['data'].isNotEmpty) {
        setState(() {
          _hasSubscriptions = true;
        });
      }

      var orders = results[1];
      if (orders == "1" && mp.order.isNotEmpty) {
        setState(() {
          _hasOrders = true;
        });
      }
    }).catchError((e) {
      if (kDebugMode) {
        print("Error checking subscriptions/orders: $e");
      }
    });
  }

  void _setupProfileRefresh() {
    if (!_isProfileComplete()) {
      _profileRefreshTimer =
          Timer.periodic(const Duration(seconds: 30), (timer) {
        _refreshUserProfile();
      });
    }
  }

  Future<void> _refreshUserProfile() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    try {
      SessionPref.getUserProfile();

      if (_isProfileComplete()) {
        _profileRefreshTimer?.cancel();
        _hideStatusBanner();
      } else {
        _checkAndShowStatusBanner();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing profile: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> onManualRefresh() async {
    if (_isRefreshDebounced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait before refreshing again.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _isRefreshDebounced = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing portfolio data...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Clear all portfolio cache for fresh data
    HttpClientService.clearAllPortfolioCache();

    await _refreshUserProfile();
    if (_isProfileComplete()) {
      Provider.of<MarketProvider>(context, listen: false);
      await _loadInitialData();
    }

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isRefreshDebounced = false;
        });
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final mp = Provider.of<MarketProvider>(context, listen: false);

    // ALWAYS load market data first, regardless of profile status
    // await _loadAllMarketData(mp);

    var userProfile = SessionPref.getUserProfile();
    if (userProfile == null || userProfile.length < 6) {
      // Only set empty portfolio, market data already loaded above
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mp.setFundPortfolio({
            'investedValue': '0',
            'currentValue': '0',
            'profitLoss': '0',
            'profitLossPercentage': '0'
          });
        }
      });
      return; // Return after setting portfolio, but market data is already loaded
    }

    if (userProfile[6] == "pending") {
      // Only set empty portfolio, market data already loaded above
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          mp.setFundPortfolio({
            'investedValue': '0',
            'currentValue': '0',
            'profitLoss': '0',
            'profitLossPercentage': '0'
          });
        }
      });
      return; // Return after setting portfolio, but market data is already loaded
    }

    try {
      // Clear all portfolio cache to ensure fresh data
      HttpClientService.clearAllPortfolioCache();

      // Store current portfolio data as fallback in case API calls fail
      final currentPortfolio = mp.portfolio;
      final currentFundPortfolio = mp.fundPortfolio;
      final currentBondPortfolio = mp.bondPortfolio;

      // Load all portfolio data in parallel for faster startup
      await Future.wait<dynamic>([
        StockWaiter().getMyPortfolio(mp: mp, context: context),
        StockWaiter().getMyFundPortfolio(mp: mp, context: context),
        StockWaiter().fundPortfolio(context: context, mp: mp),
        StockWaiter().getPortfolio(provider: mp, context: context),
        StockWaiter().getBondPortfolio(mp: mp),
      ]);

      // If fund portfolio failed to load but we had previous data, restore it
      if (mp.fundPortfolio == null && currentFundPortfolio != null) {
        if (kDebugMode) {
          print("Fund portfolio API failed, keeping previous data");
        }
        mp.fundPortfolio = currentFundPortfolio;
      }

      // var combinedData = await StockWaiter().getCombinedPortfolio(
      //   mp: mp,
      //   context: context,
      // );
      // final combinedData = await StockWaiter().getMyPortfolio(
      //   context: context,
      //   mp: mp,
      // );

      // print('====== getMyCombined Portfolio Data: $combinedData');

      // if (mounted && combinedData.isNotEmpty) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (mounted) {
      //       print('====== getMyCombined Portfolio Data: $combinedData');

      // mp.combinedPortfolio = PortfolioModel(
      //   investedValue: combinedData['investedValue'],
      //   currentValue: combinedData['currentValue'],
      //   wallet: combinedData['wallet'],
      //   profitLoss: combinedData['profitLoss'],
      //   profitLossPercentage:
      //       combinedData['profitLossPercentage']?.toString(),
      //   stockID: '',
      //   stockName: '',
      //   qnty: '',
      //   avgPrice: '',
      //   closePrice: '',
      //   changeAmount: '',
      //   changePercentage: '',
      // );
      //   }
      // });
      // }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading initial portfolio data: $e");
      }
    }
  }

  // In your home screen _loadAllMarketData method:
  Future<void> _loadAllMarketData(MarketProvider mp) async {
    try {
      if (kDebugMode) {
        print('🚀 Starting to load market data...');
        print(
            'Before loading - Funds: ${mp.fund.length}, Stocks: ${mp.stock?.length ?? 0}, Bonds: ${mp.bonds.length}');
      }

      final marketDataWaiter = StockWaiter.forMarketData();

      await Future.wait([
        marketDataWaiter.fundListForAll(mp: mp, context: context),
        marketDataWaiter.getBondsForAll(mp: mp, context: context),
        marketDataWaiter.getStocksForAll(mp: mp, context: context),
      ]);

      if (kDebugMode) {
        print('✅ Market data loading completed');
        print(
            'After loading - Funds: ${mp.fund.length}, Stocks: ${mp.stock?.length ?? 0}, Bonds: ${mp.bonds.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading market data: $e');
      }
    }
  }

  String safeCurrencyFormat(dynamic value) {
    if (value == null) return "0.00";
    try {
      if (value is String) {
        value = double.tryParse(value) ?? 0.0;
      }
      return currFormat.format(value);
    } catch (e) {
      if (kDebugMode) {
        print("Error formatting currency: $e");
      }
      return "0.00";
    }
  }

  bool _isProfileComplete() {
    final status = SessionPref.getUserProfile()![6];
    final kycStatus = SessionPref.getUserProfile()![7];
    return status == "finished" && kycStatus == "active";
  }

  ProfileStatus _getProfileStatus() {
    final status = SessionPref.getUserProfile()![6];
    final kycStatus = SessionPref.getUserProfile()![7];

    if (widget.updated == 'submitted') {
      return ProfileStatus.submitted;
    } else if (status == "pending") {
      return ProfileStatus.pending;
    } else if (status == "submitted" ||
        kycStatus == "pending" ||
        widget.updated == 'submitted') {
      return ProfileStatus.submitted;
    } else if (status == "finished" && kycStatus == "active") {
      return ProfileStatus.active;
    }
    return ProfileStatus.unknown;
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);
    final mp = Provider.of<MarketProvider>(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding;

    final availableHeight = screenHeight - safePadding.top - safePadding.bottom;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: SvgPicture.asset(
            "assets/images/Logo_left_with_name_black.svg",
            height: 22,
          ),
          leading: GestureDetector(
            child: const ProfileImageWidget(
              photo: '',
              // photo: SessionPref.getNIDA()?[14] ?? '',
              height: 36,
              width: 36,
              radius: 20,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountAndSettings(),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notification_add,
                color: AppColor().blueBTN,
              ),
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: onManualRefresh,
                child: Column(
                  // padding: EdgeInsets.zero,
                  // physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (_isStatusBannerVisible)
                      StatusBannerHelper.buildStatusBanner(
                        context: context,
                        statusBannerAnimation: _statusBannerAnimation,
                        rotate: rotate,
                        metadataProvider: metadataProvider,
                        onCompletePressed: () async {
                          setState(() => rotate = true);

                          bool success = await PullMetadata()
                              .nidabtnPressed(metadataProvider, context);

                          setState(() => rotate = false);

                          if (success) {
                            // Handle success case if needed
                            print("Metadata pull completed successfully");
                          } else {
                            // Handle failure case if needed
                            print("Metadata pull failed");
                          }
                        },
                        onClosePressed: _hideStatusBanner,
                        updated:
                            widget.updated == 'submitted' ? 'submitted' : '',
                      ),

                    if (SessionPref.getUserProfile()![6] == "finished" &&
                        SessionPref.getUserProfile()![7] == "active")
                      PortfolioWidgets.buildPortfolioOverview(
                        context: context,
                        marketProvider: marketProvider,
                        pageController: _pageController,
                        isPortfolioVisible: _isPortfolioVisible,
                        showShimmer: _showShimmer,
                        safeCurrencyFormat: safeCurrencyFormat,
                        onVisibilityToggle: () {
                          setState(() {
                            _isPortfolioVisible = !_isPortfolioVisible;
                          });
                        },
                      ),
                    SizedBox(height: availableHeight * 0.01),

                    InvestmentWidgets.buildInvestmentSection(
                      context: context,
                      marketProvider: marketProvider,
                      selectedInvestmentType: _selectedInvestmentType,
                      onInvestmentTypeChanged: (type) {
                        setState(() {
                          _selectedInvestmentType = type;
                        });
                      },
                    ),
                    // if (_showFunds)
                    Column(
                      children: [
                        _selectedInvestmentType == 'funds'
                            ? InvestmentWidgets.buildFundsGrid(
                                context: context, mp: mp)
                            : _selectedInvestmentType == 'stocks'
                                ? InvestmentWidgets.buildStocksGrid(
                                    context: context, mp: mp)
                                : InvestmentWidgets.buildBondsGrid(
                                    context: context, mp: mp),
                      ],
                    ),
                    // InvestmentWidgets.buildActionButton(
                    //   context: context,
                    //   marketProvider: marketProvider,
                    //   selectedInvestmentType: _selectedInvestmentType,
                    //   hasSubscriptions: _hasSubscriptions,
                    //   hasOrders: _hasOrders,
                    //   getProfileStatus: _getProfileStatus,
                    // ),
                    // SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
