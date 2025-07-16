import 'package:iwealth/providers/market.dart';
import 'package:iwealth/services/stocks/apis_request.dart';

class Starter {
  initiateStoc({required MarketProvider mp, required context}) async {
    if (mp.stock == null ||
        mp.portfolio == null ||
        mp.eachStockPortfolio.isEmpty ||
        mp.market == null ||
        mp.order.isEmpty ||
        mp.marketIndex.isEmpty) {
      await StockWaiter().getStocks(mp: mp, context: context);
      await StockWaiter()
          .stockPerformance(identity: "movers", provider: mp, context: context);
      await StockWaiter().stockPerformance(
          identity: "gainers", provider: mp, context: context);
      await StockWaiter()
          .stockPerformance(identity: "losers", provider: mp, context: context);
      await StockWaiter().getMarketStatus(mp: mp, context: context);
      await StockWaiter().getOrders(mp);
      await StockWaiter().getIndex(mp);
    } else {}
  }
}
