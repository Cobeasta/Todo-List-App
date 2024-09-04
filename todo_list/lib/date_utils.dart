import 'package:intl/intl.dart';

class TaskListDateUtils {
  static final comparisonDateFormat = DateFormat("yyyymmdd");
  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isToday(DateTime date) {
    return compareDates(date, today()) == 0;
  }

  static bool isBefore(DateTime date, DateTime end) {
    return compareDates(date, end) < 0;
  }

  static bool isAfterInclusive(DateTime date, DateTime start) {
    return compareDates(date, start) >= 0;
  }

  static DateTime tomorrow() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  static DateTime daysFromToday(int offset) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + offset);
  }

  static String formatDate(DateTime dateTime) {
    String month = DateFormat.MMM().format(dateTime);
    String day = DateFormat.d().format(dateTime);
    return "$month $day";
  }

  static String getWeekday(DateTime dateTime) {
    String dayStr;
    switch (dateTime.weekday) {
      case 1:
        dayStr = "Mon";
        break;
      case 2:
        dayStr = "Tues";
        break;
      case 3:
        dayStr = "Wed";
        break;
      case 4:
        dayStr = "Thurs";
        break;
      case 5:
        dayStr = "Fri";
        break;
      case 6:
        dayStr = "Sat";
        break;
      case 7:
        dayStr = "Sun";
        break;
      default:
        dayStr = "UNKNOWN";
        break;
    }
    return dayStr;
  }

  static int daysUntil(DateTime date) {
    return compareDates(date, today());
  }

  static int compareDates(DateTime key1, DateTime key2) {
    int key1I = int.parse(comparisonDateFormat.format(key1));
    int key2I = int.parse(comparisonDateFormat.format(key2));
    return key1I - key2I;
  }
  static DateTime thisSaturday() {
    DateTime tod = today();
    switch(tod.weekday) {
      case 1:
        return DateTime(tod.year, tod.month, tod.day + 5);
      case 2:
        return DateTime(tod.year, tod.month, tod.day + 4);
      case 3:
        return DateTime(tod.year, tod.month, tod.day + 3);
      case 4:
        return DateTime(tod.year, tod.month, tod.day + 2);
      case 5:
        return DateTime(tod.year, tod.month, tod.day + 1);
      case 6:
        return tod;
      case 7:
        return DateTime(tod.year, tod.month, tod.day + 6);
    }
    return tod;
  }
}
