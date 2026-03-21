import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/marketplace_profile.dart';

class ProfileDetailHeader extends StatelessWidget {
  const ProfileDetailHeader({
    super.key,
    required this.profile,
    this.heroTagPrefix = 'all',
  });

  final MarketplaceProfile profile;
  final String heroTagPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Hero(
            tag: 'marketplace_avatar_${heroTagPrefix}_${profile.id}',
            child: CircleAvatar(
              radius: 40.r,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.15),
              child: Text(
                profile.fullName.isNotEmpty ? profile.fullName[0] : '?',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.fullName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (profile.isVerified) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.all(2.r),
                  decoration: BoxDecoration(
                    color: statusColors.verified.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    size: 18.r,
                    color: statusColors.verified,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            [
              l10n.homeAgeSuffix(profile.age),
              profile.gender == 'M' ? l10n.homeGenderMale : l10n.homeGenderFemale,
              if (profile.heightCm != null) l10n.homeHeightCm(profile.heightCm!),
            ].join(' · '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          if (profile.managerName != null || profile.regionName != null)
            Text(
              [
                if (profile.managerName != null) profile.managerName!,
                if (profile.regionName != null) profile.regionName!,
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}
