import 'package:campus_incident_reporter/core/utils/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 7, 12, 0);

  test('timeAgo picks a sensible unit', () {
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now: now), 'just now');
    expect(timeAgo(now.subtract(const Duration(minutes: 1)), now: now), '1 minute ago');
    expect(timeAgo(now.subtract(const Duration(minutes: 45)), now: now), '45 minutes ago');
    expect(timeAgo(now.subtract(const Duration(hours: 2)), now: now), '2 hours ago');
    expect(timeAgo(now.subtract(const Duration(days: 1)), now: now), '1 day ago');
    expect(timeAgo(now.subtract(const Duration(days: 3)), now: now), '3 days ago');
  });

  test('older dates fall back to a calendar date', () {
    expect(timeAgo(DateTime(2026, 10, 1), now: now), 'Oct 1, 2026');
  });
}
