import 'dart:convert';
import 'dart:io';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:flutter/foundation.dart';
import 'package:iwealth/models/bonds/bond_order_cost_breakdown.dart';
import 'package:iwealth/models/fund/fund_model.dart';
import 'package:iwealth/models/fund/subscription.dart';
import 'package:iwealth/models/stocks/fee_model.dart';
import 'package:iwealth/models/stocks/statement.dart';
import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/auth/token_service.dart';
import 'package:iwealth/services/api_endpoints.dart';
import 'package:iwealth/services/http_client.dart';
import 'package:iwealth/services/error_handler.dart';
import 'package:iwealth/services/session/app_session.dart';
import 'package:iwealth/services/stocks/exceptions.dart';
import 'package:iwealth/stocks/models/bond_holdings_model.dart';
import 'package:iwealth/stocks/models/bond_model.dart';
import 'package:iwealth/stocks/models/bond_order_model.dart';
import 'package:iwealth/stocks/models/bond_orders_model.dart';
import 'package:iwealth/stocks/models/bond_portfolio_model.dart';
import 'package:iwealth/stocks/models/market_index.dart';
import 'package:iwealth/stocks/models/order.dart';
import 'package:iwealth/stocks/models/performance.dart';
import 'package:iwealth/stocks/models/portfolio.dart';
import 'package:iwealth/stocks/models/stock.model.dart';
import 'package:iwealth/stocks/models/stock_purchase_request.dart';
import 'package:iwealth/stocks/models/stock_purchase_response.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Quick fix: Simple cache for API responses
class SimpleCache {
  static final Map<String, CacheEntry> _cache = {};

  static CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry;
    }
    _cache.remove(key);
    return null;
  }

  static void set(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? Duration(minutes: 5),
    );
  }

  static void clear() {
    _cache.clear();
  }

  static void clearKey(String key) {
    _cache.remove(key);
  }

  static void clearFundRelatedCache() {
    _cache.removeWhere((key, value) =>
        key.contains('fund') ||
        key.contains('portfolio') ||
        key.contains('subscription'));
  }

  static void clearPurchasesCache() {
    _cache.removeWhere((key, value) =>
        key.contains('v2/innova/purchases') ||
        key.contains('innova/purchases'));
  }

  static void clearAfterFundPurchase() {
    // Clear only the specific caches that need to be updated after fund purchase
    _cache.removeWhere((key, value) =>
        key.contains('v2/innova/purchases') ||
        key.contains('innova/purchases') ||
        key.contains('fundPortfolio') ||
        key.contains('getSubscriptionList'));
  }

  static void clearAfterBondPurchase() {
    // Clear only the specific caches that need to be updated after bond purchase
    _cache.removeWhere((key, value) =>
        key.contains('trading/bonds/orders') ||
        key.contains('holdings/bonds') ||
        key.contains('holdings/portfolio-bond'));
  }

  static void clearAfterStockPurchase() {
    // Clear only the specific caches that need to be updated after stock purchase
    _cache.removeWhere((key, value) =>
        key.contains('trading/equities/orders') ||
        key.contains('holdings/equities') ||
        key.contains('holdings/portfolio-stock'));
  }
}

// Add this class to manage ongoing requests
class RequestManager {
  static void clearOngoingFundPortfolioRequest() {
    StockWaiter._ongoingFundPortfolioRequest = null;
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}

class StockWaiter {
  late String userId;

  StockWaiter() {
    _initializeUserId();
  }

  void _initializeUserId() {
    var userProfile = SessionPref.getUserProfile();
    if (userProfile != null && userProfile.length > 6) {
      if (userProfile[6] != "pending") {
        userId = base64.encode(utf8.encode(userProfile[5]));
      } else {
        userId = "";
      }
    } else {
      userId = "";
    }
  }

  void refreshUserId() {
    _initializeUserId();
  }

  // Add this new constructor for market data only
  StockWaiter.forMarketData() {
    _initializeUserIdForMarketData();
  }

  void _initializeUserIdForMarketData() {
    var userProfile = SessionPref.getUserProfile();
    if (userProfile != null && userProfile.length > 5) {
      userId = base64.encode(utf8.encode(userProfile[5]));
    } else {
      userId = ""; // Empty string for market data calls
    }
  }

// Add these helper methods that don't require complete profiles
  Future<String?> getStocksForAll(
      {required MarketProvider mp, required BuildContext context}) async {
    if (kDebugMode) {
      print('🔍 getStocksForAll called');
    }
    final result = await getStocks(mp: mp, context: context);
    if (kDebugMode) {
      print(
          '🔍 getStocksForAll result: $result, stocks count: ${mp.stock?.length ?? 0}');
    }
    return result;
  }

  Future<void> getBondsForAll(
      {required MarketProvider mp, required BuildContext context}) async {
    // Same as getBonds but doesn't check profile completion
    return await getBonds(mp: mp, context: context);
  }

  Future<String?> fundListForAll(
      {required MarketProvider mp, required BuildContext context}) async {
    // Same as fundList but doesn't check profile completion
    return await fundList(mp: mp, context: context);
  }

  static PortfolioModel? _portfolioCache;
  static List<PortfolioModel>? _eachStockPortfolioCache;
  static List<String>? _tickerIOwnCache;
  static bool _isFetchingPortfolio = false;

  bool _requiresCifNumber(String endpoint) {
    // List of endpoints that require flex_cif_number
    final restrictedEndpoints = [
      APIEndpoints.portfolioEndpoint,
      APIEndpoints.eachStockPortfolioEndpoint,
      APIEndpoints.fundPortfolio,
      APIEndpoints.fundBuyOrder,
      APIEndpoints.redemptionOrder,
      APIEndpoints.redemptionEndpoint,
      APIEndpoints.fundMobilePayment,
      APIEndpoints.azamPay,
      APIEndpoints.brokerageFundBuyOrder,
      APIEndpoints.brokeragePurchase,
      APIEndpoints.uploadProofEp,
      APIEndpoints.buyOrder,
      APIEndpoints.sellOrder,
      APIEndpoints.orderList,
      APIEndpoints.calculateBuy,
      APIEndpoints.bondBuy,
      APIEndpoints.fees,
      APIEndpoints.stockMobilePayment,
      APIEndpoints.stockProofPayment,
      APIEndpoints.bondProofPayment,
      APIEndpoints.bondMobilePayment,
      APIEndpoints.bondOrders,
      API().bondPortfolio,
      APIEndpoints.eachBondPortfolioEndpoint
    ];
    return restrictedEndpoints.any((e) => endpoint.contains(e));
  }

  Future<Map<String, String>> _getHeaders({required String endpoint}) async {
    var baseHeaders = await HttpClientService.getBaseHeaders();

    if (TokenService.isTokenExpired()) {
      if (kDebugMode) {
        print('🔄 Token needs refresh, attempting refresh...');
      }

      final refreshed = await TokenService.refreshToken();
      if (!refreshed) {
        if (kDebugMode) {
          print('❌ Token refresh failed');
        }
        throw Exception('Token refresh failed');
      }

      if (kDebugMode) {
        print('✅ Token refreshed successfully');
      }
    } else if (kDebugMode) {
      print('✅ Token is still valid');
    }

    final token = SessionPref.getToken()![0];
    if (kDebugMode) {
      print('Token length: ${token.length}');
    }
    baseHeaders['Authorization'] = 'Bearer $token';

    if (_requiresCifNumber(endpoint)) {
      var userProfile = SessionPref.getUserProfile();
      if (userProfile != null && userProfile.length > 6) {
        if (userProfile[6] != "pending") {
          userId = base64.encode(utf8.encode(userProfile[5]));
          baseHeaders['id'] = userId;
        }
      } else {
        throw Exception("Complete your profile to access this feature");
      }
    }

    return baseHeaders;
  }

