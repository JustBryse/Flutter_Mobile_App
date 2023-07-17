abstract class TimeUtility {
  static String getIsoDateTime(DateTime date) {
    return "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}";
  }
}
