import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat   = DateFormat('dd MMM yyyy');
  static final _shortDate    = DateFormat('dd MMM');
  static final _timeFormat   = DateFormat('hh:mm a');
  static final _monthYear    = DateFormat('MMM yyyy');
  static final _iso          = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");

  static String formatDate(DateTime dt)       => _dateFormat.format(dt.toLocal());
  static String formatShortDate(DateTime dt)  => _shortDate.format(dt.toLocal());
  static String formatTime(DateTime dt)       => _timeFormat.format(dt.toLocal());
  static String formatMonthYear(DateTime dt)  => _monthYear.format(dt.toLocal());

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inHours < 1)    return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)     return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static DateTime? tryParse(String? s) {
    if (s == null) return null;
    try { return DateTime.parse(s).toLocal(); } catch (_) { return null; }
  }

  static String toIso(DateTime dt) => _iso.format(dt.toUtc());
}
