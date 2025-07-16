class PortfolioModel {
  double? availableBalance,
      actualBalance,
      currentValue,
      investedValue,
      profitLoss,
      wallet;
  String? qnty,
      avgPrice,
      stockName,
      profitLossPercentage,
      closePrice,
      changeAmount,
      changePercentage,
      stockID,
      logoUrl;

  PortfolioModel({
    this.availableBalance,
    this.actualBalance,
    required this.currentValue,
    required this.investedValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    this.wallet,
    this.avgPrice,
    this.qnty,
    this.stockName,
    this.closePrice,
    this.changeAmount,
    this.changePercentage,
    this.stockID,
    this.logoUrl,
  });
}
