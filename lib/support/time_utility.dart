abstract class TimeUtility {
  static String getIsoDateTime(DateTime date) {
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}";
  }

  static DateTime getDateTimeFromFormattedPattern(String pattern) {
    // tryParse returns null if parse fails
    DateTime? date = DateTime.tryParse(pattern);
    if (date == null) {
      return DateTime(0);
    } else {
      return date;
    }
  }
}
