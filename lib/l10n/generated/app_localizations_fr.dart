// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Skeleton';

  @override
  String get generalOk => 'OK';

  @override
  String get generalDefault => 'Par défaut';

  @override
  String get navHome => 'Accueil';

  @override
  String get navInsights => 'Stats';

  @override
  String get navSettings => 'Réglages';

  @override
  String get daySingleSun => 'D';

  @override
  String get daySingleMon => 'L';

  @override
  String get daySingleTue => 'M';

  @override
  String get daySingleWed => 'M';

  @override
  String get daySingleThu => 'J';

  @override
  String get daySingleFri => 'V';

  @override
  String get daySingleSat => 'S';

  @override
  String get daySun => 'Dim';

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Jeu';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sam';

  @override
  String get daySundayFull => 'Dimanche';

  @override
  String get dayMondayFull => 'Lundi';

  @override
  String get dayTuesdayFull => 'Mardi';

  @override
  String get dayWednesdayFull => 'Mercredi';

  @override
  String get dayThursdayFull => 'Jeudi';

  @override
  String get dayFridayFull => 'Vendredi';

  @override
  String get daySaturdayFull => 'Samedi';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Fév';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Avr';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJun => 'Juin';

  @override
  String get monthJul => 'Juil';

  @override
  String get monthAug => 'Aoû';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Déc';

  @override
  String get alarmStop => 'Arrêter';

  @override
  String get alarmsTitle => 'Alarmes';

  @override
  String get alarmsEmpty => 'Aucune alarme';

  @override
  String get alarmsEmptyHint => 'Touchez + pour en ajouter une.';

  @override
  String get alarmsOneTime => 'Unique';

  @override
  String get alarmsEveryDay => 'Tous les jours';

  @override
  String get alarmsWeekdays => 'En semaine';

  @override
  String alarmsDefaultName(int n) {
    return 'Alarme #$n';
  }

  @override
  String get alarmFormNewAlarm => 'Nouvelle alarme';

  @override
  String get alarmFormEditAlarm => 'Modifier l\'alarme';

  @override
  String get alarmFormAlarmName => 'Nom de l\'alarme';

  @override
  String get alarmFormAlarmTime => 'Heure';

  @override
  String get alarmFormSetTime => 'Régler l\'heure';

  @override
  String get alarmFormDone => 'OK';

  @override
  String get alarmFormScheduled => 'Planifiée';

  @override
  String get alarmFormOneTime => 'Unique';

  @override
  String get alarmFormRepeatOn => 'Répéter le';

  @override
  String get alarmFormCreateAlarm => 'Créer l\'alarme';

  @override
  String get alarmFormSaveChanges => 'Enregistrer';

  @override
  String get homeNextAlarm => 'Prochaine alarme';

  @override
  String get homeToday => 'Aujourd\'hui';

  @override
  String get homeTomorrow => 'Demain';

  @override
  String get homePastAlarm => 'Déjà passée';

  @override
  String homeRingsIn(int h, int m) {
    return 'Sonne dans ${h}h ${m}m';
  }

  @override
  String get homeNoActiveAlarm => 'Aucune alarme active';

  @override
  String get homeNoActiveAlarmHint => 'Touchez pour en ajouter une.';

  @override
  String get activityHistoryTitle => 'Activité';

  @override
  String get activityHistoryEmpty => 'Aucune activité';

  @override
  String get activityHistoryMissed => 'Manquée';

  @override
  String get insightsTitle => 'Stats';

  @override
  String get insightsWeek => 'Semaine';

  @override
  String get insightsMonth => 'Mois';

  @override
  String get insightsAllTime => 'Tout';

  @override
  String get insightsStats => 'Statistiques';

  @override
  String get insightsAvgTime => 'Heure moy.';

  @override
  String get insightsAvgDuration => 'Durée moy.';

  @override
  String get insightsDayStreak => 'Série';

  @override
  String get insightsBadgesEarned => 'Badges';

  @override
  String get milestonesTitle => 'Objectifs';

  @override
  String get milestonesDayStreak => 'Série';

  @override
  String get milestonesBadgesEarned => 'Badges';

  @override
  String milestonesLongestStreak(int n) {
    return '$n';
  }

  @override
  String get milestonesLongestStreakLabel => 'Série la plus longue';

  @override
  String get milestonesStreakBadges => 'Badges de série';

  @override
  String get milestonesAchievementBadges => 'Défis';

  @override
  String get milestonesHowStreaksWork => 'Comment ça marche';

  @override
  String get milestonesStreakExplanation =>
      'Enregistrez une activité chaque jour pour conserver votre série. Jusqu\'à 2 jours manqués par semaine comptent comme des congélations et ne brisent pas la série.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsApp => 'App';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsDevTools => 'Outils dev';

  @override
  String get settingsDevToolsEmpty =>
      'Ajoutez des outils de debug spécifiques au projet ici.';

  @override
  String get settingsUserType => 'Plan';

  @override
  String get settingsEnterReferralCode => 'Entrer un code de parrainage';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsTermsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutTitle => 'Se déconnecter ?';

  @override
  String get settingsLogoutBody =>
      'Vous pourrez vous reconnecter à tout moment.';

  @override
  String get settingsLogoutCancel => 'Annuler';

  @override
  String get settingsLogoutConfirm => 'Se déconnecter';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get settingsDeleteAccountBody =>
      'Vos données seront supprimées définitivement.';

  @override
  String get settingsDeleteAccountCancel => 'Annuler';

  @override
  String get settingsDeleteAccountConfirm => 'Supprimer';

  @override
  String get settingsDeleteAccountError =>
      'Échec de la suppression du compte. Réessayez.';

  @override
  String get settingsDeleteAccountReauthRequired =>
      'Veuillez vous reconnecter avant de supprimer votre compte.';

  @override
  String get settingsVersion => 'v0.1.0';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans Skeleton';

  @override
  String get onboardingWelcomeSubtitle =>
      'Remplacez ce texte par un message de bienvenue.';

  @override
  String get onboardingInfoTitle => 'Page info 1';

  @override
  String get onboardingInfoBody =>
      'Remplacez ce texte par un contenu utile. Lorem ipsum dolor sit amet.';

  @override
  String get onboardingNotificationTitle => 'Restez informé';

  @override
  String get onboardingNotificationBody =>
      'Activez les notifications pour ne rien manquer.';

  @override
  String get onboardingEnableNotifications => 'Activer les notifications';

  @override
  String get onboardingMaybeLater => 'Plus tard';

  @override
  String get onboardingSignatureTitle => 'Signez votre engagement';

  @override
  String get onboardingSignatureBody => 'Signez ci-dessous pour confirmer.';

  @override
  String get onboardingSignatureClear => 'Effacer';

  @override
  String get onboardingSignatureCommit => 'Je m\'engage';

  @override
  String get onboardingLoadingTitle => 'Préparation de l\'app…';

  @override
  String get onboardingLoadingStep1 => 'Tâche 1';

  @override
  String get onboardingLoadingStep2 => 'Tâche 2';

  @override
  String get onboardingLoadingStep3 => 'Tâche 3';

  @override
  String get onboardingLoadingStep4 => 'Tâche 4';

  @override
  String get onboardingLoadingStep5 => 'Tâche 5';

  @override
  String get onboardingLoadingStep6 => 'Tâche 6';

  @override
  String get onboardingAgeRangeQuestion => 'Quelle est votre tranche d\'âge ?';

  @override
  String get onboardingGenderQuestion => 'Comment vous identifiez-vous ?';

  @override
  String get onboardingWhereHeard => 'Comment avez-vous découvert l\'app ?';

  @override
  String get onboardingYouTube => 'YouTube';

  @override
  String get onboardingFacebook => 'Facebook';

  @override
  String get onboardingTwitter => 'X (Twitter)';

  @override
  String get onboardingReddit => 'Reddit';

  @override
  String get onboardingAppStore => 'App Store';

  @override
  String get onboardingFriendFamily => 'Famille ou ami';

  @override
  String get onboardingOther => 'Autre';

  @override
  String get onboardingTimePickerTitle => 'Choisissez une heure';

  @override
  String get onboardingTimePickerSubtitle => 'Remplacez par votre question.';

  @override
  String get onboardingDayPickerTitle => 'Quels jours ?';

  @override
  String get onboardingDayPickerSubtitle =>
      'Choisissez les jours qui vous conviennent.';

  @override
  String get onboardingSignInTitle => 'Créez votre compte';

  @override
  String get onboardingSignInSubtitle =>
      'Synchronisez vos données entre vos appareils.';

  @override
  String get onboardingSignInApple => 'Continuer avec Apple';

  @override
  String get onboardingSignInGoogle => 'Continuer avec Google';

  @override
  String get onboardingSignInEmail => 'Continuer avec un e-mail';

  @override
  String get onboardingSkipForNow => 'Plus tard';

  @override
  String get onboardingAccountNotFound =>
      'Aucun compte trouvé pour cette connexion.';

  @override
  String get onboardingGoogleFailed =>
      'Échec de la connexion Google. Réessayez.';

  @override
  String get onboardingAppleFailed => 'Échec de la connexion Apple. Réessayez.';

  @override
  String get onboardingEmailLabel => 'E-mail';

  @override
  String get onboardingPasswordLabel => 'Mot de passe';

  @override
  String get onboardingEmailEmptyError =>
      'Saisissez votre e-mail et votre mot de passe.';

  @override
  String get onboardingEmailModalSignInTitle => 'Connexion';

  @override
  String get onboardingEmailModalSignUpTitle => 'Inscription';

  @override
  String get onboardingEmailSignInAction => 'Se connecter';

  @override
  String get onboardingEmailSignUpAction => 'S\'inscrire';

  @override
  String get onboardingEmailHasAccount => 'Déjà un compte ? Se connecter';

  @override
  String get onboardingEmailNoAccount => 'Pas de compte ? S\'inscrire';

  @override
  String get onboardingPaywallTitle => 'Essayez l\'app gratuitement';

  @override
  String get onboardingPaywallTryFree => 'Démarrer l\'essai';

  @override
  String get onboardingPaywallNoPayment => 'Aucun paiement maintenant';

  @override
  String get onboardingPaywallNoCommitment => 'Annulable à tout moment';

  @override
  String get onboardingPaywallPrivacy => 'Confidentialité';

  @override
  String get onboardingPaywallTerms => 'Conditions';

  @override
  String get onboardingPaywallRestore => 'Restaurer';

  @override
  String get onboardingPaywallEula => 'CLUF';

  @override
  String get onboardingTrialTitle =>
      'Nous vous préviendrons avant la facturation';

  @override
  String get onboardingTrialNoPayment => 'Aucun paiement maintenant';

  @override
  String get onboardingTrialContinueFree => 'Continuer gratuitement';

  @override
  String get onboardingTrialPrice => 'Puis 0,00 € / mois';

  @override
  String get onboardingReferralTitle => 'Code de parrainage ?';

  @override
  String get onboardingReferralSubtitle =>
      'Saisissez-le maintenant pour bénéficier d\'un avantage.';

  @override
  String get onboardingReferralLabel => 'Code de parrainage';

  @override
  String get onboardingReferralApplied => 'Code appliqué !';

  @override
  String get onboardingReferralInvalid => 'Code invalide.';

  @override
  String get onboardingReferralLimit =>
      'Ce code a atteint sa limite d\'utilisation.';

  @override
  String get onboardingRatingTitle => 'Apprécié des utilisateurs';

  @override
  String get onboardingRatingSubtitle => 'Lisez ce que d\'autres en disent.';

  @override
  String get onboardingRatingMarc => 'Marc';

  @override
  String get onboardingRatingMarcReview =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

  @override
  String get onboardingRatingSophie => 'Sophie';

  @override
  String get onboardingRatingSophieReview =>
      'Sed do eiusmod tempor incididunt ut labore et dolore magna.';

  @override
  String get onboardingRatingAlex => 'Alex';

  @override
  String get onboardingRatingAlexReview =>
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco.';

  @override
  String get referralTitle => 'Entrer un code de parrainage';

  @override
  String get referralCodeLabel => 'Code';

  @override
  String get referralSubmit => 'Appliquer';

  @override
  String get referralCancel => 'Annuler';

  @override
  String referralApplied(String plan) {
    return 'Code appliqué : $plan';
  }

  @override
  String get referralInvalid => 'Code invalide';

  @override
  String get referralUsageLimit => 'Limite d\'utilisation atteinte';

  @override
  String get referralError => 'Impossible de vérifier le code. Réessayez.';
}
