
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
  static String formatDate(DateTime dateTime) {
    String month = DateFormat.MMM().format(dateTime);
    String day = DateFormat.d().format(dateTime);
    return "$month $day";
  }
  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month,  now.day);
  }
}

class OptionalDateTimeConverter extends TypeConverter<DateTime?, int?> {
  @override
  DateTime? decode(int? databaseValue) {
    if(databaseValue == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }
  @override
  int? encode(DateTime? value) {
    if(value == null) {
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
    return DateTime(now.year, now.month,  now.day);
  }
}