import 'package:intl/intl.dart';

currencyFormat(n) {
  final currFormat = NumberFormat("#,##0.00", "en_US");
  return currFormat.format(n);
}
