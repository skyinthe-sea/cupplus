import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';

/// Unified dialog wrapper with HomeColors design language.
///
/// Usage:
/// ```dart
/// AppDialog.show(
///   context: context,
///   icon: Icons.check_circle_rounded,
///   title: 'Title',
///   content: 'Content text',
///   confirmLabel: 'OK',
///   onConfirm: () => Navigator.pop(context, true),
/// );
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.content,
    this.contentWidget,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    this.isDestructive = false,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? content;
  final Widget? contentWidget;
  final String? cancelLabel;
  final String? confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isDestructive;

  /// Show a dialog and return the result.
  static Future<T?> show<T>({
    required BuildContext context,
    IconData? icon,
    Color? iconColor,
    required String title,
    String? content,
    Widget? contentWidget,
    String? cancelLabel,
    String? confirmLabel,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool isDestructive = false,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        content: content,
        contentWidget: contentWidget,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        onCancel: onCancel,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;

    return Dialog(
      backgroundColor: homeColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: homeColors.borderColor),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: (iconColor ?? homeColors.pointColor)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28.r,
                  color: iconColor ?? homeColors.pointColor,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            Text(
              title,
              style: TextStyle(
                fontFamily: serifFontFamily,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: homeColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (content != null) ...[
              SizedBox(height: 10.h),
              Text(
                content!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: homeColors.textPrimary.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (contentWidget != null) ...[
              SizedBox(height: 10.h),
              contentWidget!,
            ],
            SizedBox(height: 24.h),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: TextButton(
                      onPressed:
                          onCancel ?? () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        cancelLabel!,
                        style: TextStyle(
                          color:
                              homeColors.textPrimary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                if (confirmLabel != null)
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          onConfirm ?? () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: isDestructive
                            ? theme.colorScheme.error
                            : homeColors.ctaBar,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        confirmLabel!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
