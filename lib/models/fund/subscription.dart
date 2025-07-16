class Subscription {
  String shareClass,
      transReference,
      amount,
      fundName,
      transStatus,
      reqReference,
      shareClassCode,
      transactionType,
      date;

  Subscription(
      {required this.amount,
      required this.date,
      required this.fundName,
      required this.reqReference,
      required this.shareClass,
      required this.shareClassCode,
      required this.transReference,
      required this.transStatus,
      required this.transactionType});
}
