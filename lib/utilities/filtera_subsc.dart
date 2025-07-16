import 'package:iwealth/providers/market.dart';

filterSubsc({required String fundCode, required MarketProvider mp}) {
  return mp.ipoSubsc.where((stock) => stock.fundCode == fundCode).toList();
}
