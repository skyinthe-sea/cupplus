import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/marketplace_providers.dart';
import '../widgets/profile_detail_bio_section.dart';
import '../widgets/profile_detail_header.dart';
import '../widgets/profile_detail_hobbies_section.dart';
import '../widgets/profile_detail_ideal_partner_section.dart';
import '../widgets/profile_detail_info_section.dart';
import '../widgets/profile_detail_verification_section.dart';
import '../widgets/request_match_button.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(marketplaceProfileByIdProvider(profileId));
    final l10n = AppLocalizations.of(context)!;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(l10n.errorNotFound),
        ),
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
            child: SizedBox(height: MediaQuery.of(context).padding.top + 56.h),
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
      bottomNavigationBar: RequestMatchButton(
        matchRequestCount: profile.matchRequestCount,
        profileName: profile.fullName,
      ),
    );
  }
}
