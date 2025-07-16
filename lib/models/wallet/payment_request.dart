class PaymentRequest {
  final double amount;
  final String mobile;


  PaymentRequest({
    required this.amount,
    required this.mobile,
 
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'mobile': mobile,
     
    };
  }
}
