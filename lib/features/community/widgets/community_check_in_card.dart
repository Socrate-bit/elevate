import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_mock_data.dart';

/// "Community check-in" card with a row of 5 tappable mood faces.
class CommunityCheckInCard extends StatelessWidget {
  const CommunityCheckInCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.communityMoodGreat,
      l10n.communityMoodGood,
      l10n.communityMoodOkay,
      l10n.communityMoodStruggling,
      l10n.communityMoodReallyHard,
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: CommunityPalette.card,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.communityCheckInTitle,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: CommunityPalette.textDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            l10n.communityCheckInSubtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: CommunityPalette.subtitleGrey,
            ),
          ),
          SizedBox(height: 14.h),
          BlocBuilder<CommunityCubit, CommunityState>(
            buildWhen: (p, c) => p.selectedMood != c.selectedMood,
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  CommunityMockData.moodAssets.length,
                  (i) => _MoodFace(
                    asset: CommunityMockData.moodAssets[i],
                    label: labels[i],
                    selected: state.selectedMood == i,
                    onTap: () => context.read<CommunityCubit>().selectMood(i),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A single mood face with its label; dims when another mood is selected.
class _MoodFace extends StatelessWidget {
  final String asset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MoodFace({
    required this.asset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Column(
        children: [
          AnimatedScale(
            scale: selected ? 1.12 : 1,
            duration: const Duration(milliseconds: 150),
            child: Image.asset(asset, width: 40.w, height: 40.w),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 52.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? CommunityPalette.textDark
                    : CommunityPalette.subtitleGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
