/// Hardcoded mock content for the home page — simulates backend data.
/// (The "Today's Plan" list is now backed by real routines; the badges, quest,
/// and greeting name below remain mock until those features are wired.)
class HomeMockData {
  static const userName = 'Lucas';

  // Top bar notification badges.
  static const questsBadge = '!';
  static const shopBadge = '2';
  static const messageBadge = '2';

  // Active quest banner.
  static const questTitle = 'Forest Adventure';
  static const questDone = 0;
  static const questTotal = 15;
}