  Future<String?> getStocks(
      {required MarketProvider mp, required BuildContext context}) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.stockList,
        requiresAuth: false,
      );

      if (response['success']) {
        final decodeBody = response['data'];
        List<Stock> stockList = [];

        for (var each in decodeBody["data"]) {
          Stock stock = Stock(
            changeAmount: "${each["price_change_value"] ??= "000"}",
            changePercentage: "${each["price_change_percentage"] ??= "000"}",
            closePrice: "${each["close"] ?? 0}",
            date: "${each["date"]}",
            deals: "${each["deals"]}",
            fullname: "${each["fullname"]}",
            highPrice: "${each["high"]}",
            logo: "${each["logo"]}",
            lowPrice: "${each["low"]}",
            marketCap: "${each["mcap"]}",
            name: "${each["name"]}",
            openPrice: "${each["open"] ??= "000"}",
            price: "${each["price"]}",
            sector: "${each["sector"]}",
            stockID: "${each["security_id"]}",
            turnOver: "${each["turn_over"]}",
            volume: "${each["volume"]}",
            description: "${each["description"] ?? ''}",
          );
          stockList.add(stock);
        }

        mp.stock = stockList;
        return "1";
      } else {
        ErrorHandler.showError(
            context, "Failed to fetch stocks. Please try again later.");
        return null;
      }
    } catch (e) {
      ErrorHandler.showError(
          context, "Failed to fetch stocks. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<String?> getMarketStatus(
      {required MarketProvider mp, required BuildContext context}) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.marketStatus,
        requiresAuth: true,
      );

      if (response['success']) {
        final decodeBody = response['data'];
        String? marketStatus = decodeBody["data"]["status"];
        mp.market = marketStatus;
        return "1";
      } else {
        ErrorHandler.showError(
            context, "Failed to fetch market status. Please try again later.");
        return null;
      }
    } catch (e) {
      ErrorHandler.showError(
          context, "Failed to fetch market status. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<String?> getIndex(MarketProvider mp) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.dseINDEX,
        requiresAuth: true,
      );

      if (response['success']) {
        final decodeBody = response['data'];
        List<MarketIndex> marketIndx = [];

        for (var each in decodeBody) {
          MarketIndex marketIndex = MarketIndex(
            change: "${each["Change"]}",
            closePrice: "${each["ClosingPrice"] ?? 0}",
            code: "${each["Code"]}",
            description: "${each["IndexDescription"]}",
          );
          marketIndx.add(marketIndex);
        }

        mp.marketIndex = marketIndx;
        return "1";
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Exception on getIndex: $e");
      }
      return null;
    }
  }

  Future<String?> stockPerformance({
    required String identity,
    required MarketProvider provider,
    required BuildContext context,
  }) async {
    try {
      String endpoint = "";
      switch (identity) {
        case "movers":
          endpoint = APIEndpoints.movers;
          break;
        case "gainers":
          endpoint = APIEndpoints.gainer;
          break;
        case "losers":
          endpoint = APIEndpoints.loosers;
          break;
        default:
          endpoint = APIEndpoints.movers;
      }

      final response = await HttpClientService.get(
        endpoint: endpoint,
        requiresAuth: true,
      );

      if (response['success']) {
        final decodeBody = response['data'];
        List<MarketPerformance> marketSummary = [];

        for (var each in decodeBody[identity]) {
          MarketPerformance marketPerformance = MarketPerformance(
            change: each["change"],
            close: each["close"],
            marketCap: each["mcap"],
            name: each["name"],
            security: each["security"],
            volume: each["volume"] ??= "",
          );
          marketSummary.add(marketPerformance);
        }

        switch (identity) {
          case "movers":
            provider.marketMovers = marketSummary;
            break;
          case "gainers":
            provider.marketGainers = marketSummary;
            break;
          case "losers":
            provider.marketLoosers = marketSummary;
            break;
        }

        return "1";
      } else {
        ErrorHandler.showError(context,
            "Failed to fetch stock performance. Please try again later.");
        return null;
      }
    } catch (e) {
      ErrorHandler.showError(
          context, "Failed to fetch stock performance. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>> orderStock(
      Order order, MarketProvider mp, BuildContext context) async {
    try {
      var endpoint = order.orderType == "buy"
          ? APIEndpoints.buyOrder
          : APIEndpoints.sellOrder;

      StockPurchase stockPurchase = StockPurchase(
        useCustodian: order.hasCustodian.toString(),
        price: order.price.toString(),
        volume: order.volume.toString(),
        type: order.orderType!,
        securityId: order.stockID.toString(),
        mode: order.mode!,
        paymentOption:
            order.orderType == "buy" ? order.paymentOption ?? '' : null,
        mobile: order.orderType == "buy" ? order.mobile : null,
      );

      final response = await HttpClientService.post(
        endpoint: endpoint,
        body: stockPurchase.toJson(),
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final data = response['data'];
        StockPurchaseResponse stockResponse =
            StockPurchaseResponse.fromJson(data);

        if (kDebugMode) {
          print("${order.orderType} Order: ${stockResponse.toJson()}");
        }

        // Clear stock-related cache after successful order placement
        SimpleCache.clearAfterStockPurchase();

        await getPortfolio(context: context, provider: mp);
        await getOrders(mp);

        ErrorHandler.showSuccess(context, "Order placed successfully");

        return {
          'status': true,
          'message': stockResponse.message,
          'purchaseId': stockResponse.data.purchaseId,
        };
      } else {
        ErrorHandler.showError(
            context, response['message'] ?? 'Failed to place order');
        return {
          'status': false,
          'message': response['message'] ?? 'Failed to place order',
        };
      }
    } catch (e) {
      ErrorHandler.showError(
          context, 'Something went wrong while placing the order',
          error: e);
      return {
        'status': false,
        'message': 'Something went wrong while placing the order',
      };
    }
  }

  Future<String?> getOrders(MarketProvider provider) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.orderList,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decodeBody = response['data'];
        List<Order> orderList = [];
        print('fetched stock orders: ${decodeBody["data"]}');
        for (var each in decodeBody["data"]["data"]) {
          Order order = Order(
            id: each["id"],
            hasCustodian: false,
            mode: each["mode"],
            orderType: each["type"],
            price: each["price"],
            stockID: each["security_id"],
            volume: each["volume"],
            amountBeforeCharge: each["amount"],
            brokerage: each["brokerage"],
            cds: "${each["cds"]}",
            cmsa: "${each["cmsa"]}",
            date: each["created_at"],
            dse: "${each["dse"]}",
            fidelity: "${each["fidelity"]}",
            payout: "${each["payout"]}",
            status: each["status"],
            stockName: each["security_name"],
            totalFees: "${each["total_fees"]}",
            validityUntil: each["validity_until"],
            vat: "${each["vat"]}",
            executed: "${each["executed"]}",
          );
          orderList.add(order);
        }

        provider.order = orderList;
        return "1";
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Exception on getOrders: $e");
      }
      return null;
    }
  }

  Future<String?> getPortfolio(
      {required MarketProvider provider, required BuildContext context}) async {
    if (!await HttpClientService.hasInternetConnection()) {
      // Use cache if available
      if (_portfolioCache != null) {
        provider.portfolio = _portfolioCache;
        return "1";
      }
      throw Exception('No internet connection');
    }

    // Prevent concurrent fetches
    if (_isFetchingPortfolio) {
      if (_portfolioCache != null) {
        provider.portfolio = _portfolioCache;
        return "1";
      }
      return null;
    }

    _isFetchingPortfolio = true;

    try {
      var userProfile = SessionPref.getUserProfile();
      if (userProfile != null &&
          userProfile.length > 6 &&
          userProfile[6] == "pending") {
        // ErrorHandler.showError(
        //     context, "Please complete your profile to view portfolio");
        _isFetchingPortfolio = false;
        return null;
      }

      final response = await HttpClientService.get(
        endpoint: APIEndpoints.portfolioEndpoint,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decodeBody = response['data'];

        PortfolioModel portfolioModel = PortfolioModel(
          availableBalance: double.parse(decodeBody["available"]),
          actualBalance: double.parse(decodeBody["net_available"]),
          currentValue: double.parse(decodeBody["current_value"]),
          investedValue: double.parse(decodeBody["invested_value"]),
          profitLoss: double.parse(decodeBody["profit_or_loss"]),
          profitLossPercentage:
              "${decodeBody["profit_or_loss_percentage"] ?? "0"}",
          wallet: double.parse(decodeBody["available"]),
        );

        var eachPortfolioStatus =
            await getEachStockPortfolio(context: context, mp: provider);
        if (eachPortfolioStatus == "1") {
          if (kDebugMode) {
            print("[STEP 8a PORTFOLIO]: USER PORTFOLIO PULLED SUCCESSFULLY");
          }
        } else {
          if (kDebugMode) {
            print("[STEP 8a PORTFOLIO]: FAIL TO PULL EACH STOCK PORTFOLIO !!");
          }
        }

        var eachBondPortfolioStatus =
            await getEachBondPortfolio(mp: provider, context: context);
        if (eachBondPortfolioStatus == "1") {
          if (kDebugMode) {
            print(
                "[STEP 8b PORTFOLIO]: USER BOND PORTFOLIO PULLED SUCCESSFULLY");
          }
        } else {
          if (kDebugMode) {
            print("[STEP 8b PORTFOLIO]: FAIL TO PULL EACH BOND PORTFOLIO !!");
          }
        }

        provider.portfolio = portfolioModel;
        _portfolioCache = portfolioModel;
        _isFetchingPortfolio = false;
        return "1";
      } else {
        if (_portfolioCache != null) {
          provider.portfolio = _portfolioCache;
          _isFetchingPortfolio = false;
          return "1";
        }
        ErrorHandler.showError(
            context, "Failed to fetch portfolio. Please try again later.");
        _isFetchingPortfolio = false;
        return null;
      }
    } catch (e) {
      _isFetchingPortfolio = false;

      if (e.toString().contains("Profile completion required")) {
        // ErrorHandler.showError(
        //     context, "");
      } else {
        if (_portfolioCache != null) {
          provider.portfolio = _portfolioCache;
          return "1";
        }
        ErrorHandler.showError(
            context, "Failed to fetch portfolio. Please try again later.",
            error: e);
      }
      return null;
    }
  }

  Future<String?> getEachStockPortfolio(
      {required MarketProvider mp, required BuildContext context}) async {
    if (!await HttpClientService.hasInternetConnection()) {
      // Use cache if available
      if (_eachStockPortfolioCache != null && _tickerIOwnCache != null) {
        mp.eachStockPortfolio = _eachStockPortfolioCache ?? [];
        mp.tickerIOwn = _tickerIOwnCache ?? [];
        return "1";
      }
      throw Exception('No internet connection');
    }

    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.eachStockPortfolioEndpoint,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );
      print('=========== Each Stock Portfolio Response: $response');
      if (response['success']) {
        final decodeBody = response['data'];
        List<PortfolioModel> eachStock = [];
        List<String> tickerOwner = [];

        for (var each in decodeBody["data"]) {
          PortfolioModel portfolioModel = PortfolioModel(
            currentValue: double.parse("${each["current_value"]}"),
            investedValue: double.parse("${each["invested_value"]}"),
            profitLoss: double.parse("${each["prof_or_loss"]}"),
            profitLossPercentage: "${each["profit_loss_percent"]}",
            avgPrice: "${each["avg_price"]}",
            qnty:
                each["total_buy"] != null ? each["total_buy"].toString() : '0',
            stockName: each["security"],
            closePrice: each["price"] ?? 0,
            stockID: each["security_id"],
            changeAmount: each["change"],
            changePercentage: "0",
            logoUrl: each["logo"] ?? "",
          );
          eachStock.add(portfolioModel);
          tickerOwner.add(each["security"]);
        }

        mp.eachStockPortfolio = eachStock;
        mp.tickerIOwn = tickerOwner;
        _eachStockPortfolioCache = eachStock;
        _tickerIOwnCache = tickerOwner;
        return "1";
      } else {
        if (_eachStockPortfolioCache != null && _tickerIOwnCache != null) {
          mp.eachStockPortfolio = _eachStockPortfolioCache ?? [];
          mp.tickerIOwn = _tickerIOwnCache ?? [];
          return "1";
        }
        ErrorHandler.showError(context,
            "Failed to fetch each stock portfolio. Please try again later.");
        return null;
      }
    } catch (e) {
      if (_eachStockPortfolioCache != null && _tickerIOwnCache != null) {
        mp.eachStockPortfolio = _eachStockPortfolioCache ?? [];
        mp.tickerIOwn = _tickerIOwnCache ?? [];
        return "1";
      }
      ErrorHandler.showError(context,
          "Failed to fetch each stock portfolio. Please try again later.",
          error: e);
      return null;
    }
  }

  getBondPortfolio({
    required MarketProvider mp,
  }) async {
    if (!await HttpClientService.hasInternetConnection()) {
      throw Exception('No internet connection');
    }
    Map<String, String> headers =
        await _getHeaders(endpoint: API().bondPortfolio);
    Map<String, dynamic> res = await HttpClientService.get(
        additionalHeaders: headers, endpoint: API().bondPortfolio);
    if (kDebugMode) {
      print("BOND PORTFOLIO RESPONSE: $res");
    }

    if (res['success'] == true && res['data'] != null) {
      BondPortfolioSummary bondPortfolioSummary =
          BondPortfolioSummary.fromJson(res);
      mp.bondPortfolio = bondPortfolioSummary;
      return "1";
    }
    return res['message'];
  }

  getEachBondPortfolio({
    required MarketProvider mp,
    context,
  }) async {
    try {
      if (!await HttpClientService.hasInternetConnection()) {
        ErrorHandler.showError(context, "No internet connection.");
        return null;
      }

      Map<String, String> headers =
          await _getHeaders(endpoint: APIEndpoints.eachBondPortfolioEndpoint);

      final response = await HttpClientService.get(
        additionalHeaders: headers,
        endpoint: APIEndpoints.eachBondPortfolioEndpoint,
      );

      if (response['success'] == true && response['data'] != null) {
        try {
          final bondListResponse =
              bondListResponseFromJson(jsonEncode(response['data']));
          print("EACH BOND PORTFOLIO RESPONSE: $bondListResponse");
          if (bondListResponse.bonds.isNotEmpty) {
            mp.myBonds = bondListResponse.bonds;
            return "1";
          } else {
            mp.myBonds = [];
            ErrorHandler.showError(context, "No bond portfolio data found.");
          }
        } catch (e) {
          ErrorHandler.showError(
              context, "Failed to parse bond portfolio data.",
              error: e);
          mp.myBonds = [];
        }
      } else {
        String message = response['message']?.toString() ??
            "Failed to fetch bond portfolio.";
        ErrorHandler.showError(context, message);
        mp.myBonds = [];
      }
    } catch (e) {
      ErrorHandler.showError(context, "Error fetching bond portfolio.",
          error: e);
      mp.myBonds = [];
    }
  }

  Future<String?> getFeesCharges(Order order, MarketProvider mp) async {
    try {
      Map<String, String> qp = {
        "use_custodian": "false",
        "price": order.price ?? "",
        "volume": (double.tryParse(order.volume ?? "0") ?? 0).toString(),
        "security_id": order.stockID ?? "",
        "mode": order.mode ?? "",
      };

      final response = await HttpClientService.get(
        endpoint: APIEndpoints.fees,
        queryParams: qp,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decodedBody = response['data'];

        if (decodedBody["code"] == 100) {
          FeeModel feeModel = FeeModel(
            brokerage: decodedBody["data"]["brokerage"],
            cds: decodedBody["data"]["cds"],
            cmsa: decodedBody["data"]["cmsa"],
            dse: decodedBody["data"]["dse"],
            fidelity: decodedBody["data"]["fidelity"],
            payout: decodedBody["data"]["payout"],
            consideration: decodedBody["data"]["total"],
            totalFees: decodedBody["data"]["total_fees"],
            vat: decodedBody["data"]["vat"],
          );

          mp.feeCharge = feeModel;
          return "1";
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Exception on getFeesCharges: $e");
      }
      return null;
    }
  }

  Future<String?> getStatement(String orderID, MarketProvider mp) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.statementEndpoint,
        queryParams: {"order_id": orderID},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decodedBody = response['data'];
        List<FeeModel> contractNote = [];

        for (var each in decodedBody["data"]["data"]) {
          FeeModel feeModel = FeeModel(
            brokerage: each["brokerage"],
            cds: each["cds"],
            cmsa: each["cmsa"],
            dse: each["dse"],
            fidelity: each["fidelity"],
            payout: each["payout"],
            consideration: each["amount"],
            totalFees: each["total_fees"],
            vat: each["vat"],
            reference: each["reference"],
            ticker: each["security"],
            executed: each["executed"],
            date: each["date"],
            contractId: each["id"],
          );
          contractNote.add(feeModel);
        }

        mp.contractNotes = contractNote;
        return "1";
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Exception on getStatement: $e");
      }
      return null;
    }
  }

  Future<Uint8List?> downloadContractNote(
      {required String orderID, required BuildContext context}) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.downloadContract,
        body: {"id": orderID},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        // Note: This might need adjustment based on how the new HttpClientService handles binary data
        return response['data']; // This may need to be updated
      } else {
        ErrorHandler.showError(context,
            "Failed to download contract note. Please try again later.");
        return null;
      }
    } catch (e) {
      ErrorHandler.showError(
          context, "Something went wrong. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<String?> savePDF({
    required Uint8List pdfStream,
    required String ticker,
    String? reference,
    required BuildContext context,
  }) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      Directory directory = Directory("");
      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Download");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filepath = directory.path;
      await Directory(directory.path).create(recursive: true);

      final file = File(
          "$filepath/$ticker-ITR-${reference?.replaceAll("/", "~")}-contract-note.pdf");
      await file.writeAsBytes(pdfStream);

      ErrorHandler.showSuccess(
          context, "Contract note downloaded successfully");
      return filepath;
    } catch (e) {
      ErrorHandler.showError(
          context, "Failed to download contract note. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<String?> viewStatement({
    required BuildContext context,
    required MarketProvider marketProvider,
  }) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.statement,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decodedResponse = response['data'];
        List<Statement> transactionStatements = [];

        for (var transaction in decodedResponse) {
          Statement statement = Statement(
            debit: "${transaction["debitAmount"] ?? 0}",
            credit: "${transaction["creditAmount"] ?? 0}",
            amount: "${transaction["amount"] ?? 0}",
            transactionDate: transaction["date"] ?? "",
            transactionDescription: transaction["description"] ?? "",
            transactionReference: transaction["reference"] ?? "",
            transactionType: transaction["debitCredit"] ?? "",
            orderType: "",
            transactionPrice: "",
            transactionQuantity: "",
          );
          transactionStatements.add(statement);
        }

        marketProvider.statement = transactionStatements;
        ErrorHandler.showSuccess(context, "Statement loaded successfully");
        return "1";
      } else {
        ErrorHandler.showError(
            context, "Failed to fetch statement. Please try again later.");
        return null;
      }
    } catch (e) {
      ErrorHandler.showError(
          context, "Something went wrong. Please try again later.",
          error: e);
      return null;
    }
  }

  // Continue with remaining methods using the same pattern...
  // I'll implement the key remaining methods to show the pattern

  Future<String?> fundList(
      {required MarketProvider mp, required BuildContext context}) async {
    try {
      // Check cache first
      const cacheKey = 'fundList';
      final cachedData = SimpleCache.get(cacheKey);
      if (cachedData != null) {
        mp.fund = cachedData.data as List<FundModel>;
        return "1";
      }

      final response = await HttpClientService.get(
        endpoint: APIEndpoints.fundlist,
        requiresAuth: true,
      );

      if (response['success']) {
        final decoded = response['data'];
        List<FundModel> fundList = [];

        for (var each in decoded["data"] ?? []) {
          FundModel fundModel = FundModel(
            salePrice: each["sale_price"] ?? "",
            buyPrice: each["buy_price"] ?? "",
            accountNumber: each["fund_account_number"] ?? "",
            bankName: each["fund_bank_name"] ?? "",
            entryFee: "${(double.tryParse(each["entry_fee"] ?? "0") ?? 0)}%",
            exitFee: "${(double.tryParse(each["exit_fee"] ?? "0") ?? 0)}%",
            units: each["units"] ?? "",
            description: each["description"] ?? "",
            nav: each["nav"] ?? "",
            name: each["name"] ?? "",
            sector: each["category"] ?? "",
            shareClassCode: each["fund_code"] ?? "",
            logoUrl: each["logo_url"] ?? '',
            initialMinContribution: each["initial_min_contribution"] ?? "",
            subsequentAmount: each["subsequent_amount"] ?? "",
          );
          fundList.add(fundModel);
        }

        mp.fund = fundList;

        // Cache the result for 10 minutes
        SimpleCache.set(cacheKey, fundList, ttl: Duration(minutes: 10));

        return "1";
      }
      return null;
    } catch (e) {
      ErrorHandler.showError(
          context, "Failed to load fund list. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>> payByMobile({
    required String phoneNumber,
    required String amount,
    required String purchaseId,
    required BuildContext context,
    required String paymentType,
    String? gateway,
  }) async {
    try {
      String endpoint;
      switch (paymentType) {
        case 'fund':
          endpoint = APIEndpoints.fundMobilePayment;
          break;
        case 'stock':
          endpoint = APIEndpoints.stockMobilePayment;
          break;
        case 'bond':
          endpoint = APIEndpoints.bondMobilePayment;
          break;
        default:
          throw Exception('Invalid payment type');
      }

      Map<String, dynamic> requestBody = {
        "mobile": phoneNumber,
        "amount": amount,
        "purchaseId": purchaseId,
      };

      if ((paymentType == 'fund' ||
              paymentType == 'stock' ||
              paymentType == 'bond') &&
          gateway != null) {
        requestBody["gateway"] = gateway;
      }

      final response = await HttpClientService.post(
        endpoint: endpoint,
        body: requestBody,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decoded = response['data'];
        if (decoded["code"] == 100) {
          ErrorHandler.showSuccess(
              context, "Mobile payment processed successfully");
          return {"status": "success", "response": decoded};
        }
      }

      ErrorHandler.showError(
          context, "Failed to process mobile payment. Please try again later.");
      return {"status": "fail", "response": response['data']};
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while processing mobile payment. Please try again later.",
          error: e);
      return {"status": "fail", "response": e.toString()};
    }
  }

  Future<String?> placeFundOrder({
    required String shareClassCode,
    required String fundId,
    required String purchasesValue,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.purchasesFund,
        body: {
          "FundShareClassCode": shareClassCode,
          "fund_id": fundId,
          "PurchaseValue": purchasesValue,
        },
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decoded = response['data'];
        if (decoded["status"] == true) {
          getCombinedFundOrders(
            fundCode: '',
            context: context,
            mp: MarketProvider(),
          );
          ErrorHandler.showSuccess(context, "Fund order placed successfully");
          return "1";
        } else {
          ErrorHandler.showError(
              context,
              decoded["message"] ??
                  "Failed to place fund order. Please try again later.");
          return decoded["message"];
        }
      } else {
        ErrorHandler.showError(
            context, "Failed to place fund order. Please try again later.");
        return response['message'];
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while placing fund order. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>> placeRedemptionOrder({
    required String shareClassCode,
    required String salesValue,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.redemptionEndpoint,
        body: {
          "FundShareClassCode": shareClassCode,
          "SaleValue": salesValue,
        },
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        ErrorHandler.showSuccess(
            context, "Redemption order placed successfully");
        return {
          'status': true,
          'message': 'Redemption order placed successfully',
        };
      } else {
        ErrorHandler.showError(
            context,
            response['message'] ??
                "Failed to place redemption order. Please try again later.");
        return {
          'status': false,
          'message': response['message'] ?? 'Failed to place redemption order',
        };
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while placing redemption order. Please try again later.",
          error: e);
      return {
        'status': false,
        'message': 'Something went wrong while placing redemption order',
        'error': e.toString(),
      };
    }
  }

  // Track ongoing fund portfolio requests to prevent duplicates
  static Future<String?>? _ongoingFundPortfolioRequest;

  Future<String?> fundPortfolio(
      {required BuildContext context, required MarketProvider mp}) async {
    // If there's already an ongoing request, wait for it instead of creating a new one
    if (_ongoingFundPortfolioRequest != null) {
      if (kDebugMode) {
        print("Fund portfolio request already in progress, waiting...");
      }
      return await _ongoingFundPortfolioRequest!;
    }

    // Start new request and store it to prevent duplicates
    _ongoingFundPortfolioRequest =
        _executeFundPortfolioRequest(context: context, mp: mp);

    try {
      final result = await _ongoingFundPortfolioRequest!;
      return result;
    } finally {
      // Clear the ongoing request when done
      _ongoingFundPortfolioRequest = null;
    }
  }

  Future<String?> _executeFundPortfolioRequest(
      {required BuildContext context, required MarketProvider mp}) async {
    try {
      // Check profile status first
      var userProfile = SessionPref.getUserProfile();
      if (userProfile == null ||
          userProfile.length < 6 ||
          userProfile[6] == "pending") {
        throw Exception("Profile completion required");
      }

      // Check cache first - shorter cache time for portfolio data
      const cacheKey = 'fundPortfolio';
      final cachedData = SimpleCache.get(cacheKey);
      if (cachedData != null) {
        final portfolioData = cachedData.data as Map<String, dynamic>;
        mp.eachFundPortfolio =
            portfolioData['eachFundPortfolio'] as List<PortfolioModel>;
        mp.fundPortfolio = portfolioData['fundPortfolio'] as PortfolioModel;
        return "1";
      }

      if (kDebugMode) {
        print("\n=== DEBUG: Starting Fund Portfolio Fetch ===");
      }

      // Get innova portfolio
      final innovaResponse = await HttpClientService.post(
        endpoint: APIEndpoints.fundPortfolio,
        body: {},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      // Get brokerage fund list
      // final brokerageResponse = await HttpClientService.get(
      //   endpoint: APIEndpoints.fundlist,
      //   requiresAuth: true,
      //   additionalHeaders: {'id': userId},
      // );

      // if (innovaResponse['success']) {
      // if (innovaResponse['success'] && brokerageResponse['success']) {
      final decodedInnovaUrlRes = innovaResponse['data'];
      // final decodedBrokerageUrlRes = brokerageResponse['data'];

      if (decodedInnovaUrlRes["IsSuccess"] == true) {
        // Create maps of brokerage funds for both full and short names
        Map<String, dynamic> brokarageFunds = {};
        // for (var fund in decodedBrokerageUrlRes["data"]) {
        //   String fullName = fund["name"].toString().toLowerCase();
        //   String shortName = fullName.split(' ').first;

        //   brokarageFunds[fullName] = fund;
        //   brokarageFunds[shortName] = fund;
        // }

        double totalInvestedValue = 0.0;
        double totalCurrentValue = 0.0;
        double totalGainLoss = 0.0;
        List<PortfolioModel> fundPortfolioList = [];

        for (var innovaFund in decodedInnovaUrlRes["UnitTrustFundDetails"]) {
          // String innovaFundName =
          innovaFund["FundName"].toString().toLowerCase();
          // String innovaShortName = innovaFundName.split(' ').first;
          print("=========== Innova Fund Name: $innovaFund['GainLoss']");
          // var brokarageFund =
          //     brokarageFunds[innovaFundName] ?? brokarageFunds[innovaShortName];

          // if (brokarageFund != null) {
          final double units =
              double.parse(innovaFund["Units"]?.toString() ?? "0");

          final double unitPrice =
              double.parse(innovaFund["UnitPrice"]?.toString() ?? "0");
          final double fundInvestedValue =
              double.parse("${innovaFund["Contributions"]}");

          final double fundCurrentValue =
              double.parse("${innovaFund["MarketValue"]}");
          final double fundGainLoss = double.parse("${innovaFund["GainLoss"]}");

          totalCurrentValue += fundCurrentValue;
          totalInvestedValue += fundInvestedValue;
          totalGainLoss += fundGainLoss;

          PortfolioModel portfolioModel = PortfolioModel(
            investedValue: fundInvestedValue,
            profitLoss: fundGainLoss,
            profitLossPercentage: "${innovaFund["PercentageChange"] ?? "0"}",
            stockName: innovaFund["FundName"],
            qnty: units.toStringAsFixed(2),
            stockID: innovaFund["FundShareClassCode"],
            closePrice: "$unitPrice",
            avgPrice: unitPrice.toStringAsFixed(2),
            currentValue: fundCurrentValue,
            changeAmount: "0",
            changePercentage: "",
          );

          fundPortfolioList.add(portfolioModel);
          // }
        }

        //  print('=========== Innova Fund Details: ${e}');

        mp.eachFundPortfolio = fundPortfolioList;
        // mp.fundPortfolio = PortfolioModel(
        //   currentValue: totalCurrentValue,
        //   investedValue: totalInvestedValue,
        //   profitLoss: totalGainLoss,
        //   profitLossPercentage:
        //       "${(totalInvestedValue != 0) ? (totalGainLoss / totalInvestedValue * 100).toStringAsFixed(2) : 0}",
        // );

        // Cache portfolio data for 5 minutes
        SimpleCache.set(
            cacheKey,
            {
              'eachFundPortfolio': fundPortfolioList,
              'fundPortfolio': mp.fundPortfolio,
            },
            ttl: Duration(minutes: 5));

        return "1";
      } else {
        if (decodedInnovaUrlRes["Message"]?.contains("ClientIdentifier") ??
            false) {
          throw Exception("Profile completion required");
        }
        return null;
      }
      // } else {
      //   // ErrorHandler.showError(context,
      //   //     "Failed to load your portfolio data. Please try again later.");
      //   return null;
      // }
    } catch (e) {
      print('=========== Innova Fund Details: ${e}');

      if (e.toString().contains(" Profile completion required")) {
        // ErrorHandler.showError(
        //     context, "Please complete your profile to start Investing.");
      } else {
        // ErrorHandler.showError(context,
        //     "Failed to load your portfolio data. Please try again later.",
        //     error: e);
      }
      return null;
    }
  }

  Future<String?> getFundOrders(
      {required MarketProvider mp, required BuildContext context}) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.fundBuyOrder,
        body: {},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decoded = response['data'];
        if (decoded["IsSuccess"] == true) {
          List<Subscription> fundSubs = [];

          if (decoded["Data"] != null && decoded["Data"] is List) {
            for (var each in decoded["Data"]) {
              Subscription subscription = Subscription(
                amount: "${each["TransactionAmount"] ?? '0'}",
                date: each["TransactionDate"] ?? "",
                fundName: each["Fund"] ?? "",
                reqReference: each["RequestReference"] ?? "",
                shareClass: each["FundShareClass"] ?? "",
                shareClassCode: each["FundShareClassCode"] ?? "",
                transReference: each["TransactionReference"] ?? "",
                transStatus: each["TransactionStatus"] ?? "",
                transactionType: each["TransactionType"] ?? "",
              );
              fundSubs.add(subscription);
            }
            mp.fundOrders = fundSubs;
            return "1";
          } else {
            mp.fundOrders = [];
            return "0";
          }
        } else {
          ErrorHandler.showError(context,
              "Failed to retrieve fund subscriptions. Please try again later.");
          return null;
        }
      } else {
        ErrorHandler.showError(context,
            "Failed to retrieve fund subscriptions. Please try again later.");
        return null;
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while retrieving fund subscriptions. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<List<IPOSubscription>?> getRedemptionOrders({
    required MarketProvider mp,
    required BuildContext context,
    int page = 1,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.redemptionOrder,
        // body: {},
        body: {"page": page.toString()},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decoded = response['data'];
        if (decoded["IsSuccess"] == true) {
          List<Subscription> fundSubs = [];
          for (var each in decoded["Data"]) {
            Subscription subscription = Subscription(
              amount: "${each["TransactionAmount"]}",
              date: each["TransactionDate"],
              fundName: each["Fund"],
              reqReference: each["RequestReference"],
              shareClass: each["FundShareClass"],
              shareClassCode: each["FundShareClassCode"],
              transReference: each["TransactionReference"] ?? "",
              transStatus: each["TransactionStatus"],
              transactionType: each["TransactionType"],
            );
            fundSubs.add(subscription);
          }
          mp.fundRedemptionOrder = fundSubs;
          return null;
        } else {
          ErrorHandler.showError(context,
              "Something Went Wrong While Retrieving Your Fund Redemption Orders, Please Try again later");
          return null;
        }
      } else {
        ErrorHandler.showError(context,
            "Failed to retrieve redemption orders. Please try again later.");
        return null;
      }
    } catch (e) {
      ErrorHandler.showError(
          context, "Something went wrong. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<String?> uploadProofOfPayment({
    required File receipt,
    required String amount,
    required String description,
    required String purchaseId,
    required String paymentType,
    required BuildContext context,
  }) async {
    try {
      String endpoint;
      switch (paymentType) {
        case 'fund':
          endpoint = APIEndpoints.uploadProofEp;
          break;
        case 'stock':
          endpoint = APIEndpoints.stockProofPayment;
          break;
        case 'bond':
          endpoint = APIEndpoints.bondProofPayment;
          break;
        default:
          throw Exception('Invalid payment type');
      }

      final response = await HttpClientService.postMultipart(
        endpoint: endpoint,
        fields: {
          "amountPaid": amount,
          "description": description,
          "purchaseId": purchaseId,
        },
        files: {
          "attachment": receipt,
        },
        requiresAuth: true,
        additionalHeaders: {
          'id': userId,
        },
      );
      print("Upload Proof Response: ${SessionPref.getUserProfile()}");
      print("Upload Proof Response: $response");
      if (response['success']) {
        ErrorHandler.showSuccess(
            context, "Proof of payment uploaded successfully");
        return "success";
      } else {
        ErrorHandler.showError(context,
            "Failed to upload proof of payment. Please try again later.");
        return "fail";
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while uploading proof of payment. Please try again later.",
          error: e);
      return null;
    }
  }

  Future<String?> stockPayProofOfPayment({
    required File receipt,
    required String amount,
    required String description,
    required String purchaseId,
    required BuildContext context,
  }) async {
    try {
      if (!receipt.existsSync()) {
        throw Exception('Receipt file does not exist');
      }

      final response = await HttpClientService.postMultipart(
        endpoint: APIEndpoints.stockProofPayment,
        fields: {
          "amountPaid": amount,
          "description": description,
          "purchaseId": purchaseId,
        },
        files: {
          "attachment": receipt,
        },
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        ErrorHandler.showSuccess(
            context, "Stock proof of payment uploaded successfully");
        return "success";
      } else {
        ErrorHandler.showError(context,
            "Failed to upload proof of payment. ${response['message'] ?? ''}");
        return "fail";
      }
    } catch (e) {
      ErrorHandler.showError(context, "Something went wrong: $e", error: e);
      return null;
    }
  }

  Future<String?> bondPayProofOfPayment({
    required File receipt,
    required String amount,
    required String description,
    required String purchaseId,
    required BuildContext context,
  }) async {
    try {
      if (!receipt.existsSync()) {
        throw Exception('Receipt file does not exist');
      }

      final response = await HttpClientService.postMultipart(
        endpoint: APIEndpoints.bondProofPayment,
        fields: {
          "amountPaid": amount,
          "description": description,
          "purchaseId": purchaseId,
        },
        files: {
          "attachment": receipt,
        },
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        ErrorHandler.showSuccess(
            context, "Bond proof of payment uploaded successfully");
        return "success";
      } else {
        ErrorHandler.showError(context,
            "Failed to upload proof of payment. ${response['message'] ?? ''}");
        return "fail";
      }
    } catch (e) {
      ErrorHandler.showError(context, "Something went wrong: $e", error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>> payByAzamPesa({
    required String phoneNumber,
    required String amount,
    required String purchaseId,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.azamPay,
        body: {
          "purchase_id": purchaseId,
          "amount": amount,
          "gateway": "azampay",
          "mobile": phoneNumber,
        },
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decoded = response['data'];
        if (decoded["code"] == 600 && decoded["success"] == true) {
          ErrorHandler.showSuccess(
              context, "AzamPesa payment processed successfully");
          return {
            "status": "success",
            "transactionId": decoded["transactionId"],
            "redirectUrl": decoded["redirectUrl"],
            "message": decoded["message"],
          };
        } else if (decoded["code"] == 601) {
          String errorMessage = decoded["message"] is Map
              ? decoded["message"]["message"] ??
                  "Payment failed. Please try again."
              : decoded["message"] ?? "Payment failed. Please try again.";

          ErrorHandler.showError(context, errorMessage);
          return {
            "status": "fail",
            "transactionId": decoded["transactionId"] ?? "",
            "message": errorMessage,
            "messageCode": decoded["message"] is Map
                ? decoded["message"]["messageCode"]
                : null,
          };
        } else {
          ErrorHandler.showError(
              context, "Unexpected error occurred. Please try again later.");
          return {"status": "fail", "response": decoded};
        }
      } else {
        ErrorHandler.showError(context,
            "Failed to process AzamPesa payment. Please try again later.");
        return {"status": "fail", "response": response['data']};
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Something went wrong while processing payment. Please try again later.",
          error: e);
      return {"status": "fail", "response": e.toString()};
    }
  }

  Future<Map<String, dynamic>> getFundOrderDetails({
    required String fundCode,
    required BuildContext context,
    required MarketProvider mp,
    int page = 1,
  }) async {
    if (page != 1) {
      return {"data": []};
    }

    try {
      List<IPOSubscription> allOrders = [];

      // 1. Get paginated brokerage orders
      final brokerageResponse = await HttpClientService.get(
        endpoint: APIEndpoints.brokerageFundBuyOrder,
        queryParams: {"page": page.toString()},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (brokerageResponse['success']) {
        final brokerageData = brokerageResponse['data'];
        if (brokerageData['data'] != null) {
          for (var order in brokerageData['data']) {
            var subscription = IPOSubscription.fromJson(order);
            if (!allOrders.any((o) => o.id == subscription.id)) {
              allOrders.add(subscription);
            }
          }
        }

        // 2. Get innova buy orders (only on first page)
        if (page == 1) {
          final fundBuyResponse = await HttpClientService.post(
            endpoint: APIEndpoints.fundBuyOrder,
            body: {},
            requiresAuth: true,
            additionalHeaders: {'id': userId},
          );

          if (fundBuyResponse['success']) {
            final fundBuyData = fundBuyResponse['data'];
            if (fundBuyData['Data'] != null) {
              for (var order in fundBuyData['Data']) {
                var buyOrder = IPOSubscription(
                  accountNumber: '',
                  clientRef: order['ClientIdentifier'] ?? '',
                  date: order['TransactionDate'] ?? '',
                  fundCode: order['FundShareClassCode'] ?? '',
                  id: order['RequestReference'] ?? '',
                  fundId: '',
                  name: order['Fund'] ?? '',
                  status: order['TransactionStatus'] ?? '',
                  amount: order['TransactionAmount']?.toString() ?? '',
                  amountPaid: order['TransactionAmount']?.toString() ?? '',
                  reference: order['TransactionReference'] ?? '',
                  paymentProof: '',
                  transactionType: 'buy',
                );
                if (!allOrders.any((o) => o.id == buyOrder.id)) {
                  allOrders.add(buyOrder);
                }
              }
            }
          }

          // 3. Get redemption orders
          final redemptionResponse = await HttpClientService.post(
            endpoint: APIEndpoints.redemptionOrder,
            body: {},
            requiresAuth: true,
            additionalHeaders: {'id': userId},
          );

          if (redemptionResponse['success']) {
            final redemptionData = redemptionResponse['data'];
            if (redemptionData['Data'] != null) {
              for (var order in redemptionData['Data']) {
                var redemptionOrder = IPOSubscription(
                  accountNumber: '',
                  clientRef: order['ClientIdentifier'] ?? '',
                  date: order['TransactionDate'] ?? '',
                  fundCode: order['FundShareClassCode'] ?? '',
                  id: order['RequestReference'] ?? '',
                  fundId: '',
                  name: order['Fund'] ?? '',
                  status: order['TransactionStatus'] ?? '',
                  amount: order['TransactionAmount']?.toString() ?? '',
                  amountPaid: order['TransactionAmount']?.toString() ?? '',
                  reference: order['TransactionReference'] ?? '',
                  paymentProof: '',
                  transactionType: 'sale',
                );
                if (!allOrders.any((o) => o.id == redemptionOrder.id)) {
                  allOrders.add(redemptionOrder);
                }
              }
            }
          }
        }

        // Sort all orders by date
        allOrders.sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

        return {
          'status': 'success',
          'message': 'Successfully retrieved fund orders',
          'data': allOrders,
          'totalRecords': brokerageData['total'] ?? 0,
          'hasMorePages': page < (brokerageData['last_page'] ?? 1),
          'currentPage': page,
        };
      } else {
        return {
          'status': 'error',
          'message': 'Failed to retrieve fund orders',
          'data': null,
        };
      }
    } catch (e) {
      // ErrorHandler.showError(
      //     context, "Failed to retrieve fund orders. Please try again later.",
      //     error: e);
      return {
        'status': 'error',
        'message': 'Failed to retrieve fund orders',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getCombinedFundOrders({
    required String fundCode,
    required BuildContext context,
    required MarketProvider mp,
    int page = 1,
  }) async {
    var headers = await _getHeaders(endpoint: APIEndpoints.fundBuyOrder);
    List<IPOSubscription> combinedOrders = [];
    int totalPages = 1;

    try {
      // Fund Buy Orders API Call
      final fundBuyResponse = await HttpClientService.post(
        endpoint: APIEndpoints.fundBuyOrder,
        // body: {},
        body: {"pageNumber": page.toString()},
        requiresAuth: true,
        additionalHeaders: headers,
      );

      print("=============fund orders buy ${DateTime.now()}============");
      print("=============fund orders buy $fundBuyResponse============");

      if (fundBuyResponse['success']) {
        final fundBuyData = fundBuyResponse['data'];
        if (fundBuyData["success"] == true) {
          List fundItems = fundBuyData["Data"] ?? [];
          for (var item in fundItems) {
            combinedOrders.add(IPOSubscription.fromFundBuyJson(item));
          }
          totalPages = fundBuyData["TotalPages"] ?? totalPages;
        }
      }

      // Brokerage Orders
      final brokerageResponse = await HttpClientService.get(
        endpoint: APIEndpoints.brokerageFundBuyOrder,
        queryParams: {"page": page.toString()},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      print("=============fund orders brokage ${DateTime.now()}============");
      print(
          "=============fund orders brokage ======= ${brokerageResponse['code']}=====");
      print("=============fund orders brokage $brokerageResponse============");

      if (brokerageResponse['success']) {
        final brokerageData = brokerageResponse['data'];
        if (brokerageData["data"] != null) {
          List brokerageItems = brokerageData["data"];
          for (var item in brokerageItems) {
            combinedOrders.add(IPOSubscription.fromBrokerageJson(item));
          }
          print(
              "=============fund orders brokage $brokerageResponse============");
        }
      }

      // Redemption Orders
      final redemptionResponse = await HttpClientService.post(
        endpoint: APIEndpoints.redemptionOrder,
        // body: {},
        body: {"pageNumber": page.toString()},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );
      print("=============fund orders redem $redemptionResponse============");

      if (redemptionResponse['success']) {
        final redemptionData = redemptionResponse['data'];
        if (redemptionData["success"] == true) {
          List redemptionItems = redemptionData["Data"] ?? [];
          for (var item in redemptionItems) {
            combinedOrders.add(IPOSubscription.fromRedemptionJson(item));
          }
        }
      }

      return {"data": combinedOrders, "totalPages": totalPages};
    } catch (e) {
      if (kDebugMode) print("Error in getCombinedFundOrders: $e");
      return {"data": <IPOSubscription>[], "totalPages": totalPages};
    }
  }

  Future<Map<String, double>> getMyPortfolio({
    required MarketProvider mp,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.myPortfolio,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      var data = response['data']['data'];
      print('====== getMyPortfolio ${response['data']}');

      mp.combinedPortfolio = PortfolioModel(
        investedValue: double.parse('${data['investedValue']}'),
        currentValue: double.parse('${data['currentValue']}'),
        profitLoss: double.parse('${data['profitLoss']}'),
        profitLossPercentage: '${data['percentageChange']}',
      );

      return {
        'investedValue': double.parse('${data['investedValue']}'),
        'currentValue': double.parse('${data['currentValue']}'),
        'profitLoss': double.parse('${data['profitLoss']}'),
        'profitLossPercentage': double.parse('${data['percentageChange']}'),
      };
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, double>> getMyFundPortfolio({
    required MarketProvider mp,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.myFundPortfolio,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      var data = response['data']['data'];
      print('====== getMyPortfolio ${response['data']}');

      mp.fundPortfolio = PortfolioModel(
        investedValue: double.parse('${data['investedValue']}'),
        currentValue: double.parse('${data['currentValue']}'),
        profitLoss: double.parse('${data['profitLoss']}'),
        profitLossPercentage: '${data['percentageChange']}',
      );
      return {
        'investedValue': double.parse('${data['investedValue']}'),
        'currentValue': double.parse('${data['currentValue']}'),
        'profitLoss': double.parse('${data['profitLoss']}'),
        'profitLossPercentage': double.parse('${data['percentageChange']}'),
      };
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getCombinedPortfolio({
    required MarketProvider mp,
    required BuildContext context,
  }) async {
    try {
      // Fetch stock portfolio
      var stockPortfolioResponse =
          await getPortfolio(provider: mp, context: context);
      if (stockPortfolioResponse != "1") {
        //  throw Exception('Failed to fetch stock portfolio');
      }

      // Fetch fund portfolio
      var fundPortfolioResponse = await fundPortfolio(context: context, mp: mp);
      if (fundPortfolioResponse != "1") {
        //   throw Exception('Failed to fetch fund portfolio');
      }

      // Calculate combined values
      double totalInvestedValue = (mp.portfolio?.investedValue ?? 0) +
          (mp.fundPortfolio?.investedValue ?? 0);
      double totalCurrentValue = (mp.portfolio?.currentValue ?? 0) +
          (mp.fundPortfolio?.currentValue ?? 0);
      double wallet = mp.portfolio?.wallet ?? 0;
      double profitLoss = totalCurrentValue - totalInvestedValue;
      double profitLossPercentage = totalInvestedValue != 0
          ? double.parse(
              ((profitLoss / totalInvestedValue) * 100).toStringAsFixed(2))
          : 0;

      return {
        'wallet': wallet,
        'investedValue': totalInvestedValue,
        'currentValue': totalCurrentValue,
        'profitLoss': profitLoss,
        'profitLossPercentage': profitLossPercentage,
      };
    } catch (e) {
      // ErrorHandler.showError(
      //     context, "Error fetching combined portfolio. Please try again later.",
      //     error: e);
      return {};
    }
  }

  Future<void> getBonds(
      {required MarketProvider mp, required BuildContext context}) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.bondList,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final bondResponse = bondResponseFromJson(jsonEncode(response['data']));
        mp.bonds = bondResponse.bonds;
        if (kDebugMode) {
          print(
              "Bonds fetched successfully: ${bondResponse.bonds.length} bonds");
        }
      } else {
        // ErrorHandler.showError(
        //     context, "Failed to fetch bonds. Please try again later.");
      }
    } catch (e) {
      // ErrorHandler.showError(
      //     context, "Failed to fetch bonds. Please try again later.",
      //     error: e);
      rethrow;
    }
  }

  Future<BondOrderCostBreakdown> calculateBondOrderFees({
    required BondOrderRequest order,
    required MarketProvider mp,
    required BuildContext context,
    bool useCustodian = false,
  }) async {
    try {
      var options = {
        'bond': order.bond,
        'price': order.price.toString(),
        'face_value': order.faceValue.toString(),
        'notice': order.notice,
        'useCustodian': useCustodian.toString(),
      };

      final response = await HttpClientService.get(
        endpoint: APIEndpoints.calculateBuy,
        queryParams: options,
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final costBreakdown =
            bondOrderCostBreakdownFromJson(jsonEncode(response['data']));
        mp.bondsCostBreakdown = costBreakdown;

        if (kDebugMode) {
          print(
              'Bond order fees calculated successfully: Total=${costBreakdown.total}, Payout=${costBreakdown.payout}');
        }
        return costBreakdown;
      } else {
        ErrorHandler.showError(context,
            "Failed to calculate bond order fees. Please try again later.");
      }
    } catch (e) {
      ErrorHandler.showError(context,
          "Failed to calculate bond order fees. Please try again later.",
          error: e);
      rethrow;
    }
    throw Exception("Failed to calculate bond order fees.");
  }

  Future<Map<String, dynamic>> orderBond(
      BondOrderRequest order, MarketProvider mp, BuildContext context) async {
    try {
      final response = await HttpClientService.post(
        endpoint: APIEndpoints.bondBuy,
        body: order.toJson(),
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final decodeBody = response['data'];

        // Clear bond-related cache after successful order placement
        SimpleCache.clearAfterBondPurchase();

        // Clear provider's cached bond orders to force refresh
        mp.bondOrders = [];

        ErrorHandler.showSuccess(context, "Bond order placed successfully");

        if (kDebugMode) {
          print("Bond buy order: $decodeBody");
        }

        return {
          'status': true,
          'message': decodeBody["message"],
          'data': decodeBody["data"]['purchaseId'],
        };
      } else {
        ErrorHandler.showError(
            context, response['message'] ?? "Failed to place bond order.");
        return {
          'status': false,
          'message': response['message'] ?? 'Failed to place bond order.',
        };
      }
    } catch (e) {
      ErrorHandler.showError(
          context, 'Something went wrong while placing the bond order',
          error: e);
      return {
        'status': false,
        'message': 'Something went wrong while placing the bond order',
      };
    }
  }

  Future<void> getBondOrders(
      {required MarketProvider mp, required BuildContext context}) async {
    try {
      final response = await HttpClientService.get(
        endpoint: APIEndpoints.bondOrders,
        queryParams: {'market': 'primary', 'status': 'all'},
        requiresAuth: true,
        additionalHeaders: {'id': userId},
      );

      if (response['success']) {
        final bondOrdersResponse =
            bondOrdersResponseFromJson(jsonEncode(response['data']));
        mp.bondOrders = bondOrdersResponse.data.data;

        if (kDebugMode) {
          print(
              "Orders fetched successfully: ${bondOrdersResponse.data.data.length} orders");
        }
      } else {
        ErrorHandler.showError(
            context, "Failed to fetch orders. Please try again later.");
      }
    } catch (e) {
      ErrorHandler.showError(
          context, "Failed to fetch orders. Please try again later.",
          error: e);
      rethrow;
    }
  }
}
