/// Formatter tanggal dan waktu ramah pengguna Indonesia
class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static String formatDateTime(DateTime dateTime) {
    final day = dateTime.day;
    final month = _months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute WIB';
  }

  static String formatTimeOnly(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  static String formatDateOnly(DateTime dateTime) {
    final day = dateTime.day;
    final month = _months[dateTime.month - 1];
    final year = dateTime.year;
    return '$day $month $year';
  }
}
