import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_enums.dart';

/// Horizontal row of feed filter chips (For you / Recent / Following / Support).
class CommunityFilterChips extends StatelessWidget {
  const CommunityFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = <(CommunityFilter, IconData, String)>[
      (CommunityFilter.forYou, Icons.auto_awesome, l10n.communityFilterForYou),
      (
        CommunityFilter.recent,
        Icons.schedule_rounded,
        l10n.communityFilterRecent,
      ),
      (
        CommunityFilter.following,
        Icons.person_outline_rounded,
        l10n.communityFilterFollowing,
      ),
      (
        CommunityFilter.support,
        Icons.volunteer_activism_rounded,
        l10n.communityFilterSupport,
      ),
    ];

    return BlocBuilder<CommunityCubit, CommunityState>(
      buildWhen: (p, c) => p.filter != c.filter,
      builder: (context, state) {
        return SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: chips.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final (filter, icon, label) = chips[i];
              return _FilterChip(
                icon: icon,
                label: label,
                selected: state.filter == filter,
                onTap: () =>
                    context.read<CommunityCubit>().selectFilter(filter),
              );
            },
          ),
        );
      },
    );
  }
}

/// A single filter chip.
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? CommunityPalette.chipSelectedText
        : CommunityPalette.textBrown;
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Translucent chips so the page tint shows through.
          color: selected
              ? CommunityPalette.chipSelected.withValues(alpha: 0.7)
              : CommunityPalette.card.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: fg),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
