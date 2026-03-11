import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/client_summary.dart';

class ProfileCarouselCard extends StatelessWidget {
  const ProfileCarouselCard({super.key, required this.client});

  final ClientSummary client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final statusColors = theme.extension<StatusColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.65)
                  : theme.colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row: avatar + name/age + match status chip
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        client.fullName.isNotEmpty ? client.fullName[0] : '?',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                client.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (client.isVerified) ...[
                                SizedBox(width: 4.w),
                                Container(
                                  padding: EdgeInsets.all(2.r),
                                  decoration: BoxDecoration(
                                    color: statusColors.verified
                                        .withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.verified_rounded,
                                    size: 14.r,
                                    color: statusColors.verified,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${l10n.homeAgeSuffix(client.age)} · ${client.gender == 'M' ? l10n.homeGenderMale : l10n.homeGenderFemale}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (client.matchStatus != null)
                      _MatchStatusChip(
                        status: client.matchStatus!,
                        statusColors: statusColors,
                        l10n: l10n,
                      ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                  ),
                ),

                // Info rows
                _InfoRow(
                  icon: Icons.business_rounded,
                  text: client.company != null
                      ? '${client.occupation} · ${client.company}'
                      : client.occupation,
                ),
                if (client.education != null) ...[
                  SizedBox(height: 8.h),
                  _InfoRow(
                    icon: Icons.school_rounded,
                    text: client.education!,
                  ),
                ],
                if (client.heightCm != null) ...[
                  SizedBox(height: 8.h),
                  _InfoRow(
                    icon: Icons.straighten_rounded,
                    text: l10n.homeHeightCm(client.heightCm!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchStatusChip extends StatelessWidget {
  const _MatchStatusChip({
    required this.status,
    required this.statusColors,
    required this.l10n,
  });

  final String status;
  final StatusColors statusColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'pending' => (statusColors.pending, l10n.matchStatusPending),
      'accepted' => (statusColors.accepted, l10n.matchStatusAccepted),
      'declined' => (statusColors.declined, l10n.matchStatusDeclined),
      _ => (statusColors.pending, status),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16.r,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
