import 'package:equatable/equatable.dart';

/// Top-level segments of the Community page.
enum CommunitySegment { feed, groups, messages }

/// Feed filter chips.
enum CommunityFilter { forYou, recent, following, support }

/// A single feed post.
class CommunityPost extends Equatable {
  final String avatar;
  final String username;
  final String tag;
  final String timeAgo;
  final String body;
  final int likes;
  final int comments;
  final int shares;
  final bool liked;

  const CommunityPost({
    required this.avatar,
    required this.username,
    required this.tag,
    required this.timeAgo,
    required this.body,
    required this.likes,
    required this.comments,
    required this.shares,
    this.liked = false,
  });

  CommunityPost copyWith({int? likes, bool? liked}) => CommunityPost(
    avatar: avatar,
    username: username,
    tag: tag,
    timeAgo: timeAgo,
    body: body,
    likes: likes ?? this.likes,
    comments: comments,
    shares: shares,
    liked: liked ?? this.liked,
  );

  @override
  List<Object?> get props => [
    avatar,
    username,
    tag,
    timeAgo,
    body,
    likes,
    comments,
    shares,
    liked,
  ];
}

/// A support/community group.
class CommunityGroup extends Equatable {
  final String avatar;
  final String name;
  final int members;
  final String description;
  final bool joined;

  const CommunityGroup({
    required this.avatar,
    required this.name,
    required this.members,
    required this.description,
    this.joined = false,
  });

  @override
  List<Object?> get props => [avatar, name, members, description, joined];
}

/// A direct-message conversation preview.
class CommunityMessage extends Equatable {
  final String avatar;
  final String name;
  final String lastMessage;
  final String timeAgo;
  final int unread;

  const CommunityMessage({
    required this.avatar,
    required this.name,
    required this.lastMessage,
    required this.timeAgo,
    this.unread = 0,
  });

  @override
  List<Object?> get props => [avatar, name, lastMessage, timeAgo, unread];
}

/// Hardcoded mock content for the Community page — simulates backend data.
class CommunityMockData {
  CommunityMockData._();

  // Asset shortcuts.
  static const _avatar1 = 'assets/community/profil_avatar/Avatar1.png';
  static const _avatar2 = 'assets/community/profil_avatar/Avater2.png';
  static const _avatar3 = 'assets/community/profil_avatar/Avatar3.png';
  static const _avatar4 = 'assets/community/profil_avatar/Avatar4.png';

  // Groups segment badge count.
  static const groupsCount = 12;

  // Daily inspiration quote.
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

  // Feed posts.
  static const posts = [
    CommunityPost(
      avatar: _avatar1,
      username: 'mindful_mo',
      tag: 'Anxiety',
      timeAgo: '2h',
      body: 'Had a tough morning, but taking 10 deep breaths really helped '
          'me reset. Small steps 🌱',
      likes: 24,
      comments: 8,
      shares: 7,
    ),
    CommunityPost(
      avatar: _avatar2,
      username: 'brave_bird',
      tag: 'Depression',
      timeAgo: '5h',
      body: 'Reminder to be gentle with yourself today. You\'re doing better '
          'than you think you are 💛',
      likes: 32,
      comments: 12,
      shares: 9,
    ),
    CommunityPost(
      avatar: _avatar3,
      username: 'calm_cloud',
      tag: 'Mindfulness',
      timeAgo: '8h',
      body: 'Five minutes of journaling before bed has changed my sleep. '
          'Highly recommend giving it a try ✍️',
      likes: 18,
      comments: 5,
      shares: 3,
    ),
    CommunityPost(
      avatar: _avatar4,
      username: 'steady_sam',
      tag: 'Recovery',
      timeAgo: '1d',
      body: 'One month sober today. Grateful for this community for keeping '
          'me grounded 🙏',
      likes: 96,
      comments: 41,
      shares: 22,
    ),
  ];

  // Groups.
  static const groups = [
    CommunityGroup(
      avatar: _avatar1,
      name: 'Anxiety Support',
      members: 1284,
      description: 'A safe space to share and cope together.',
      joined: true,
    ),
    CommunityGroup(
      avatar: _avatar3,
      name: 'Mindful Mornings',
      members: 842,
      description: 'Daily meditation and gratitude check-ins.',
    ),
    CommunityGroup(
      avatar: _avatar2,
      name: 'Beating the Blues',
      members: 2071,
      description: 'Peer support for depression and low moods.',
    ),
    CommunityGroup(
      avatar: _avatar4,
      name: 'Sober & Strong',
      members: 593,
      description: 'Recovery journeys, one day at a time.',
      joined: true,
    ),
    CommunityGroup(
      avatar: _avatar1,
      name: 'Better Sleep Club',
      members: 1150,
      description: 'Tips and routines for restful nights.',
    ),
  ];

  // Messages.
  static const messages = [
    CommunityMessage(
      avatar: _avatar3,
      name: 'calm_cloud',
      lastMessage: 'Thank you, that really means a lot 💛',
      timeAgo: '5m',
      unread: 2,
    ),
    CommunityMessage(
      avatar: _avatar1,
      name: 'mindful_mo',
      lastMessage: 'Want to join the morning session tomorrow?',
      timeAgo: '1h',
      unread: 1,
    ),
    CommunityMessage(
      avatar: _avatar4,
      name: 'steady_sam',
      lastMessage: 'Congrats on the milestone! 🎉',
      timeAgo: '3h',
    ),
    CommunityMessage(
      avatar: _avatar2,
      name: 'brave_bird',
      lastMessage: 'You\'ve got this. Talk soon.',
      timeAgo: '1d',
    ),
  ];
}
