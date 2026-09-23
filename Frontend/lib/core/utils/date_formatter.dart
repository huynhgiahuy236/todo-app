import 'package:intl/intl.dart';

class DateFormatter {
  static String formatIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseIsoDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static String formatDisplayDateVi(DateTime date) {
    final weekdayNames = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    final weekday = weekdayNames[date.weekday % 7];
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return '$weekday, $formattedDate';
  }

  static String formatWeekdayHeader(DateTime date) {
    final weekdayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return weekdayNames[date.weekday % 7];
  }

  static String formatMonthYear(DateTime date) {
    return 'Tháng ${date.month}, ${date.year}';
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  // Returns 7 days of the week starting from Monday (or configured start day)
  static List<DateTime> getWeekDays(DateTime current, {bool startOnMonday = true}) {
    final currentDayOnly = DateTime(current.year, current.month, current.day);
    // weekday in Dart: 1 = Mon ... 7 = Sun
    final diff = startOnMonday ? (currentDayOnly.weekday - 1) : (currentDayOnly.weekday % 7);
    final monday = currentDayOnly.subtract(Duration(days: diff));

    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
