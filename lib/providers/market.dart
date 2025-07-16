import 'package:iwealth/models/IPO/ipo_model.dart';
import 'package:iwealth/models/IPO/subscription.dart';
import 'package:iwealth/models/bonds/bond_order_cost_breakdown.dart';
import 'package:iwealth/models/fund/fund_model.dart';
import 'package:iwealth/models/fund/subscription.dart';
import 'package:iwealth/models/stocks/fee_model.dart';
import 'package:iwealth/models/stocks/statement.dart';
import 'package:iwealth/stocks/models/bond_holdings_model.dart';
import 'package:iwealth/stocks/models/bond_model.dart';
import 'package:iwealth/stocks/models/bond_orders_model.dart';
import 'package:iwealth/stocks/models/bond_portfolio_model.dart';

import 'package:iwealth/stocks/models/market_index.dart';
import 'package:iwealth/stocks/models/order.dart';
import 'package:iwealth/stocks/models/performance.dart';
import 'package:iwealth/stocks/models/portfolio.dart';
import 'package:iwealth/stocks/models/stock.model.dart';
import 'package:flutter/material.dart';

class MarketProvider extends ChangeNotifier {
  String? _market;
  String? _currentScreen;
  FeeModel? _feeCharge;
  BondOrderCostBreakdown? _bondsCostBreakdown;
  List<Stock>? _stock;
  List<String> _tickerIOwn = [];

  List<MarketIndex> _marketIndex = [];
  List<MarketPerformance>? _marketMovers;
  List<MarketPerformance>? _marketGainers;
  List<MarketPerformance>? _marketLoosers;
  List<Order> _order = [];
  List<Subscription> _fundOrders = [];
  List<Subscription> _fundRedemptionOrders = [];
  PortfolioModel? _portfolio;
  BondPortfolioSummary? _bondPortfolio;
  PortfolioModel? _fundPortfolio;
  PortfolioModel? _combinedPortfolio;
  List<PortfolioModel> _eachStockPortfolio = [];
  List<PortfolioModel> _eachFundPortfolio = [];
  List<FeeModel> _contractNotes = [];
  List<Statement> _statement = [];
  List<FundModel> _fund = [];
  List<FUNDIPO> _fundIPO = [];
  List<IPOSubscription> _ipoSubsc = [];
  List<UserSubscriber> _usrSub = [];
  double _totalContirbutions = 0.0;

  String _accountNumber = '';
  String _clientRef = '';

  List<Bond> _bonds = [];
  List<MyBond> _my_bonds = [];
  List<BondOrder> _bond_orders = [];

  double get totalContributions => _totalContirbutions;
  String? get currentScreen => _currentScreen;
  String? get market => _market;
  List<Stock>? get stock => _stock;
  List<MarketIndex> get marketIndex => _marketIndex;

  List<MarketPerformance>? get marketMovers => _marketMovers;
  List<MarketPerformance>? get marketGainers => _marketGainers;
  List<MarketPerformance>? get marketLoosers => _marketLoosers;
  List<Order> get order => _order;
  List<Subscription> get fundOrders => _fundOrders;
  List<Subscription> get fundRedemptionOrder => _fundRedemptionOrders;
  PortfolioModel? get fundPortfolio => _fundPortfolio;
  PortfolioModel? get portfolio => _portfolio;
  BondPortfolioSummary? get bondPortfolio => _bondPortfolio;
  PortfolioModel? get combinedPortfolio => _combinedPortfolio;
  List<PortfolioModel> get eachStockPortfolio => _eachStockPortfolio;
  List<PortfolioModel> get eachFundPortfolio => _eachFundPortfolio;
  FeeModel? get feeCharge => _feeCharge;
  BondOrderCostBreakdown? get bondsCostBreakdown => _bondsCostBreakdown;
  List<FeeModel> get contractNotes => _contractNotes;
  List<String> get tickerIOwn => _tickerIOwn;
  List<Statement> get statement => _statement;
  List<FundModel> get fund => _fund;
  List<FUNDIPO> get fundIPO => _fundIPO;
  List<IPOSubscription> get ipoSubsc => _ipoSubsc;
  List<UserSubscriber> get usrSub => _usrSub;
  String get accountNumber => _accountNumber;
  String get clientRef => _clientRef;
  List<Bond> get bonds => _bonds;
  List<MyBond> get myBonds => _my_bonds;
  List<BondOrder> get bondOrders => _bond_orders;

