/// A streak milestone the user works toward — earned once a streak reaches
/// [days]. Name and inspirational quote are localized by day via l10n_helpers
/// (`localizedStreakBadgeName` / `localizedStreakBadgeQuote`); the flame badge
/// art lives under assets/streak_badges/.
class StreakMilestone {
  /// Distinct active days required to earn this milestone.
  final int days;

  /// Badge art shown for this milestone.
  final String asset;

  const StreakMilestone({required this.days, required this.asset});
}

/// The ordered streak milestones, mirroring the streak_badges art set.
const List<StreakMilestone> kStreakMilestones = [
  StreakMilestone(days: 1, asset: 'assets/streak_badges/1.png'),
  StreakMilestone(days: 3, asset: 'assets/streak_badges/3.png'),
  StreakMilestone(days: 7, asset: 'assets/streak_badges/7.png'),
  StreakMilestone(days: 14, asset: 'assets/streak_badges/14.png'),
  StreakMilestone(days: 30, asset: 'assets/streak_badges/30.png'),
  StreakMilestone(days: 100, asset: 'assets/streak_badges/100.png'),
  StreakMilestone(days: 365, asset: 'assets/streak_badges/365.png'),
];

/// The next milestone a streak of [streak] days is working toward, or `null`
/// once every milestone has been reached.
StreakMilestone? nextStreakMilestone(int streak) {
  for (final m in kStreakMilestones) {
    if (streak < m.days) return m;
  }
  return null;
}
