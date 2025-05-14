import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _inputDateFormat =
      DateFormat('yyyy-MM-ddTHH:mm:ss.SSSSSS');
  static final DateFormat _outputDateFormat = DateFormat('dd/MM/yyyy');

  static String format(String dateString) {
    try {
      final DateTime date = _inputDateFormat.parse(dateString);
      return _outputDateFormat.format(date);
    } catch (e) {
      print('Error parsing date: $e');
      return '';
    }
  }
}
