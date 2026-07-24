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
  String get navChat => 'Chat';

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

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatModelName => 'Gemini';

  @override
  String get chatHistoryTitle => 'Conversations';

  @override
  String get chatHistorySearchHint => 'Rechercher';

  @override
  String get chatHistoryEmpty => 'Aucune conversation';

  @override
  String get chatHistoryEmptyHint => 'Touchez + pour démarrer une discussion.';

  @override
  String get chatGreeting => 'Comment puis-je vous aider ce soir ?';

  @override
  String get chatStartChat => 'Commencer la discussion';

  @override
  String get chatComposerHint => 'Message';

  @override
  String get chatSend => 'Envoyer';

  @override
  String get chatNewConversation => 'Nouveau chat';

  @override
  String get chatUntitledConversation => 'Nouvelle conversation';

  @override
  String get chatVoiceListening => 'À l\'écoute…';

  @override
  String get chatVoiceUnavailable => 'La saisie vocale est indisponible.';

  @override
  String get chatVoicePermissionDenied => 'Permission du microphone refusée.';

  @override
  String get chatSendFailed => 'Impossible d\'envoyer le message. Réessayez.';

  @override
  String get chatDelete => 'Supprimer';

  @override
  String get chatDeleteConfirm => 'Supprimer cette conversation ?';

  @override
  String get chatDeleteCancel => 'Annuler';

  @override
  String get chatRelativeJustNow => 'à l\'instant';

  @override
  String chatRelativeSecondsAgo(int n) {
    return 'il y a $n secondes';
  }

  @override
  String chatRelativeMinutesAgo(int n) {
    return 'il y a $n minutes';
  }

  @override
  String chatRelativeHoursAgo(int n) {
    return 'il y a $n heures';
  }

  @override
  String chatRelativeDaysAgo(int n) {
    return 'il y a $n jours';
  }

  @override
  String get chatMissionStart => 'Démarrer la mission';

  @override
  String get chatMissionDecline => 'Pas maintenant';

  @override
  String get chatMissionAccepted => 'Mission lancée';

  @override
  String get chatMissionDeclined => 'Peut-être plus tard';

  @override
  String get chatMissionValidated => 'Je viens de terminer la mission !';

  @override
  String get chatMissionSetUp => 'Configurer cette mission';

  @override
  String get dismissMissionTimeToWakeUp => 'Il est temps de se lever !';

  @override
  String dismissMissionLabel(int n, int total, String name) {
    return 'Mission $n sur $total : $name';
  }

  @override
  String get dismissStartMission => 'Commencer la mission';

  @override
  String dismissMathProgress(int n, int total) {
    return 'Problème $n sur $total';
  }

  @override
  String get dismissMathWrong => 'Mauvaise réponse, réessayez';

  @override
  String get dismissMathConfirm => 'Vérifier';

  @override
  String get dismissShakePrompt => 'Secouez votre téléphone !';

  @override
  String dismissSpeechTryAgain(int score) {
    return 'Réessayez : $score%';
  }

  @override
  String dismissSpeechProgress(int n, int total) {
    return 'Affirmation $n sur $total';
  }

  @override
  String get dismissSpeechSay => 'Dites ceci à voix haute :';

  @override
  String get dismissSpeechListening => 'Écoute en cours…';

  @override
  String get dismissSpeechTapToSpeak => 'Appuyez pour parler';

  @override
  String get dismissSpeechMicUnavailable => 'Microphone indisponible';

  @override
  String dismissPhotoPrompt(String target) {
    return 'Trouvez : $target';
  }

  @override
  String dismissPhotoNotDetected(String target) {
    return 'Impossible de détecter $target';
  }

  @override
  String dismissPhotoError(String error) {
    return 'Erreur : $error';
  }

  @override
  String dismissPhotoChecking(String target) {
    return 'Vérification de $target…';
  }

  @override
  String get dismissPhotoStarting => 'Démarrage de la caméra…';

  @override
  String get dismissPhotoPickingTarget => 'Sélection de la cible…';

  @override
  String get dismissFeedbackMoveIntoFrame => 'Entrez dans le cadre';

  @override
  String get dismissFeedbackKeepGoing => 'Continuez !';

  @override
  String get dismissFeedbackPushupPosition =>
      'Mettez-vous en position de pompes';

  @override
  String get dismissFeedbackStartPushups => 'Commencez les pompes';

  @override
  String get dismissFeedbackPushupGoDeeper => 'Allez plus bas';

  @override
  String get dismissFeedbackSquatPosition => 'Genoux au-dessus des chevilles';

  @override
  String get dismissFeedbackStartSquats => 'Commencez les squats';

  @override
  String get dismissFeedbackSquatGoDeeper => 'Descendez plus bas';

  @override
  String get dismissRepStarting => 'Démarrage de la caméra…';

  @override
  String dismissRepPrompt(int count, String name) {
    return 'Faites $count $name';
  }

  @override
  String dismissRepOf(int target) {
    return 'sur $target';
  }

  @override
  String get missionComplete => 'Mission accomplie !';

  @override
  String get missionCompleteMessage => 'Excellent travail ! Continuez.';

  @override
  String get missionPickerTitle => 'Missions';

  @override
  String get missionPickerSubtitle => 'Choisissez une mission et commencez';

  @override
  String get breathingPhaseInhale => 'Inspirez';

  @override
  String get breathingPhaseHold => 'Retenez';

  @override
  String get breathingPhaseExhale => 'Expirez';

  @override
  String breathingRoundLabel(int current, int total) {
    return 'Cycle $current / $total';
  }

  @override
  String get toolSessionDone => 'Terminé';

  @override
  String get toolSessionLoadError =>
      'Échec du chargement. Touchez pour réessayer.';

  @override
  String get reflectionContinue => 'Continuer';

  @override
  String get reflectionDone => 'Terminé';

  @override
  String get reflectionSaveError => 'Échec de l\'enregistrement. Réessaie.';

  @override
  String get gratitudeStepPrompt =>
      'Quelles sont 3 choses qui t\'ont apporté de la joie cette semaine ?';

  @override
  String get gratitudeHint => 'Ça peut être aussi simple qu\'un bon repas…';

  @override
  String gratitudeJoyLabel(int number) {
    return 'Joie $number';
  }

  @override
  String get gratitudeRememberTitle => 'Prends un instant';

  @override
  String get gratitudeRememberBody =>
      'Souviens-toi de chacune, et revis le sentiment qu\'elle t\'a procuré.';

  @override
  String get gratitudeAffirmTitle => 'Sois reconnaissant';

  @override
  String get gratitudeAffirmBody =>
      'Ressens de la gratitude pour ces moments — laisse-la s\'installer.';

  @override
  String get selfLoveStepPrompt =>
      'Quelles sont 3 choses que tu apprécies chez toi ?';

  @override
  String get selfLoveHint =>
      'Grande ou petite — une force, un effort, une gentillesse.';

  @override
  String selfLoveItemLabel(int number) {
    return 'Qualité $number';
  }

  @override
  String get selfLoveRememberTitle => 'Prends un instant';

  @override
  String get selfLoveRememberBody =>
      'Relis chacune pour toi-même, avec douceur et sans jugement.';

  @override
  String get selfLoveAffirmTitle => 'Sois bienveillant envers toi';

  @override
  String get selfLoveAffirmBody =>
      'Laisse cette bienveillance s\'installer — tu le mérites.';

  @override
  String get mindfulnessStepPrompt =>
      'Quelles sont 3 choses que tu remarques maintenant ?';

  @override
  String get mindfulnessHint =>
      'Un son, une sensation, quelque chose que tu vois.';

  @override
  String mindfulnessItemLabel(int number) {
    return 'Sensation $number';
  }

  @override
  String get mindfulnessRememberTitle => 'Prends un instant';

  @override
  String get mindfulnessRememberBody =>
      'Reviens à chacune, et reste avec elle le temps d\'une respiration.';

  @override
  String get mindfulnessAffirmTitle => 'Sois présent';

  @override
  String get mindfulnessAffirmBody =>
      'Repose-toi ici un instant — il n\'y a nulle part où aller.';

  @override
  String get moodPickerTitle => 'Comment vas-tu ?';

  @override
  String get moodPickerRad => 'génial';

  @override
  String get moodPickerGood => 'bien';

  @override
  String get moodPickerMeh => 'bof';

  @override
  String get moodPickerBad => 'mal';

  @override
  String get moodPickerAwful => 'terrible';

  @override
  String get moodSectionTitle => 'Humeur';

  @override
  String get homeActionsTitle => 'Actions';

  @override
  String get homeActionsEmpty =>
      'Aucune action. Appuyez sur + pour en ajouter.';

  @override
  String get homeHabitsTitle => 'Habitudes';

  @override
  String get homeHabitsEmpty =>
      'Aucune habitude. Appuyez sur + pour en ajouter.';

  @override
  String get homeAddTitle => 'Et maintenant ?';

  @override
  String get homeAddMoodDesc => 'Notez votre humeur';

  @override
  String get homeAddMissionDesc => 'Démarrer une mission';

  @override
  String get homeAddBreathingTitle => 'Respiration';

  @override
  String get homeAddBreathingDesc => 'Exercice de respiration';

  @override
  String get routinePickerTitle => 'Que voulez-vous ajouter ?';

  @override
  String get routinePickerSubtitle =>
      'Les actions sont uniques. Les habitudes se répètent.';

  @override
  String get routineTypeAction => 'Action';

  @override
  String get routineTypeActionDesc => 'Une tâche unique.';

  @override
  String get routineTypeHabit => 'Habitude';

  @override
  String get routineTypeHabitDesc => 'Se répète les jours choisis.';

  @override
  String get routineFormNewAction => 'Nouvelle action';

  @override
  String get routineFormNewHabit => 'Nouvelle habitude';

  @override
  String get routineFormEditTitle => 'Modifier';

  @override
  String get routineFormCreate => 'Créer';

  @override
  String get routineFormNameHint => 'Nom';

  @override
  String get routineFormDescriptionHint => 'Description (optionnelle)';

  @override
  String get routineFormColorLabel => 'Couleur';

  @override
  String get routineFormEmojiLabel => 'Choisir un emoji';

  @override
  String get routineFormXpLabel => 'Récompense';

  @override
  String get routineFormObjectCheckLabel => 'Vérification photo';

  @override
  String get routineFormObjectCheckHint =>
      'ex. brosse à dents, livre, bouteille d\'eau';

  @override
  String get routineFormDateLabel => 'Date';

  @override
  String get routineFormPickDate => 'Choisir une date';

  @override
  String get routineFormPickTime => 'Choisir une heure';

  @override
  String get routineFormClear => 'Effacer';

  @override
  String get routineFormAlarmLabel => 'Rappel';

  @override
  String get routineFormAlarmHint =>
      'Recevez une notification à l\'heure prévue.';

  @override
  String get routineFormDeleteTitle => 'Supprimer ?';

  @override
  String get routineFormDeleteMessage => 'Cela retire l\'élément du suivi.';

  @override
  String get routineFormDeleteCancel => 'Annuler';

  @override
  String get routineFormDeleteConfirm => 'Supprimer';

  @override
  String get routineCardTapToValidate => 'Appuyez pour valider';

  @override
  String routineCardObjectCheck(String object) {
    return 'Photo : $object';
  }

  @override
  String get routineHabitNoSchedule => 'Pas de planning';

  @override
  String chatRoutineCreated(String name) {
    return 'Créé \'$name\'';
  }

  @override
  String chatRoutineUpdated(String name) {
    return 'Modifié \'$name\'';
  }

  @override
  String chatRoutineDeleted(String name) {
    return 'Supprimé \'$name\'';
  }

  @override
  String get chatActionStartNow => 'Commencer maintenant';

  @override
  String get chatActionDone => 'Terminé';

  @override
  String get chatActionCompleted => 'Je viens de le faire !';

  @override
  String homePageGreeting(String name) {
    return 'Bon après-midi, $name 🌿';
  }

  @override
  String get homePageHeadline => 'Tu t\'en sors très bien aujourd\'hui !';

  @override
  String get homePageMessage => 'Message';

  @override
  String get homePageCall => 'Appel';

  @override
  String get homePageCrisisMode => 'Mode Crise';

  @override
  String homePageQuestProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get homePageTodaysPlan => 'Plan du jour';

  @override
  String get homePageTodaysPlanSubtitle => 'Petits pas, grands changements.';

  @override
  String get homePagePlanEmpty =>
      'Rien de prévu aujourd\'hui. Appuyez sur + pour ajouter une tâche.';

  @override
  String get homePageEdit => 'Modifier';

  @override
  String homePageXp(int xp) {
    return '+ $xp XP';
  }

  @override
  String get adventureTitle => 'Aventure en forêt';

  @override
  String adventureStrikeProgress(int done, int total) {
    return '$done / $total coups';
  }

  @override
  String get adventureStartButton => 'Partir à l\'aventure';

  @override
  String get adventureDiscoverButton => 'Découvrir la surprise';

  @override
  String adventureRemaining(int h, int m) {
    return '${h}h ${m}min restantes';
  }

  @override
  String get adventureSuccessLabel => 'Trophée obtenu';

  @override
  String get navJournal => 'Journal';

  @override
  String get navTools => 'Outils';

  @override
  String get navQuest => 'Quête';

  @override
  String get questPageTitle => 'Quêtes';

  @override
  String get questPageComingSoon => 'Les quêtes arrivent bientôt.';

  @override
  String get chatPageCalmMode => 'Mode calme';

  @override
  String get chatPageCompanionName => 'Appy';

  @override
  String get chatPageCompanionSubtitle => 'Votre compagnon bienveillant';

  @override
  String get chatPageToday => 'Aujourd\'hui';

  @override
  String get chatPageYesterday => 'Hier';

  @override
  String get chatPageStartConversation => 'Démarrer une conversation';

  @override
  String get chatPageSuggestTalkDay => 'Parler de ma journée';

  @override
  String get chatPageSuggestComfort => 'J\'ai besoin de réconfort';

  @override
  String get chatPageSuggestReflect => 'M\'aider à réfléchir';

  @override
  String get chatPageComposerHint => 'Votre message';

  @override
  String get chatInsightsFormingTitle => 'Vos insights se dessinent';

  @override
  String get chatInsightsFormingBody =>
      'Ash a besoin d\'un peu plus de contexte dans cette conversation avant de pouvoir vous refléter un insight.';

  @override
  String get chatInsightsReadyTitle => 'Un insight est prêt';

  @override
  String get chatInsightsReadyBody =>
      'Ash a repéré dans cette conversation quelque chose qui mérite de vous être reflété.';

  @override
  String get chatInsightsContinue => 'Continuer la conversation';

  @override
  String get chatInsightsReveal => 'Révéler l\'insight';

  @override
  String get chatInsightCardLabel => 'Insight';

  @override
  String get chatInsightCardCta => 'Lire l\'insight';

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalMonthlyInsight => 'Bilan du mois';

  @override
  String get journalInputCues => 'Pistes d\'écriture';

  @override
  String get shopTitle => 'Boutique';

  @override
  String get shopComingSoon => 'Bientôt disponible';

  @override
  String get shopTabBackground => 'Décor';

  @override
  String get shopTabHat => 'Chapeau';

  @override
  String get shopTabGlass => 'Lunettes';

  @override
  String get shopTabScarf => 'Écharpe';

  @override
  String get shopTabColor => 'Couleur';

  @override
  String get shopTabFurniture => 'Mobilier';

  @override
  String get shopCtaBackground => 'Changer le décor';

  @override
  String get shopCtaHat => 'Acheter un chapeau';

  @override
  String get shopCtaGlass => 'Acheter des lunettes';

  @override
  String get shopCtaScarf => 'Acheter une écharpe';

  @override
  String get shopCtaColor => 'Changer la couleur';

  @override
  String get shopCtaFurniture => 'Acheter du mobilier';
}
