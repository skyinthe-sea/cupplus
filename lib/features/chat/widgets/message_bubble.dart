import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
    this.participantName,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String? participantName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.72;
    final timeText = _formatTime(message.createdAt);

    if (message.isMine) {
      return _MineBubble(
        message: message,
        theme: theme,
        maxWidth: maxWidth,
        timeText: timeText,
        l10n: l10n,
      );
    }
    return _OtherBubble(
      message: message,
      theme: theme,
      isDark: isDark,
      maxWidth: maxWidth,
      timeText: timeText,
      showAvatar: showAvatar,
      participantName: participantName,
      l10n: l10n,
    );
  }

  static String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _MineBubble extends StatelessWidget {
  const _MineBubble({
    required this.message,
    required this.theme,
    required this.maxWidth,
    required this.timeText,
    required this.l10n,
  });

  final ChatMessage message;
  final ThemeData theme;
  final double maxWidth;
  final String timeText;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 48.w, right: 16.w, top: 2.h, bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 4.w, bottom: 2.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  message.isRead ? Icons.done_all : Icons.done,
                  size: 14.r,
                  color: message.isRead
                      ? const Color(0xFF2D5A8E)
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5A8E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(4.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: _buildContent(
                Colors.white,
                Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color textColor, Color secondaryColor) {
    if (message.type == 'image') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 16.r, color: secondaryColor),
          SizedBox(width: 4.w),
          Text(
            l10n.chatImageMessage,
            style: TextStyle(fontSize: 14.sp, color: secondaryColor),
          ),
        ],
      );
    }
    return Text(
      message.content,
      style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.4),
    );
  }
}

class _OtherBubble extends StatelessWidget {
  const _OtherBubble({
    required this.message,
    required this.theme,
    required this.isDark,
    required this.maxWidth,
    required this.timeText,
    required this.showAvatar,
    this.participantName,
    required this.l10n,
  });

  final ChatMessage message;
  final ThemeData theme;
  final bool isDark;
  final double maxWidth;
  final String timeText;
  final bool showAvatar;
  final String? participantName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 48.w, top: 2.h, bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar)
            CircleAvatar(
              radius: 16.r,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                participantName?.characters.first ?? '?',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            )
          else
            SizedBox(width: 32.r),
          SizedBox(width: 8.w),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainer
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: _buildContent(
                theme.colorScheme.onSurface,
                theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
            child: Text(
              timeText,
              style: TextStyle(
                fontSize: 10.sp,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color textColor, Color secondaryColor) {
    if (message.type == 'image') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 16.r, color: secondaryColor),
          SizedBox(width: 4.w),
          Text(
            l10n.chatImageMessage,
            style: TextStyle(fontSize: 14.sp, color: secondaryColor),
          ),
        ],
      );
    }
    return Text(
      message.content,
      style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.4),
    );
  }
}
