/// Centralized date formatting utilities for Alpha Connect.
///
/// All screens should import this file instead of defining inline
/// formatting functions. Follows D-05 through D-09 conventions.
library;

/// Format a DateTime as a date string.
/// Current year: DD/MM. Different year: DD/MM/YYYY.
/// Per D-07.
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final now = DateTime.now();
  if (date.year == now.year) {
    return '$day/$month';
  }
  return '$day/$month/${date.year}';
}

/// Format a DateTime as date + time string.
/// Current year: DD/MM HH:MM. Different year: DD/MM/YYYY HH:MM.
/// Per D-07.
String formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final now = DateTime.now();
  if (date.year == now.year) {
    return '$day/$month $hour:$minute';
  }
  return '$day/$month/${date.year} $hour:$minute';
}

/// Format a DateTime as relative time (short form).
/// < 1 min: "agora", < 60 min: "Xm", < 24h: "Xh", <= 7 days: "Xd".
/// Beyond 7 days: falls back to formatDate().
/// Per D-08, D-09.
String formatRelativeTime(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);

  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays <= 7) return '${diff.inDays}d';

  return formatDate(timestamp);
}
