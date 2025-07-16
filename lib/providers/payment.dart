import 'package:iwealth/models/payment/payment.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  Check? _cheque;

  Check? get cheque => _cheque;

  set cheque(Check? data) {
    _cheque = data;
    notifyListeners();
  }
}
