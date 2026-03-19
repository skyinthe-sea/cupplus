import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/label_formatters.dart';
import '../models/marketplace_profile.dart';
import '../providers/marketplace_providers.dart';
import '../widgets/marketplace_shimmer_card.dart';
import '../widgets/profile_detail_bio_section.dart';
import '../widgets/profile_detail_header.dart';
import '../widgets/profile_detail_hobbies_section.dart';
import '../widgets/profile_detail_ideal_partner_section.dart';
import '../widgets/profile_detail_info_section.dart';
import '../widgets/profile_detail_verification_section.dart';
import '../widgets/request_match_button.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({
    super.key,
    required this.profileId,
    this.hideMatchButton = false,
  });

  final String profileId;
  final bool hideMatchButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(marketplaceProfileByIdProvider(profileId));
    final l10n = AppLocalizations.of(context)!;

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.errorNotFound)),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child:
                    SizedBox(height: MediaQuery.of(context).padding.top + 56.h),
              ),
              SliverToBoxAdapter(
                child: ProfileDetailHeader(profile: profile),
              ),
              SliverToBoxAdapter(
                child: ProfileDetailInfoSection(profile: profile),
              ),
              SliverToBoxAdapter(
                child: ProfileDetailHobbiesSection(hobbies: profile.hobbies),
              ),
              if (profile.bio != null)
                SliverToBoxAdapter(
                  child: ProfileDetailBioSection(bio: profile.bio!),
                ),
              // Family & Lifestyle section
              if (profile.maritalHistory != null ||
                  profile.drinking != null ||
                  profile.smoking != null ||
                  profile.familyDetail != null)
                SliverToBoxAdapter(
                  child: _FamilyLifestyleSection(profile: profile),
                ),
              // Ideal partner conditions section (structured)
              if (profile.idealMinAge != null ||
                  profile.idealMaxAge != null ||
                  profile.idealMinHeight != null ||
                  profile.idealMaxHeight != null ||
                  profile.idealEducationLevel != null ||
                  profile.idealIncomeRange != null ||
                  profile.idealReligion != null ||
                  profile.idealNotes != null)
                SliverToBoxAdapter(
                  child: _IdealPartnerSection(profile: profile),
                ),
              if (profile.idealPartnerNotes != null)
                SliverToBoxAdapter(
                  child: ProfileDetailIdealPartnerSection(
                    notes: profile.idealPartnerNotes!,
                  ),
                ),
              SliverToBoxAdapter(
                child: ProfileDetailVerificationSection(
                  documents: profile.verifiedDocuments,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
          bottomNavigationBar: hideMatchButton ||
                  profile.managerId ==
                      ref.watch(currentUserProvider)?.id
              ? _MatchContextBar(profile: profile)
              : RequestMatchButton(profile: profile),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: EdgeInsets.only(top: 16.h),
          children: List.generate(3, (_) => const MarketplaceShimmerCard()),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.commonError),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () =>
                    ref.invalidate(marketplaceProfileByIdProvider(profileId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyLifestyleSection extends StatelessWidget {
  const _FamilyLifestyleSection({required this.profile});

  final MarketplaceProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final rows = <_DetailRow>[
      if (profile.maritalHistory != null)
        _DetailRow(
          icon: Icons.family_restroom_outlined,
          label: l10n.profileMaritalHistory,
          value: _maritalLabel(profile.maritalHistory!, l10n),
        ),
      if (profile.familyDetail != null)
        _DetailRow(
          icon: Icons.people_outline_rounded,
          label: l10n.profileFamilyDetail,
          value: profile.familyDetail!,
        ),
      if (profile.parentsStatus != null)
        _DetailRow(
          icon: Icons.supervisor_account_outlined,
          label: l10n.profileParentsStatus,
          value: _parentsLabel(profile.parentsStatus!, l10n),
        ),
      if (profile.hasChildren)
        _DetailRow(
          icon: Icons.child_care_outlined,
          label: l10n.profileChildren,
          value: profile.childrenCount != null
              ? l10n.profileChildrenCount(profile.childrenCount!)
              : '-',
        ),
      if (profile.drinking != null)
        _DetailRow(
          icon: Icons.local_bar_outlined,
          label: l10n.profileDrinking,
          value: _drinkingLabel(profile.drinking!, l10n),
        ),
      if (profile.smoking != null)
        _DetailRow(
          icon: Icons.smoking_rooms_outlined,
          label: l10n.profileSmoking,
          value: _smokingLabel(profile.smoking!, l10n),
        ),
      if (profile.residenceArea != null)
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: l10n.profileResidenceArea,
          value: profile.residenceArea!,
        ),
      if (profile.personalityType != null)
        _DetailRow(
          icon: Icons.psychology_outlined,
          label: l10n.profilePersonalityType,
          value: profile.personalityType!,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

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
                  color:
                      Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.family_restroom_rounded,
                      size: 18.r,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.profileFamilyTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...rows.map((row) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            row.icon,
                            size: 18.r,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 50.w,
                            child: Text(
                              row.label,
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
                              row.value,
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

  String _parentsLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'both_alive' => l10n.regParentsBothAlive,
      'father_only' => l10n.regParentsFatherOnly,
      'mother_only' => l10n.regParentsMotherOnly,
      'deceased' => l10n.regParentsDeceased,
      _ => val,
    };
  }
}

class _IdealPartnerSection extends StatelessWidget {
  const _IdealPartnerSection({required this.profile});

  final MarketplaceProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final rows = <_DetailRow>[
      if (profile.idealMinAge != null && profile.idealMaxAge != null)
        _DetailRow(
          icon: Icons.cake_outlined,
          label: l10n.profileIdealAge,
          value: l10n.profileIdealAgeRange(
              profile.idealMinAge!, profile.idealMaxAge!),
        ),
      if (profile.idealMinAge != null && profile.idealMaxAge == null)
        _DetailRow(
          icon: Icons.cake_outlined,
          label: l10n.profileIdealAge,
          value: '${profile.idealMinAge}+',
        ),
      if (profile.idealMinAge == null && profile.idealMaxAge != null)
        _DetailRow(
          icon: Icons.cake_outlined,
          label: l10n.profileIdealAge,
          value: '~${profile.idealMaxAge}',
        ),
      if (profile.idealMinHeight != null && profile.idealMaxHeight != null)
        _DetailRow(
          icon: Icons.straighten_rounded,
          label: l10n.profileIdealHeight,
          value: l10n.profileIdealHeightRange(
              profile.idealMinHeight!, profile.idealMaxHeight!),
        ),
      if (profile.idealMinHeight != null && profile.idealMaxHeight == null)
        _DetailRow(
          icon: Icons.straighten_rounded,
          label: l10n.profileIdealHeight,
          value: '${profile.idealMinHeight}cm+',
        ),
      if (profile.idealMinHeight == null && profile.idealMaxHeight != null)
        _DetailRow(
          icon: Icons.straighten_rounded,
          label: l10n.profileIdealHeight,
          value: '~${profile.idealMaxHeight}cm',
        ),
      if (profile.idealEducationLevel != null)
        _DetailRow(
          icon: Icons.school_outlined,
          label: l10n.profileIdealEducation,
          value: profile.idealEducationLevel!,
        ),
      if (profile.idealIncomeRange != null)
        _DetailRow(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.profileIdealIncome,
          value: incomeLabel(profile.idealIncomeRange!, l10n),
        ),
      if (profile.idealReligion != null)
        _DetailRow(
          icon: Icons.brightness_7_outlined,
          label: l10n.profileIdealReligion,
          value: profile.idealReligion!,
        ),
      if (profile.idealNotes != null)
        _DetailRow(
          icon: Icons.notes_outlined,
          label: l10n.profileIdealNotes,
          value: profile.idealNotes!,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

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
                  color:
                      Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 18.r,
                      color: theme.colorScheme.tertiary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.profileIdealPartnerTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...rows.map((row) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            row.icon,
                            size: 18.r,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 50.w,
                            child: Text(
                              row.label,
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
                              row.value,
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
}

class _MatchContextBar extends StatelessWidget {
  const _MatchContextBar({required this.profile});

  final MarketplaceProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: bottomPadding + 12.h,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.85)
                : theme.colorScheme.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18.r,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.profileDetailMatchContext,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
