import '../models/mission.dart';

/// Data for object hunt missions: items the user can be asked to photograph.

const List<String> objectHuntItems = [
  'chair', 'book', 'cup', 'bottle', 'plant', 'lamp', 'pillow',
  'clock', 'shoe', 'bag', 'phone', 'remote', 'key', 'glasses',
];

const List<String> petHuntItems = [
  'dog', 'cat', 'bird', 'fish', 'rabbit', 'hamster', 'turtle',
];

const List<String> natureHuntItems = [
  'leaf', 'flower', 'tree', 'rock', 'stick', 'cloud', 'bird',
  'grass', 'mushroom', 'bark', 'seed', 'pebble',
];

/// Returns the default items for a hunt mission type.
List<String> defaultItemsFor(MissionType type) {
  switch (type) {
    case MissionType.objectHunt:
      return objectHuntItems;
    case MissionType.petHunt:
      return petHuntItems;
    case MissionType.natureHunt:
      return natureHuntItems;
    default:
      return [];
  }
}

/// Returns an emoji for a well-known hunt item label, or null if unknown.
String? emojiForItemLabel(String label) {
  const map = {
    'dog': '🐕', 'cat': '🐈', 'bird': '🐦', 'fish': '🐟',
    'rabbit': '🐰', 'hamster': '🐹', 'turtle': '🐢',
    'leaf': '🍃', 'flower': '🌸', 'tree': '🌳', 'rock': '🪨',
    'stick': '🪵', 'cloud': '☁️', 'grass': '🌿', 'mushroom': '🍄',
    'bark': '🪵', 'seed': '🌱', 'pebble': '🪨',
    'chair': '🪑', 'book': '📚', 'cup': '☕', 'bottle': '🍶',
    'plant': '🪴', 'lamp': '💡', 'pillow': '🛏️', 'clock': '🕐',
    'shoe': '👟', 'bag': '👜', 'phone': '📱', 'remote': '📺',
    'key': '🔑', 'glasses': '👓',
  };
  return map[label.toLowerCase()];
}

/// Returns the photo prompt target text for fixed-target missions.
String photoTargetFor(MissionType type) {
  switch (type) {
    case MissionType.skyPhoto:
      return 'sky';
    case MissionType.makeBed:
      return 'a made bed';
    case MissionType.touchGrass:
      return 'grass';
    default:
      return 'the target';
  }
}
