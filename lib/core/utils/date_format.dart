import 'package:intl/intl.dart';

String timeAgo(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(date);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return m == 1 ? '1 minute ago' : '$m minutes ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return h == 1 ? '1 hour ago' : '$h hours ago';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return d == 1 ? '1 day ago' : '$d days ago';
  }
  return DateFormat('MMM d, y').format(date);
}

String fullDateTime(DateTime date) =>
    DateFormat("MMM d, y 'at' h:mm a").format(date);

String shortDateTime(DateTime date) => DateFormat('MMM d, h:mm a').format(date);
