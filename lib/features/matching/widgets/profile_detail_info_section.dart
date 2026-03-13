import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../models/marketplace_profile.dart';

class ProfileDetailInfoSection extends StatelessWidget {
  const ProfileDetailInfoSection({super.key, required this.profile});

  final MarketplaceProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final infoItems = <_InfoItem>[
      _InfoItem(
        icon: Icons.work_outline_rounded,
        label: l10n.profileOccupation,
        value: profile.company != null
            ? '${profile.occupation} · ${profile.company}'
            : profile.occupation,
      ),
      if (profile.education != null)
        _InfoItem(
          icon: Icons.school_outlined,
          label: l10n.profileEducation,
          value: profile.education!,
        ),
      if (profile.heightCm != null)
        _InfoItem(
          icon: Icons.straighten_rounded,
          label: l10n.profileHeight,
          value: l10n.homeHeightCm(profile.heightCm!),
        ),
      if (profile.religion != null)
        _InfoItem(
          icon: Icons.brightness_7_outlined,
          label: l10n.profileReligion,
          value: profile.religion!,
        ),
      if (profile.annualIncomeRange != null)
        _InfoItem(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.profileIncome,
          value: profile.annualIncomeRange!,
        ),
      if (profile.drinking != null)
        _InfoItem(
          icon: Icons.local_bar_outlined,
          label: l10n.profileDrinking,
          value: _drinkingLabel(profile.drinking!, l10n),
        ),
      if (profile.smoking != null)
        _InfoItem(
          icon: Icons.smoking_rooms_outlined,
          label: l10n.profileSmoking,
          value: _smokingLabel(profile.smoking!, l10n),
        ),
      if (profile.maritalHistory != null)
        _InfoItem(
          icon: Icons.family_restroom_outlined,
          label: l10n.profileMaritalHistory,
          value: _maritalLabel(profile.maritalHistory!, l10n),
        ),
      if (profile.personalityType != null)
        _InfoItem(
          icon: Icons.psychology_outlined,
          label: l10n.profilePersonalityType,
          value: profile.personalityType!,
        ),
      if (profile.residenceArea != null)
        _InfoItem(
          icon: Icons.location_on_outlined,
          label: l10n.profileResidenceArea,
          value: profile.residenceArea!,
        ),
      if (profile.assetRange != null)
        _InfoItem(
          icon: Icons.account_balance_outlined,
          label: l10n.profileAssetRange,
          value: _assetLabel(profile.assetRange!, l10n),
        ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.55)
                  : theme.colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.45),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileDetailInfoTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                ...infoItems.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 18.r,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 50.w,
                            child: Text(
                              item.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              item.value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _drinkingLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'none' => l10n.regDrinkingNone,
      'social' => l10n.regDrinkingSocial,
      'regular' => l10n.regDrinkingRegular,
      _ => val,
    };
  }

  String _smokingLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'none' => l10n.regSmokingNone,
      'sometimes' => l10n.regSmokingSometimes,
      'regular' => l10n.regSmokingRegular,
      _ => val,
    };
  }

  String _maritalLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'first_marriage' => l10n.regMaritalFirst,
      'remarriage' => l10n.regMaritalRemarriage,
      'divorced' => l10n.regMaritalDivorced,
      _ => val,
    };
  }

  String _assetLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'under_100m' => l10n.regAssetRange1,
      '100m_300m' => l10n.regAssetRange2,
      '300m_500m' => l10n.regAssetRange3,
      '500m_1b' => l10n.regAssetRange4,
      'over_1b' => l10n.regAssetRange5,
      _ => val,
    };
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
