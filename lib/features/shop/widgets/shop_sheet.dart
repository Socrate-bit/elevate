import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../subscription/services/analytics_service.dart';
import '../cubit/shop_cubit.dart';

/// Opens the shop as a half-height modal sheet, leaving the streak and shop
/// icons above it visible. Flags the [ShopCubit] open/closed around its
/// lifetime so the home top bar swaps its settings icon for the coin balance.
Future<void> showShopSheet(BuildContext context) async {
  final shop = context.read<ShopCubit>();
  shop.open();
  AnalyticsService.capture(AnalyticsService.shopOpened);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // No scrim — the rest of the screen stays fully visible while shopping.
    barrierColor: Colors.transparent,
    builder: (_) => const _ShopSheet(),
  );
  shop.dismiss();
}

/// A shop tab: its icon asset (used both in the tab bar and the coming-soon
/// body) plus the call-to-action shown in its body.
class _ShopTab {
  final String icon;
  final String cta;

  const _ShopTab({required this.icon, required this.cta});
}

/// Half-height shop modal with a tab per customization category. Each tab is a
/// coming-soon placeholder with its own call-to-action.
class _ShopSheet extends StatelessWidget {
  const _ShopSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const iconBase = 'assets/shop/shop_tab';
    final tabs = <_ShopTab>[
      _ShopTab(icon: '$iconBase/image.png', cta: l10n.shopCtaBackground),
      _ShopTab(icon: '$iconBase/cap.png', cta: l10n.shopCtaHat),
      _ShopTab(icon: '$iconBase/safety-glasses.png', cta: l10n.shopCtaGlass),
      _ShopTab(icon: '$iconBase/scarf.png', cta: l10n.shopCtaScarf),
      _ShopTab(icon: '$iconBase/palette.png', cta: l10n.shopCtaColor),
    ];

    // Half the screen height so the streak and shop icons above stay visible.
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.5,
      child: DefaultTabController(
        length: tabs.length,
        child: Container(
          decoration: BoxDecoration(
            color: HomePalette.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Grab handle.
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: HomePalette.subtitleGrey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Category tabs — icon only, spread across the full width,
              // black when selected, grey otherwise.
              TabBar(
                indicatorColor: Colors.black,
                indicatorWeight: 3,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                onTap: (_) => HapticFeedback.selectionClick(),
                tabs: [for (final t in tabs) Tab(icon: _TabIcon(t.icon))],
              ),
              Expanded(
                child: TabBarView(
                  children: [for (final t in tabs) _ComingSoon(tab: t)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab bar icon that tints itself with the current [IconTheme] colour, which
/// TabBar animates between grey (unselected) and black (selected).
class _TabIcon extends StatelessWidget {
  final String asset;

  const _TabIcon(this.asset);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 34.w,
      height: 34.w,
      color: IconTheme.of(context).color,
    );
  }
}

/// Placeholder body for a shop tab: the category icon, its call-to-action, and
/// a "coming soon" note — vertically centered.
class _ComingSoon extends StatelessWidget {
  final _ShopTab tab;

  const _ComingSoon({required this.tab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              tab.icon,
              width: 64.w,
              height: 64.w,
              color: HomePalette.titleDark,
            ),
            SizedBox(height: 16.h),
            Text(
              tab.cta,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.titleDark,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: HomePalette.editPillBg,
                borderRadius: BorderRadius.circular(21.r),
              ),
              child: Text(
                l10n.shopComingSoon,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.editGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
