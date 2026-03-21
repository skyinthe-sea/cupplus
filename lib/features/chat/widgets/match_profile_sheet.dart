import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../home/providers/home_providers.dart';

class MatchProfileSheet extends ConsumerWidget {
  const MatchProfileSheet({super.key, required this.matchId});

  final String matchId;

  static Future<void> show(BuildContext context, String matchId) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;

    return showModalBottomSheet(
      context: context,
      backgroundColor: homeColors.cardColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => MatchProfileSheet(matchId: matchId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(matchDetailProvider(matchId));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: homeColors.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.chatMatchProfileTitle,
              style: TextStyle(
                fontFamily: serifFontFamily,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: homeColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            detailAsync.when(
              loading: () => Padding(
                padding: EdgeInsets.all(32.r),
                child: const CircularProgressIndicator(),
              ),
              error: (_, __) => Padding(
                padding: EdgeInsets.all(32.r),
                child: Text(l10n.commonError),
              ),
              data: (data) {
                if (data == null) {
                  return Padding(
                    padding: EdgeInsets.all(32.r),
                    child: Text(l10n.matchDetailNotFound),
                  );
                }
                return _MatchProfileContent(data: data);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchProfileContent extends StatelessWidget {
  const _MatchProfileContent({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final match = data['match'] as Map<String, dynamic>;
    final clientA = data['client_a'] as Map<String, dynamic>?;
    final clientB = data['client_b'] as Map<String, dynamic>?;
    final status = match['status'] as String? ?? 'pending';
    final matchedAt = match['matched_at'] as String?;

    final (statusLabel, statusColor) = _statusInfo(status, l10n, theme);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _ProfileCard(
                  client: clientA,
                  homeColors: homeColors,
                  theme: theme,
                  l10n: l10n,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 20.r,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              Expanded(
                child: _ProfileCard(
                  client: clientB,
                  homeColors: homeColors,
                  theme: theme,
                  l10n: l10n,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: homeColors.borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14.r,
                        color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(width: 6.w),
                    Text(
                      '${l10n.chatMatchDate}: ${_formatDate(matchedAt)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy.MM.dd').format(date);
    } catch (_) {
      return '-';
    }
  }

  (String, Color) _statusInfo(
      String status, AppLocalizations l10n, ThemeData theme) {
    return switch (status) {
      'pending' => (l10n.matchStatusPending, Colors.amber.shade700),
      'accepted' => (l10n.matchStatusAccepted, Colors.green.shade600),
      'declined' => (l10n.matchStatusDeclined, theme.colorScheme.error),
      'meeting_scheduled' =>
        (l10n.matchStatusMeetingScheduled, theme.colorScheme.primary),
      'completed' => (l10n.matchStatusCompleted, Colors.grey),
      'cancelled' => (l10n.matchStatusCancelled, Colors.grey),
      _ => (status, Colors.grey),
    };
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.client,
    required this.homeColors,
    required this.theme,
    required this.l10n,
  });

  final Map<String, dynamic>? client;
  final HomeColors homeColors;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (client == null) {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          border: Border.all(color: homeColors.borderColor),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(child: Text('?', style: theme.textTheme.bodyLarge)),
      );
    }

    final name = client!['full_name'] as String? ?? '?';
    final gender = client!['gender'] as String? ?? '';
    final occupation = client!['occupation'] as String? ?? '';
    final birthDate = client!['birth_date'] as String?;
    final clientId = client!['id'] as String;

    final age = _calculateAge(birthDate);
    final genderLabel = gender == 'male' ? l10n.homeGenderMale : l10n.homeGenderFemale;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        border: Border.all(color: homeColors.borderColor),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              name.characters.firstOrNull ?? '?',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: homeColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          if (age != null)
            Text(
              '$age${l10n.homeAgeSuffix(age).replaceAll(age.toString(), '')} · $genderLabel',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (occupation.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              occupation,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.profileDetail(clientId),
                  extra: true,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                l10n.chatViewProfile,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _calculateAge(String? birthDate) {
    if (birthDate == null) return null;
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      var age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }
}
