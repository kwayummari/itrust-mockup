class NumberFormatter {
  static String formatNumber(String number) {
    if (number.isEmpty) return '';
    final buffer = StringBuffer();
    final reversedNumber = number.split('').reversed.toList();
    for (int i = 0; i < reversedNumber.length; i++) {
      if (i != 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversedNumber[i]);
    }
    return buffer.toString().split('').reversed.join('');
  }
}
