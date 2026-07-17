/// Compact relative-time label for community timestamps, e.g. `now`, `5m`,
/// `2h`, `3d`, `2w`. Kept non-localized to match the feed's compact style.
String communityTimeAgo(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(time);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${(diff.inDays / 7).floor()}w';
}
