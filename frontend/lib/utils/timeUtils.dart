import 'package:intl/intl.dart';

String formatShortTime(DateTime time) {
  final now = DateTime.now();
  final isSameDay = now.year == time.year && now.month == time.month && now.day == time.day;
  if (isSameDay) {
    return DateFormat.Hm().format(time);
  }
  final isSameYear = now.year == time.year;
  final format = isSameYear ? DateFormat('dd/MM') : DateFormat('dd/MM/yy');
  return format.format(time);
}
