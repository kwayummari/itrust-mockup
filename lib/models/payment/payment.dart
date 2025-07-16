class Check {
  String channelRef,
      senderName,
      senderAccount,
      receiverName,
      receiverAccount,
      amount,
      narration;

  Check(
      {required this.amount,
      required this.channelRef,
      required this.narration,
      required this.receiverAccount,
      required this.receiverName,
      required this.senderAccount,
      required this.senderName});
}
