import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.subtitle,
    this.onTap,
    this.verificationStatus,
    this.onVerificationTap,
  });

  final String name;
  final String email;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? verificationStatus;
  final VoidCallback? onVerificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = Theme.of(context).extension<HomeColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: homeColors.cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: homeColors.borderColor,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor:
                      homeColors.pointColor.withValues(alpha: 0.12),
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: homeColors.pointColor,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (verificationStatus != null) ...[
                            SizedBox(width: 6.w),
                            _VerificationBadge(
                              status: verificationStatus!,
                              onTap: onVerificationTap,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle ?? email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.status, this.onTap});
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      'verified' => (Icons.verified_rounded, Colors.green),
      'pending' => (Icons.schedule_rounded, Colors.orange),
      'rejected' => (Icons.error_outline_rounded, Colors.red),
      _ => (null, null),
    };

    if (icon == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 18.r, color: color),
    );
  }
}
