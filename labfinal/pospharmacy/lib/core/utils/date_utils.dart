class DateUtilsHelper {
  /// yyyy-MM-dd (Reports, DB)
  static String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  /// dd/MM/yyyy (UI)
  static String formatReadable(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  /// Current timestamp
  static String now() {
    return DateTime.now().toIso8601String();
  }
}
