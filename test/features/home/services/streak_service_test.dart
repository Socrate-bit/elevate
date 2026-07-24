import 'package:elevate/features/activity/models/activity.dart';
import 'package:elevate/features/home/services/heart_service.dart';
import 'package:elevate/features/home/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Anchor "now" so tests are deterministic (8pm on a fixed day).
  final now = DateTime(2026, 7, 24, 20);

  Activity at(DateTime t, {bool completed = true}) => Activity(
        id: t.millisecondsSinceEpoch.toString(),
        timestamp: t,
        durationSeconds: 0,
        completed: completed,
      );

  group('StreakService.computeStreak', () {
    test('no activities → 0', () {
      expect(StreakService.computeStreak([], now: now), 0);
    });

    test('only incomplete activities → 0', () {
      final acts = [at(now.subtract(const Duration(hours: 2)), completed: false)];
      expect(StreakService.computeStreak(acts, now: now), 0);
    });

    test('activity today → 1', () {
      final acts = [at(DateTime(2026, 7, 24, 9))];
      expect(StreakService.computeStreak(acts, now: now), 1);
    });

    test('activity today + yesterday → 2', () {
      final acts = [at(DateTime(2026, 7, 24, 9)), at(DateTime(2026, 7, 23, 9))];
      expect(StreakService.computeStreak(acts, now: now), 2);
    });

    test('single missed day within 48h freezes (not counted, not broken)', () {
      // Today 09:00 and the day-before-yesterday 22:00 are 35h apart (< 48h),
      // so the skipped day is frozen: run survives, missed day isn't counted.
      final acts = [at(DateTime(2026, 7, 24, 9)), at(DateTime(2026, 7, 22, 22))];
      expect(StreakService.computeStreak(acts, now: now), 2);
    });

    test('two silent days (>= 48h gap) break the run', () {
      // Today 10:00 and three days ago 10:00 are 72h apart → older day drops.
      final acts = [at(DateTime(2026, 7, 24, 10)), at(DateTime(2026, 7, 21, 10))];
      expect(StreakService.computeStreak(acts, now: now), 1);
    });

    test('streak breaks once nothing is completed within 48h', () {
      // Last completed 59h before now.
      final acts = [at(DateTime(2026, 7, 22, 9))];
      expect(StreakService.computeStreak(acts, now: now), 0);
    });

    test('yesterday-only holds the streak (freeze, today not yet active)', () {
      final acts = [at(DateTime(2026, 7, 23, 9))];
      expect(StreakService.computeStreak(acts, now: now), 1);
    });

    test('multiple activities on the same day count once', () {
      final acts = [
        at(DateTime(2026, 7, 24, 8)),
        at(DateTime(2026, 7, 24, 18)),
        at(DateTime(2026, 7, 23, 12)),
      ];
      expect(StreakService.computeStreak(acts, now: now), 2);
    });

    test('unsorted input is handled', () {
      final acts = [at(DateTime(2026, 7, 23, 9)), at(DateTime(2026, 7, 24, 9))];
      expect(StreakService.computeStreak(acts, now: now), 2);
    });
  });

  group('Heart ↔ streak alignment', () {
    test('hearts decay one per 12h from the last activity', () {
      expect(HeartService.computeHearts(null, now: now), kHeartMax);
      expect(HeartService.computeHearts(now, now: now), kHeartMax);
      expect(
        HeartService.computeHearts(now.subtract(const Duration(hours: 12)), now: now),
        3,
      );
      expect(
        HeartService.computeHearts(now.subtract(const Duration(hours: 24)), now: now),
        2,
      );
    });

    test('streak breaks exactly when the last heart is lost (48h)', () {
      final lastActivity = now.subtract(const Duration(hours: 48));
      expect(HeartService.computeHearts(lastActivity, now: now), 0);
      expect(StreakService.computeStreak([at(lastActivity)], now: now), 0);
    });
  });
}
