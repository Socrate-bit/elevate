import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/utils/haptic_utils.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../auth/auth_service.dart';
import '../../subscription/services/analytics_service.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../../subscription/cubit/subscription_state.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/referral_code_dialog.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _notifications = true;

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLogoutTitle),
        content: Text(l10n.settingsLogoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.settingsLogoutCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.settingsLogoutConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.signOut();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountTitle),
        content: Text(l10n.settingsDeleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.settingsDeleteAccountCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.settingsDeleteAccountConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AuthService.deleteAccount();
    } on FirebaseAuthException catch (e) {
      debugPrint('[SettingsScreen] deleteAccount failed: ${e.code}');
      final msg = e.code == 'requires-recent-login'
          ? l10n.settingsDeleteAccountReauthRequired
          : l10n.settingsDeleteAccountError;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      debugPrint('[SettingsScreen] deleteAccount failed: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsDeleteAccountError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsTitle,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 24.h),
              _SectionTitle(title: l10n.settingsAccount),
              BlocBuilder<SubscriptionCubit, SubscriptionState>(
                builder: (context, subState) => _SettingsCard(children: [
                  _LinkRow(
                    icon: Icons.card_membership_outlined,
                    label: l10n.settingsUserType,
                    value: subState.userType.name,
                    onTap: () {},
                  ),
                ]),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: withHaptic(() => showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<SubscriptionCubit>(),
                        child: const ReferralCodeDialog(),
                      ),
                    )),
                child: _SettingsCard(children: [
                  _LinkRow(
                    icon: Icons.redeem_outlined,
                    label: l10n.settingsEnterReferralCode,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<SubscriptionCubit>(),
                        child: const ReferralCodeDialog(),
                      ),
                    ),
                  ),
                ]),
              ),
              SizedBox(height: 16.h),
              _SectionTitle(title: l10n.settingsApp),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settings) => _SettingsCard(children: [
                  _ToggleRow(
                    icon: Icons.notifications_outlined,
                    label: l10n.settingsNotifications,
                    value: _notifications,
                    onChanged: (v) {
                      setState(() => _notifications = v);
                      AnalyticsService.capture(
                        AnalyticsService.settingsNotificationsToggled,
                        {'enabled': v},
                      );
                    },
                  ),
                  const _Divider(),
                  _ToggleRow(
                    icon: Icons.dark_mode_outlined,
                    label: l10n.settingsDarkMode,
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (v) {
                      context
                          .read<SettingsCubit>()
                          .setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                      AnalyticsService.capture(
                        AnalyticsService.settingsDarkModeToggled,
                        {'enabled': v},
                      );
                    },
                  ),
                ]),
              ),
              SizedBox(height: 16.h),
              _SectionTitle(title: l10n.settingsAbout),
              _SettingsCard(children: [
                _LinkRow(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.settingsPrivacyPolicy,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
                const _Divider(),
                _LinkRow(
                  icon: Icons.description_outlined,
                  label: l10n.settingsTermsOfService,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TermsConditionsScreen(),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 16.h),
              _SettingsCard(children: [
                _ActionRow(
                  icon: Icons.logout,
                  label: l10n.settingsLogout,
                  color: Colors.red,
                  onTap: () => _confirmLogout(context),
                ),
                const _Divider(),
                _ActionRow(
                  icon: Icons.delete_forever_outlined,
                  label: l10n.settingsDeleteAccount,
                  color: Colors.red,
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ]),
              SizedBox(height: 16.h),
              // Empty Dev tools placeholder — drop project-specific debug
              // actions in here (e.g. Firestore dumps, feature-flag toggles).
              _SectionTitle(title: l10n.settingsDevTools),
              _SettingsCard(children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    l10n.settingsDevToolsEmpty,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: c.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                // TODO: add per-project dev tools here.
              ]),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  l10n.settingsVersion,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: c.textSecondary),
          SizedBox(width: 12.w),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Switch(
            value: value,
            activeThumbColor: c.primary,
            onChanged: withHapticValue(onChanged),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: c.textSecondary),
            SizedBox(width: 12.w),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            if (value != null)
              Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: Text(
                  value!,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: c.textSecondary,
                  ),
                ),
              ),
            Icon(Icons.chevron_right, size: 18.sp, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 48.w),
      child: Divider(height: 1, color: c.separator),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 12.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
