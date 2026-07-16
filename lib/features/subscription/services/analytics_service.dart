import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class AnalyticsService {
  static Future<void> identify(String uid) async {
    try {
      await Posthog().identify(userId: uid);
    } catch (e) {
      debugPrint('[AnalyticsService] identify failed: $e');
    }
  }

  static Future<void> reset() async {
    try {
      await Posthog().reset();
    } catch (e) {
      debugPrint('[AnalyticsService] reset failed: $e');
    }
  }

  static Future<void> capture(String event, [Map<String, Object>? props]) async {
    try {
      await Posthog().capture(eventName: event, properties: props);
    } catch (e) {
      debugPrint('[AnalyticsService] capture $event failed: $e');
    }
  }

  // Auth
  static const signIn = 'sign_in';
  static const signOut = 'sign_out';
  static const accountDeleted = 'account_deleted';

  // Alarms
  static const alarmCreated = 'alarm_created';
  static const alarmUpdated = 'alarm_updated';
  static const alarmDeleted = 'alarm_deleted';
  static const alarmToggled = 'alarm_toggled';

  // Alarm ring lifecycle
  static const alarmRingStarted = 'alarm_ring_started';
  static const alarmRingDismissed = 'alarm_ring_dismissed';

  // Activities
  static const activitySaved = 'activity_saved';

  // Subscription
  static const subscriptionActivated = 'subscription_activated';
  static const subscriptionLost = 'subscription_lost';

  // Referral
  static const referralRedeemAttempt = 'referral_redeem_attempt';
  static const referralRedeemSuccess = 'referral_redeem_success';
  static const referralRedeemFailed = 'referral_redeem_failed';

  // Achievements
  static const badgeEarned = 'badge_earned';

  // Onboarding
  static const onboardingStep = 'onboarding_step';

  // Navigation
  static const navTabSelected = 'nav_tab_selected';

  // Settings
  static const settingsNotificationsToggled = 'settings_notifications_toggled';
  static const settingsDarkModeToggled = 'settings_dark_mode_toggled';

  // Mood
  static const moodRecorded = 'mood_recorded'; // props: {mood, source}

  // Community
  static const communitySegmentSelected = 'community_segment_selected';
  static const communityPostLiked = 'community_post_liked';

  // Tools
  static const toolSessionStarted = 'tool_session_started'; // props: {tool}
  static const toolSessionCompleted = 'tool_session_completed'; // props: {tool}

  // Chat
  static const chatConversationCreated = 'chat_conversation_created';
  static const chatConversationDeleted = 'chat_conversation_deleted';
  static const chatMessageSent = 'chat_message_sent';
  static const chatVoiceUsed = 'chat_voice_used';
  static const chatFormAnswered = 'chat_form_answered';
  static const chatMissionAccepted = 'chat_mission_accepted';
  static const chatMissionDeclined = 'chat_mission_declined';
}
