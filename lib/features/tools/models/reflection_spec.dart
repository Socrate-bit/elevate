import 'package:elevate/l10n/generated/app_localizations.dart';

/// Which guided reflection a session runs. Every kind shares the same 3-step
/// flow (name three things → remember them → hold a feeling) and only differs
/// in its copy, emojis, and the Firestore collection it persists to.
enum ReflectionKind { gratitude, selfLove, mindfulness }

/// Localized copy for one reflection session, resolved per [ReflectionKind].
class ReflectionCopy {
  final String prompt; // Step 0 heading.
  final String hint; // Step 0 subheading.
  final String Function(int number) itemLabel; // Field hint, e.g. "Joy 1".
  final String rememberTitle;
  final String rememberBody;
  final String affirmTitle;
  final String affirmBody;

  const ReflectionCopy({
    required this.prompt,
    required this.hint,
    required this.itemLabel,
    required this.rememberTitle,
    required this.rememberBody,
    required this.affirmTitle,
    required this.affirmBody,
  });
}

/// Static description of a reflection mission — the varying pieces the shared
/// reflection session screen and cubit are parameterized by.
class ReflectionSpec {
  final ReflectionKind kind;

  /// Reported as `{tool}` in the shared tool analytics funnel.
  final String analyticsName;

  /// Firestore subcollection under `users/{uid}` this mission saves to.
  final String collection;

  /// Emoji shown beside each captured item on the "remember" step.
  final String chipEmoji;

  /// Hero emoji shown on the final "affirm" step.
  final String affirmEmoji;

  const ReflectionSpec._({
    required this.kind,
    required this.analyticsName,
    required this.collection,
    required this.chipEmoji,
    required this.affirmEmoji,
  });

  static const gratitude = ReflectionSpec._(
    kind: ReflectionKind.gratitude,
    analyticsName: 'Gratitude',
    collection: 'gratitude',
    chipEmoji: '🌿',
    affirmEmoji: '🙏',
  );

  static const selfLove = ReflectionSpec._(
    kind: ReflectionKind.selfLove,
    analyticsName: 'Self-love',
    collection: 'selfLove',
    chipEmoji: '💛',
    affirmEmoji: '🤍',
  );

  static const mindfulness = ReflectionSpec._(
    kind: ReflectionKind.mindfulness,
    analyticsName: 'Mindfulness',
    collection: 'mindfulness',
    chipEmoji: '🍃',
    affirmEmoji: '🧘',
  );

  /// Resolves this mission's localized copy.
  ReflectionCopy copy(AppLocalizations l10n) {
    switch (kind) {
      case ReflectionKind.gratitude:
        return ReflectionCopy(
          prompt: l10n.gratitudeStepPrompt,
          hint: l10n.gratitudeHint,
          itemLabel: l10n.gratitudeJoyLabel,
          rememberTitle: l10n.gratitudeRememberTitle,
          rememberBody: l10n.gratitudeRememberBody,
          affirmTitle: l10n.gratitudeAffirmTitle,
          affirmBody: l10n.gratitudeAffirmBody,
        );
      case ReflectionKind.selfLove:
        return ReflectionCopy(
          prompt: l10n.selfLoveStepPrompt,
          hint: l10n.selfLoveHint,
          itemLabel: l10n.selfLoveItemLabel,
          rememberTitle: l10n.selfLoveRememberTitle,
          rememberBody: l10n.selfLoveRememberBody,
          affirmTitle: l10n.selfLoveAffirmTitle,
          affirmBody: l10n.selfLoveAffirmBody,
        );
      case ReflectionKind.mindfulness:
        return ReflectionCopy(
          prompt: l10n.mindfulnessStepPrompt,
          hint: l10n.mindfulnessHint,
          itemLabel: l10n.mindfulnessItemLabel,
          rememberTitle: l10n.mindfulnessRememberTitle,
          rememberBody: l10n.mindfulnessRememberBody,
          affirmTitle: l10n.mindfulnessAffirmTitle,
          affirmBody: l10n.mindfulnessAffirmBody,
        );
    }
  }
}
