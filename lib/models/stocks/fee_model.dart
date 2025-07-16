class FeeModel {
  String brokerage,
      cds,
      cmsa,
      dse,
      fidelity,
      vat,
      consideration,
      totalFees,
      payout;
  String? ticker, reference, executed, date, contractId;

  FeeModel(
      {required this.brokerage,
      required this.cds,
      required this.cmsa,
      required this.dse,
      required this.fidelity,
      required this.payout,
      required this.consideration,
      required this.totalFees,
      required this.vat,
      this.reference,
      this.ticker,
      this.executed,
      this.date,
      this.contractId});
}
