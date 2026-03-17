import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/home_providers.dart';

class NotificationBottomSheet extends ConsumerStatefulWidget {
  const NotificationBottomSheet({super.key});

  @override
  ConsumerState<NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState
    extends ConsumerState<NotificationBottomSheet> {
  @override
  void initState() {
    super.initState();
    _markVisibleAsRead();
  }

  Future<void> _markVisibleAsRead() async {
    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) return;

      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
      // Realtime will auto-refetch — no need to invalidate
    } catch (_) {
      // Silently fail — RLS policy may not be applied yet
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notifications = ref.watch(notificationsListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    l10n.notificationTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _markVisibleAsRead,
                    child: Text(
                      l10n.homeNotificationMarkAllRead,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notifications.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48.r,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            l10n.notificationEmpty,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _NotificationItem(item: item);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(l10n.commonError),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.item});

  final Map<String, dynamic> item;

  void _onNotificationTap(BuildContext context) {
    final type = item['type'] as String? ?? '';
    final data = item['data'] as Map<String, dynamic>? ?? {};

    // Close the bottom sheet first
    Navigator.of(context).pop();

    switch (type) {
      case 'new_match' || 'match_response':
        final requiresVerification =
            data['requires_verification'] == true ||
                data['requires_verification'] == 'true';
        if (requiresVerification) {
          context.push(AppRoutes.verification);
          return;
        }
        final matchId = data['match_id'] as String?;
        if (matchId != null) {
          context.push(AppRoutes.matchDetail(matchId));
        }
      case 'new_message':
        final conversationId = data['conversation_id'] as String?;
        if (conversationId != null) {
          context.push(AppRoutes.chatRoom(conversationId));
        }
      case 'verification_result':
        context.go(AppRoutes.my);
      case 'system':
        final clientId = data['client_id'] as String?;
        if (clientId != null) {
          context.push(AppRoutes.profileDetail(clientId));
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRead = item['is_read'] as bool? ?? false;
    final title = item['title'] as String? ?? '';
    final body = item['body'] as String? ?? '';
    final createdAt = item['created_at'] as String?;
    final type = item['type'] as String? ?? '';

    final icon = switch (type) {
      'new_match' || 'match_response' => Icons.favorite_rounded,
      'new_message' => Icons.chat_bubble_rounded,
      'verification_result' => Icons.verified_rounded,
      'system' => Icons.person_add_rounded,
      _ => Icons.notifications_rounded,
    };

    final color = switch (type) {
      'new_match' || 'match_response' => theme.colorScheme.tertiary,
      'new_message' => theme.colorScheme.primary,
      'verification_result' => theme.colorScheme.secondary,
      'system' => Colors.green,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    String timeText = '';
    if (createdAt != null) {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        timeText = l10n.chatMinutesAgo(diff.inMinutes);
      } else if (diff.inHours < 24) {
        timeText = l10n.chatHoursAgo(diff.inHours);
      } else {
        timeText = DateFormat('M/d').format(dt);
      }
    }

    return InkWell(
      onTap: () => _onNotificationTap(context),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.r, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              timeText,
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            if (!isRead) ...[
              SizedBox(width: 4.w),
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
