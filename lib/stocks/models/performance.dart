class MarketPerformance {
  String? security, name, marketCap, close, change, volume;

  MarketPerformance(
      {required this.change,
      required this.close,
      required this.marketCap,
      required this.name,
      required this.security,
      required this.volume});
}
