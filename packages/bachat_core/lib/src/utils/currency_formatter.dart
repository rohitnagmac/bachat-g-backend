import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _indianRupeeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0, // Usually expenses are round numbers, can be 2 if needed
  );

  static String format(double amount) {
    return _indianRupeeFormat.format(amount);
  }
}
