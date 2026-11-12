/// Formatter mata uang Rupiah (IDR)
class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(num amount) {
    final integerPart = amount.round().toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    final formatted = buffer.toString().split('').reversed.join();
    return 'Rp $formatted';
  }
}
