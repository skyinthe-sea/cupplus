import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/utils/label_formatters.dart';
import '../providers/my_clients_provider.dart';
import '../widgets/client_tags_section.dart';
import '../widgets/client_timeline.dart';

class MyClientDetailScreen extends ConsumerWidget {
  const MyClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(myClientDetailProvider(clientId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return detailAsync.when(
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.errorNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(detail.fullName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.myClientDetailEdit,
                onPressed: () => context.push(AppRoutes.myClientEdit(clientId)),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context, ref, detail, l10n);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      l10n.commonDelete,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(myClientDetailProvider(clientId)),
            child: CustomScrollView(
              slivers: [
                // Profile header
                SliverToBoxAdapter(
                  child: _ProfileHeader(detail: detail),
                ),

                // Status chip with change
                SliverToBoxAdapter(
                  child: _StatusSection(
                    detail: detail,
                    onStatusChange: (newStatus) => _changeStatus(
                      context,
                      ref,
                      detail,
                      newStatus,
                      l10n,
                    ),
                  ),
                ),

                // Info section
                SliverToBoxAdapter(
                  child: _InfoSection(detail: detail, l10n: l10n),
                ),

                // Hobbies
                if (detail.hobbies.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HobbiesSection(hobbies: detail.hobbies, l10n: l10n),
                  ),

                // Ideal partner
                if (detail.idealMinAge != null || detail.idealMaxAge != null ||
                    detail.idealMinHeight != null || detail.idealMaxHeight != null ||
                    detail.idealNotes != null)
                  SliverToBoxAdapter(
                    child: _IdealPartnerSection(detail: detail, l10n: l10n),
                  ),

                // Bio
                if (detail.bio != null && detail.bio!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _BioSection(bio: detail.bio!, l10n: l10n),
                  ),

                // CRM Tags
                SliverToBoxAdapter(
                  child: ClientTagsSection(clientId: clientId),
                ),

                // CRM Notes & Timeline
                SliverToBoxAdapter(
                  child: ClientTimeline(clientId: clientId),
                ),

                // Match history
                SliverToBoxAdapter(
                  child: _MatchHistorySection(
                    matches: detail.matchHistory,
                    l10n: l10n,
                  ),
                ),

                // Contract history link
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push(AppRoutes.contractHistory(clientId));
                      },
                      icon: const Icon(Icons.description_outlined),
                      label: Text(l10n.contractHistory),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 44.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(height: 40.h),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
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
                    ref.invalidate(myClientDetailProvider(clientId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    ClientDetail detail,
    String newStatus,
    AppLocalizations l10n,
  ) async {
    final statusLabel = _statusLabel(newStatus, l10n);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        icon: Icons.swap_horiz_rounded,
        title: l10n.myClientStatusChange,
        content: l10n.myClientStatusChangeConfirm(detail.fullName, statusLabel),
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.commonConfirm,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(
        updateClientStatusProvider(clientId, newStatus).future,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.myClientStatusChanged)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError)),
        );
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ClientDetail detail,
    AppLocalizations l10n,
  ) {
    showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        icon: Icons.delete_forever_rounded,
        iconColor: Theme.of(context).colorScheme.error,
        title: l10n.myClientDeleteTitle,
        content: l10n.myClientDeleteMessage(detail.fullName),
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.commonDelete,
        isDestructive: true,
        onConfirm: () async {
          Navigator.pop(context);
          try {
            await ref.read(deleteClientProvider(clientId).future);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.myClientDeleteSuccess)),
              );
              context.pop();
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.myClientDeleteFailed)),
              );
            }
          }
        },
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    return switch (status) {
      'active' => l10n.myClientDetailStatusActive,
      'paused' => l10n.myClientDetailStatusPaused,
      'matched' => l10n.myClientDetailStatusMatched,
      'withdrawn' => l10n.myClientDetailStatusWithdrawn,
      _ => status,
    };
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.detail});
  final ClientDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      child: Row(
        children: [
          Hero(
            tag: 'client_avatar_${detail.id}',
            child: CircleAvatar(
              radius: 36.r,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: detail.profilePhotoUrl != null
                  ? NetworkImage(detail.profilePhotoUrl!)
                  : null,
              child: detail.profilePhotoUrl == null
                  ? Text(
                      detail.fullName.isNotEmpty ? detail.fullName[0] : '?',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  [
                    if (detail.age != null) '${detail.age}세',
                    detail.gender == 'M' ? '남성' : '여성',
                    if (detail.occupation != null) detail.occupation,
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.detail, required this.onStatusChange});
  final ClientDetail detail;
  final ValueChanged<String> onStatusChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentStatus = detail.status;

    final availableStatuses = ['active', 'paused', 'matched']
        .where((s) => s != currentStatus)
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            l10n.myClientDetailStatus,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 12.w),
          _buildStatusChip(currentStatus, theme, l10n),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: onStatusChange,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.myClientStatusChange,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.primary,
                    size: 20.r,
                  ),
                ],
              ),
            ),
            itemBuilder: (_) => availableStatuses
                .map(
                  (s) => PopupMenuItem(
                    value: s,
                    child: Text(_statusLabel(s, l10n)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      String status, ThemeData theme, AppLocalizations l10n) {
    final color = switch (status) {
      'active' => Colors.green,
      'paused' => Colors.orange,
      'matched' => theme.colorScheme.primary,
      _ => Colors.grey,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        _statusLabel(status, l10n),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    return switch (status) {
      'active' => l10n.myClientDetailStatusActive,
      'paused' => l10n.myClientDetailStatusPaused,
      'matched' => l10n.myClientDetailStatusMatched,
      'withdrawn' => l10n.myClientDetailStatusWithdrawn,
      _ => status,
    };
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.detail, required this.l10n});
  final ClientDetail detail;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_InfoItem>[
      if (detail.phone != null)
        _InfoItem(l10n.myClientDetailPhone, detail.phone!),
      if (detail.email != null)
        _InfoItem(l10n.myClientDetailEmail, detail.email!),
      if (detail.heightCm != null)
        _InfoItem(l10n.profileHeight, '${detail.heightCm}cm'),
      if (detail.bodyType != null)
        _InfoItem(l10n.myClientDetailBodyType, bodyTypeLabel(detail.bodyType!, l10n)),
      if (detail.education != null)
        _InfoItem(l10n.profileEducation, detail.education!),
      if (detail.educationLevel != null)
        _InfoItem(
            l10n.myClientDetailEducationLevel, educationLabel(detail.educationLevel!, l10n)),
      if (detail.school != null)
        _InfoItem(l10n.myClientDetailSchool, detail.school!),
      if (detail.major != null)
        _InfoItem(l10n.myClientDetailMajor, detail.major!),
      if (detail.company != null)
        _InfoItem(l10n.profileCompany, detail.company!),
      if (detail.annualIncomeRange != null)
        _InfoItem(l10n.profileIncome, incomeLabel(detail.annualIncomeRange!, l10n)),
      if (detail.religion != null)
        _InfoItem(l10n.profileReligion, religionLabel(detail.religion!, l10n)),
      if (detail.maritalHistory != null)
        _InfoItem(l10n.profileMaritalHistory, maritalLabel(detail.maritalHistory!, l10n)),
      if (detail.hasChildren)
        _InfoItem(l10n.profileChildren, detail.childrenCount != null ? l10n.profileChildrenCount(detail.childrenCount!) : 'O'),
      if (detail.familyDetail != null)
        _InfoItem(l10n.profileFamilyDetail, detail.familyDetail!),
      if (detail.parentsStatus != null)
        _InfoItem(l10n.profileParentsStatus, parentsLabel(detail.parentsStatus!, l10n)),
      if (detail.drinking != null)
        _InfoItem(l10n.profileDrinking, drinkingLabel(detail.drinking!, l10n)),
      if (detail.smoking != null)
        _InfoItem(l10n.profileSmoking, smokingLabel(detail.smoking!, l10n)),
      if (detail.personalityType != null)
        _InfoItem(l10n.profilePersonalityType, detail.personalityType!),
      if (detail.assetRange != null)
        _InfoItem(l10n.profileAssetRange, assetLabel(detail.assetRange!, l10n)),
      if (detail.residenceArea != null)
        _InfoItem(l10n.profileResidenceArea, detail.residenceArea!),
      if (detail.residenceType != null)
        _InfoItem(l10n.profileResidenceType, _residenceLabel(detail.residenceType!, l10n)),
      if (detail.healthNotes != null)
        _InfoItem(l10n.profileHealthNotes, detail.healthNotes!),
      if (detail.createdAt != null)
        _InfoItem(
          l10n.myClientDetailRegisteredAt,
          '${detail.createdAt!.year}.${detail.createdAt!.month.toString().padLeft(2, '0')}.${detail.createdAt!.day.toString().padLeft(2, '0')}',
        ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
              ...items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          item.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _residenceLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'own' => l10n.regResidenceOwn,
      'rent_deposit' => l10n.regResidenceRentDeposit,
      'rent_monthly' => l10n.regResidenceRentMonthly,
      'with_parents' => l10n.regResidenceWithParents,
      _ => val,
    };
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);
  final String label;
  final String value;
}

class _HobbiesSection extends StatelessWidget {
  const _HobbiesSection({required this.hobbies, required this.l10n});
  final List<String> hobbies;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileDetailHobbies,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: hobbies
                    .map(
                      (h) => Chip(
                        label: Text(h, style: TextStyle(fontSize: 12.sp)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  const _BioSection({required this.bio, required this.l10n});
  final String bio;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileDetailBio,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                bio,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchHistorySection extends StatelessWidget {
  const _MatchHistorySection({required this.matches, required this.l10n});
  final List<Map<String, dynamic>> matches;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.myClientDetailMatchHistory,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              if (matches.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: Text(
                      l10n.myClientDetailMatchEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...matches.map((m) {
                  final status = m['status'] as String;
                  final counterpartName = m['counterpart_name'] as String;
                  final matchedAt = m['matched_at'] as String?;
                  final date = matchedAt != null
                      ? DateTime.tryParse(matchedAt)
                      : null;

                  final statusColor = switch (status) {
                    'pending' => Colors.amber,
                    'accepted' || 'meeting_scheduled' => Colors.green,
                    'declined' || 'cancelled' => Colors.red,
                    'completed' => theme.colorScheme.primary,
                    _ => Colors.grey,
                  };

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 16.r,
                          color: statusColor,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '↔ $counterpartName',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            _matchStatusLabel(status),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        if (date != null) ...[
                          SizedBox(width: 8.w),
                          Text(
                            '${date.month}/${date.day}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  String _matchStatusLabel(String status) {
    return switch (status) {
      'pending' => l10n.matchStatusPending,
      'accepted' => l10n.matchStatusAccepted,
      'declined' => l10n.matchStatusDeclined,
      'meeting_scheduled' => l10n.matchStatusMeetingScheduled,
      'completed' => l10n.matchStatusCompleted,
      'cancelled' => '취소',
      _ => status,
    };
  }
}

class _IdealPartnerSection extends StatelessWidget {
  const _IdealPartnerSection({required this.detail, required this.l10n});
  final ClientDetail detail;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_InfoItem>[
      if (detail.idealMinAge != null || detail.idealMaxAge != null)
        _InfoItem(l10n.profileIdealAge, l10n.profileIdealAgeRange(
          detail.idealMinAge ?? 20, detail.idealMaxAge ?? 45)),
      if (detail.idealMinHeight != null || detail.idealMaxHeight != null)
        _InfoItem(l10n.profileIdealHeight, l10n.profileIdealHeightRange(
          detail.idealMinHeight ?? 150, detail.idealMaxHeight ?? 195)),
      if (detail.idealEducationLevel != null)
        _InfoItem(l10n.profileIdealEducation, detail.idealEducationLevel!),
      if (detail.idealIncomeRange != null)
        _InfoItem(l10n.profileIdealIncome, incomeLabel(detail.idealIncomeRange!, l10n)),
      if (detail.idealReligion != null)
        _InfoItem(l10n.profileIdealReligion, detail.idealReligion!),
      if (detail.idealNotes != null)
        _InfoItem(l10n.profileIdealNotes, detail.idealNotes!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileIdealPartnerTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              ...items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          item.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
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
