import 'package:floor/floor.dart';
import 'package:intl/intl.dart';

class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }

  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime tomorrow() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }
}

class OptionalDateTimeConverter extends TypeConverter<DateTime?, int?> {
  @override
  DateTime? decode(int? databaseValue) {
    if (databaseValue == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int? encode(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.millisecondsSinceEpoch;
  }

  static String formatDate(DateTime dateTime) {
    String month = DateFormat.MMM().format(dateTime);
    String day = DateFormat.d().format(dateTime);
    return "$month $day";
  }

  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}


String formatDate(DateTime dateTime) {
  String month = DateFormat.MMM().format(dateTime);
  String day = DateFormat.d().format(dateTime);
  return "$month $day";
}

String getWeekday(DateTime dateTime) {
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

int daysUntil(DateTime date) {
  return compareDates(date, DateTimeConverter.today());
}


int compareDates(DateTime key1, DateTime key2) {
  return int.parse("${key1.year}${key1.month}${key1.day}") -
      int.parse("${key2.year}${key2.month}${key2.day}");
}
