import 'package:intl/intl.dart';

class DateUtilsHelper {
  /// 1. Format date with custom pattern
  static String formatDate(DateTime date, String format) {
    try {
      return DateFormat(format).format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }

  /// 2. Format as "dd MMM yyyy" (14 Jul 2026)
  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// 3. Format as "EEEE, MMMM dd, yyyy" (Tuesday, July 14, 2026)
  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  /// 4. Format as "hh:mm a" (12:06 PM)
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// 5. Format as "dd MMM yyyy, hh:mm a"
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  /// 6. Parse string to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy').parse(dateString);
      } catch (_) {
        return null;
      }
    }
  }

  /// 7. Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// 8. Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// 9. Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// 10. Get relative time string (e.g., "2 hours ago")
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  /// 11. Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays.abs();
  }

  /// 12. Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// 13. Get start of day (00:00:00)
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 14. Get end of day (23:59:59)
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// 15. Add days to date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// 16. Subtract days from date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// 17. Get weekday name
  static String getWeekday(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// 18. Get month name
  static String getMonth(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// 19. Check if weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// 20. Get list of dates in range
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final List<DateTime> dates = [];
    DateTime current = getStartOfDay(start);
    final DateTime last = getStartOfDay(end);

    while (!current.isAfter(last)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Validate if a string is a valid date
  static bool isValidDate(String dateString) {
    try {
      DateTime.parse(dateString);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get formatted relative date (Today, Yesterday, Tomorrow, or formatted date)
  static String getRelativeDateLabel(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    if (isTomorrow(date)) return 'Tomorrow';
    return formatDateShort(date);
  }
}