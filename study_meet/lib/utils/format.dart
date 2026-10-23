import '../models/countdown.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';
String formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String formatDateTime(DateTime date) =>
    '${formatDate(date)}, ${formatTime(date)}';
String countdownLabel(Countdown value) => switch (value) {
  Upcoming(:final remaining) =>
    remaining.inDays > 0
        ? 'In ${remaining.inDays} days'
        : remaining.inHours > 0
        ? 'In ${remaining.inHours} hours'
        : 'In ${remaining.inMinutes + 1} min',
  Started(:final elapsed) => 'Started ${elapsed.inMinutes} min ago',
  Ended() => 'Ended',
};
