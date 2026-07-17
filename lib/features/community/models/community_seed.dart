/// Static community content that is not user-generated, plus the initial set
/// of groups seeded into Firestore on first run.
class CommunitySeed {
  CommunitySeed._();

  // Daily inspiration quote (static, shown on the feed).
  static const dailyInspiration =
      'Healing is not linear, and that\'s okay. You keep showing up, '
      'and that\'s enough.';

  // Mood check-in faces, ordered great -> really hard.
  static const moodAssets = [
    'assets/mood tracking/very_good_icon.png',
    'assets/mood tracking/good_icon.png',
    'assets/mood tracking/neutral_icon.png',
    'assets/mood tracking/bad_icon.png',
    'assets/mood tracking/very_bad_icon.png',
  ];

  /// Initial groups written to `community_groups` when the collection is empty.
  /// [id] is a stable slug so re-seeding is idempotent. [memberCount] is the
  /// displayed starting size; real joins increment it from there.
  static const groups = <CommunityGroupSeed>[
    CommunityGroupSeed(
      id: 'anxiety-support',
      name: 'Anxiety Support',
      description: 'A safe space to share and cope together.',
      avatarId: 1,
      memberCount: 1284,
    ),
    CommunityGroupSeed(
      id: 'mindful-mornings',
      name: 'Mindful Mornings',
      description: 'Daily meditation and gratitude check-ins.',
      avatarId: 3,
      memberCount: 842,
    ),
    CommunityGroupSeed(
      id: 'beating-the-blues',
      name: 'Beating the Blues',
      description: 'Peer support for depression and low moods.',
      avatarId: 2,
      memberCount: 2071,
    ),
    CommunityGroupSeed(
      id: 'sober-and-strong',
      name: 'Sober & Strong',
      description: 'Recovery journeys, one day at a time.',
      avatarId: 4,
      memberCount: 593,
    ),
    CommunityGroupSeed(
      id: 'better-sleep-club',
      name: 'Better Sleep Club',
      description: 'Tips and routines for restful nights.',
      avatarId: 1,
      memberCount: 1150,
    ),
  ];
}

/// A seed definition for a community group.
class CommunityGroupSeed {
  final String id;
  final String name;
  final String description;
  final int avatarId;
  final int memberCount;

  const CommunityGroupSeed({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarId,
    required this.memberCount,
  });
}
