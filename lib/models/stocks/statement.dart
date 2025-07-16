// class Statement{
//   String id,tradeDate,vat,brokerage,totalCommission,cmsa,dse,fidelity,totalFee,cds,payout,volume,price,status,type
// }
class Statement {
  String debit,
      credit,
      transactionDescription,
      transactionDate,
      transactionReference,
      transactionType,
      orderType,
      transactionQuantity,
      transactionPrice,
      amount;
  Statement({
    required this.debit,
    required this.credit,
    required this.transactionDate,
    required this.transactionDescription,
    required this.transactionReference,
    required this.transactionType,
    required this.orderType,
    required this.transactionPrice,
    required this.transactionQuantity,
    required this.amount,
  });
}
