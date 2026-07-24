import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/trophies_cubit.dart';
import '../cubit/trophies_state.dart';
import '../data/trophy_badges.dart';
import '../models/trophy.dart';
import '../widgets/hexagon_badge.dart';
import 'trophy_detail_screen.dart';

/// Gallery of every earned trophy, opened from the Journal. A square-cell grid
/// of hexagon badges; tapping one opens its citation detail page.
class TrophiesGridScreen extends StatelessWidget {
  const TrophiesGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrophiesCubit()..start(),
      child: const _TrophiesView(),
    );
  }
}

class _TrophiesView extends StatelessWidget {
  const _TrophiesView();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: c.textPrimary,
            size: 20.sp,
          ),
          onPressed: withHaptic(() => Navigator.of(context).maybePop()),
        ),
        title: Text(
          l10n.trophiesTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<TrophiesCubit, TrophiesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.trophies.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: Text(
                  l10n.trophiesEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp, color: c.textSecondary),
                ),
              ),
            );
          }
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.w,
              crossAxisSpacing: 16.w,
              childAspectRatio: 1,
            ),
            itemCount: state.trophies.length,
            itemBuilder: (context, i) => _TrophyCell(trophy: state.trophies[i]),
          );
        },
      ),
    );
  }
}

/// Square card: hexagon badge over a short citation preview.
class _TrophyCell extends StatelessWidget {
  final Trophy trophy;

  const _TrophyCell({required this.trophy});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: withHaptic(() {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrophyDetailScreen(trophy: trophy)),
        );
      }),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: c.separator),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HexagonBadge(
              size: 76.w,
              color: trophyColor(trophy.colorKey),
              icon: trophyIcon(trophy.iconKey),
            ),
            SizedBox(height: 10.h),
            Text(
              trophy.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              trophy.quote,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
                color: c.textSecondary,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