  set totalContributions(double tc) {
    _totalContirbutions = tc;
    notifyListeners();
  }

  set currentScreen(String? currentScr) {
    _currentScreen = currentScr;
    notifyListeners();
  }

  set market(String? status) {
    _market = status;
    notifyListeners();
  }

  set marketIndex(List<MarketIndex> marketIn) {
    _marketIndex = marketIn;
    notifyListeners();
  }

  set marketMovers(List<MarketPerformance>? marketPerfomance) {
    _marketMovers = marketPerfomance;
    notifyListeners();
  }

  set marketGainers(List<MarketPerformance>? marketPerfomance) {
    _marketGainers = marketPerfomance;
    notifyListeners();
  }

  set marketLoosers(List<MarketPerformance>? marketPerfomance) {
    _marketLoosers = marketPerfomance;
    notifyListeners();
  }

  set order(List<Order> order) {
    _order = order;
    notifyListeners();
  }

  set fundOrders(List<Subscription> fundorder) {
    _fundOrders = fundorder;
    notifyListeners();
  }

  set fundRedemptionOrder(List<Subscription> fundorder) {
    _fundRedemptionOrders = fundorder;
    notifyListeners();
  }

  set portfolio(PortfolioModel? portfolio) {
    _portfolio = portfolio;
    notifyListeners();
  }

  set bondPortfolio(BondPortfolioSummary? bondPort) {
    _bondPortfolio = bondPort;
    notifyListeners();
  }

  set fundPortfolio(PortfolioModel? fundPort) {
    _fundPortfolio = fundPort;
    notifyListeners();
  }

  set combinedPortfolio(PortfolioModel? combinedPort) {
    _combinedPortfolio = combinedPort;
    notifyListeners();
  }

  set eachStockPortfolio(List<PortfolioModel> eachPortfolio) {
    _eachStockPortfolio = eachPortfolio;
    notifyListeners();
  }

  set eachFundPortfolio(List<PortfolioModel> eachFundPortfolio) {
    _eachFundPortfolio = eachFundPortfolio;
    notifyListeners();
  }

  set stock(List<Stock>? stock) {
    _stock = stock;
    notifyListeners();
  }

  set feeCharge(FeeModel? feeCharge) {
    _feeCharge = feeCharge;
    notifyListeners();
  }

  set bondsCostBreakdown(BondOrderCostBreakdown? bondsCostBreakdown) {
    _bondsCostBreakdown = bondsCostBreakdown;
    notifyListeners();
  }

  set contractNotes(List<FeeModel> feeModel) {
    _contractNotes = feeModel;
    notifyListeners();
  }

  set tickerIOwn(List<String> tickerOwner) {
    _tickerIOwn = tickerOwner;
    notifyListeners();
  }

  set statement(List<Statement> statement) {
    _statement = statement;
    notifyListeners();
  }

  set fund(List<FundModel> fund) {
    _fund = fund;
    notifyListeners();
  }

  set fundIPO(List<FUNDIPO> fundipo) {
    _fundIPO = fundipo;
    notifyListeners();
  }

  set ipoSubsc(List<IPOSubscription> iposubs) {
    _ipoSubsc = iposubs;
    notifyListeners();
  }

  set usrSub(List<UserSubscriber> usrSubs) {
    _usrSub = usrSubs;
    notifyListeners();
  }

  set bonds(List<Bond> bondList) {
    _bonds = bondList;
    notifyListeners();
  }

  set myBonds(List<MyBond> myBondList) {
    _my_bonds = myBondList;
    notifyListeners();
  }

  set bondOrders(List<BondOrder> bondOrders) {
    _bond_orders = bondOrders;
    notifyListeners();
  }

  void setAccountDetails({String? accountNumber, String? clientRef}) {
    if (accountNumber != null) _accountNumber = accountNumber;
    if (clientRef != null) _clientRef = clientRef;
    notifyListeners();
  }

  void setFundPortfolio(Map<String, dynamic> data) {
    _fundPortfolio = PortfolioModel(
      stockID: '',
      stockName: '',
      qnty: '0',
      closePrice: '0',
      investedValue: double.tryParse(data['investedValue'].toString()) ?? 0.0,
      currentValue: double.tryParse(data['currentValue'] ?? '0') ?? 0.0,
      profitLoss: double.tryParse(data['profitLoss'] ?? '0') ?? 0,
      profitLossPercentage: data['profitLossPercentage'] ?? '0',
      changeAmount: '0',
      changePercentage: '0',
    );
    notifyListeners();
  }
}
