import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/client_summary.dart';

class ClientMiniProfile extends StatelessWidget {
  const ClientMiniProfile({super.key, required this.client});

  final ClientSummary client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: 110.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              client.fullName.isNotEmpty ? client.fullName[0] : '?',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  client.fullName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (client.isVerified) ...[
                SizedBox(width: 3.w),
                Container(
                  padding: EdgeInsets.all(1.5.r),
                  decoration: BoxDecoration(
                    color: statusColors.verified.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    size: 12.r,
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
              fontSize: 11.sp,
            ),
            maxLines: 1,
          ),
          SizedBox(height: 2.h),
          Text(
            client.occupation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (client.company != null) ...[
            SizedBox(height: 1.h),
            Text(
              client.company!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
