import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../verification/providers/verification_provider.dart';
import '../providers/home_providers.dart';

class MatchManagementSheet extends ConsumerStatefulWidget {
  const MatchManagementSheet({super.key});

  @override
  ConsumerState<MatchManagementSheet> createState() =>
      _MatchManagementSheetState();
}

class _MatchManagementSheetState extends ConsumerState<MatchManagementSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
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
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    l10n.homeMatchMgmtTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.matchesTabPending),
                Tab(text: l10n.matchesTabActive),
                Tab(text: l10n.matchesTabDone),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _MatchTab(status: 'pending'),
                  _MatchTab(status: 'active'),
                  _MatchTab(status: 'done'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MatchTab extends ConsumerWidget {
  const _MatchTab({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final matchesAsync = ref.watch(matchesByStatusProvider(status));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status == 'pending'
                      ? Icons.hourglass_empty_rounded
                      : status == 'active'
                          ? Icons.favorite_border_rounded
                          : Icons.check_circle_outline_rounded,
                  size: 48.r,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                ),
                SizedBox(height: 12.h),
                Text(
                  status == 'pending'
                      ? l10n.matchesEmptyPendingTitle
                      : status == 'active'
                          ? l10n.matchesEmptyActiveTitle
                          : l10n.matchesEmptyDoneTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.r),
          itemCount: matches.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final match = matches[index];
            return _MatchCard(match: match);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.commonError)),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  const _MatchCard({
    required this.match,
  });

  final Map<String, dynamic> match;

  int? _calcAge(String? birthDate) {
    if (birthDate == null) return null;
    try {
      final birth = DateTime.parse(birthDate);
      return DateTime.now().year - birth.year;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final myClient = match['my_client'] as Map<String, dynamic>?;
    final otherClient = match['other_client'] as Map<String, dynamic>?;
    final myClientName = myClient?['full_name'] as String? ?? '?';
    final otherClientName = otherClient?['full_name'] as String? ?? '?';
    final myAge = _calcAge(myClient?['birth_date'] as String?);
    final otherAge = _calcAge(otherClient?['birth_date'] as String?);
    final status = match['status'] as String? ?? 'pending';
    final isSender = match['is_sender'] as bool? ?? true;
    final matchedAt = match['matched_at'] as String?;
    final notes = match['notes'] as String?;

    String dateText = '';
    if (matchedAt != null) {
      dateText = DateFormat('yyyy.MM.dd').format(DateTime.parse(matchedAt));
    }

    final statusColor = switch (status) {
      'pending' => Colors.amber.shade700,
      'accepted' || 'meeting_scheduled' => const Color(0xFF2E7D32),
      'declined' || 'cancelled' => const Color(0xFFC62828),
      'completed' => theme.colorScheme.primary,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    final statusText = switch (status) {
      'pending' => l10n.matchStatusPending,
      'accepted' => l10n.matchStatusAccepted,
      'declined' => l10n.matchStatusDeclined,
      'cancelled' => l10n.matchStatusCancelled,
      'meeting_scheduled' => l10n.matchStatusMeetingScheduled,
      'completed' => l10n.matchStatusCompleted,
      _ => status,
    };

    final directionColor = isSender
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;
    final directionText =
        isSender ? l10n.matchCardSent : l10n.matchCardReceived;
    final directionIcon =
        isSender ? Icons.call_made_rounded : Icons.call_received_rounded;

    final showReceivedActions = !isSender && status == 'pending';

    return GestureDetector(
      onTap: () {
        final matchId = match['id'] as String?;
        if (matchId != null) {
          Navigator.of(context).pop();
          context.push(AppRoutes.matchDetail(matchId));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: direction icon+text (left) + date (right)
              Row(
                children: [
                  Icon(directionIcon, size: 14.sp, color: directionColor),
                  SizedBox(width: 4.w),
                  Text(
                    directionText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: directionColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // My client row
              _ClientRow(
                label: l10n.matchCardMyClient,
                name: myClientName,
                age: myAge,
                isPrimary: true,
                theme: theme,
                l10n: l10n,
              ),

              // Heart divider
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 16.r,
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
                  ),
                ),
              ),

              // Other client row
              _ClientRow(
                label: l10n.matchCardOtherClient,
                name: otherClientName,
                age: otherAge,
                isPrimary: false,
                theme: theme,
                l10n: l10n,
              ),

              SizedBox(height: 12.h),

              // Action buttons for received pending
              if (showReceivedActions)
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _acceptMatch(context, ref, match, l10n),
                        icon: Icon(Icons.check_rounded, size: 16.sp),
                        label: Text(l10n.homeMatchAccept),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _declineMatch(context, ref, match, l10n),
                        icon: Icon(Icons.close_rounded, size: 16.sp),
                        label: Text(l10n.homeMatchDecline),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(color: Color(0xFFC62828)),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    IconButton(
                      onPressed: () => _editNote(context, ref, match, l10n),
                      icon: Icon(Icons.edit_note_rounded, size: 20.sp),
                      color: theme.colorScheme.primary,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      tooltip: l10n.homeMatchMemo,
                    ),
                  ],
                )
              else if (status == 'pending' && isSender)
                // Sent pending: waiting info box + cancel + memo
                Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded,
                              size: 16.sp, color: Colors.amber.shade700),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              l10n.matchDetailWaitingResponse,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _cancelMatch(context, ref, match, l10n),
                            icon: Icon(Icons.close_rounded, size: 18.sp),
                            color: const Color(0xFFC62828),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(4.r),
                            tooltip: l10n.homeMatchCancel,
                          ),
                          SizedBox(width: 4.w),
                          IconButton(
                            onPressed: () =>
                                _editNote(context, ref, match, l10n),
                            icon: Icon(Icons.edit_note_rounded, size: 18.sp),
                            color: theme.colorScheme.primary,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(4.r),
                            tooltip: l10n.homeMatchMemo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // Notes preview
              if (notes != null && notes.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        notes,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Status badge (bottom right) for non-pending
              if (status != 'pending') ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Check verification before allowing accept/decline
  Future<bool> _checkVerification(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final status = await ref.read(managerVerificationStatusProvider.future);
    if (status == 'verified') return true;

    if (!context.mounted) return false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.verified_user_outlined,
          size: 40.r,
          color: Theme.of(ctx).colorScheme.primary,
        ),
        title: Text(l10n.matchSheetVerificationRequired),
        content: Text(
          l10n.matchSheetVerificationBody,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop(); // close sheet
              context.push(AppRoutes.verification);
            },
            child: Text(l10n.matchSheetGoVerify),
          ),
        ],
      ),
    );

    return false;
  }

  Future<void> _acceptMatch(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> match,
    AppLocalizations l10n,
  ) async {
    if (!await _checkVerification(context, ref, l10n)) return;

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.homeMatchAccept),
        content: Text(l10n.matchDetailAcceptConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.homeMatchAccept),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('matches').update({
        'status': 'accepted',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', match['id']);

      ref.invalidate(matchesByStatusProvider('pending'));
      ref.invalidate(matchesByStatusProvider('active'));
      ref.invalidate(homeTodayStatsProvider);
      ref.invalidate(activityFeedProvider);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeMatchAcceptSuccess)),
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

  Future<void> _declineMatch(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> match,
    AppLocalizations l10n,
  ) async {
    if (!await _checkVerification(context, ref, l10n)) return;

    if (!context.mounted) return;
    final reasonController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.homeMatchDecline),
          content: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: l10n.homeMatchDeclineReason,
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
              ),
              child: Text(l10n.homeMatchDecline),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final client = ref.read(supabaseClientProvider);
      final updates = <String, dynamic>{
        'status': 'declined',
        'responded_at': DateTime.now().toIso8601String(),
      };
      if (reasonController.text.trim().isNotEmpty) {
        updates['notes'] = reasonController.text.trim();
      }

      await client.from('matches').update(updates).eq('id', match['id']);

      ref.invalidate(matchesByStatusProvider('pending'));
      ref.invalidate(matchesByStatusProvider('done'));
      ref.invalidate(homeTodayStatsProvider);
      ref.invalidate(activityFeedProvider);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeMatchDeclineSuccess)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError)),
        );
      }
    } finally {
      reasonController.dispose();
    }
  }

  Future<void> _cancelMatch(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> match,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.homeMatchCancel),
        content: Text(l10n.homeMatchCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            child: Text(l10n.homeMatchCancel),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final matchId = match['id'] as String;
      debugPrint('[CancelMatch] Cancelling match: $matchId');
      final client = ref.read(supabaseClientProvider);
      await client.from('matches').update({
        'status': 'cancelled',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', matchId);
      debugPrint('[CancelMatch] Update succeeded for $matchId');

      ref.invalidate(matchesByStatusProvider('pending'));
      ref.invalidate(matchesByStatusProvider('done'));
      ref.invalidate(homeTodayStatsProvider);
      ref.invalidate(activityFeedProvider);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeMatchCancelSuccess)),
        );
      }
    } catch (e, st) {
      debugPrint('Cancel match error: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError)),
        );
      }
    }
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> match,
    AppLocalizations l10n,
  ) async {
    final controller =
        TextEditingController(text: match['notes'] as String? ?? '');

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.homeMatchMemo),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.homeMatchMemoHint),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.commonSave),
            ),
          ],
        ),
      );

      if (saved != true) return;

      final client = ref.read(supabaseClientProvider);
      await client
          .from('matches')
          .update({'notes': controller.text.trim()}).eq('id', match['id']);

      ref.invalidate(matchesByStatusProvider('pending'));
      ref.invalidate(matchesByStatusProvider('active'));
      ref.invalidate(matchesByStatusProvider('done'));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeMatchMemoSaved)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError)),
        );
      }
    } finally {
      controller.dispose();
    }
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({
    required this.label,
    required this.name,
    required this.age,
    required this.isPrimary,
    required this.theme,
    required this.l10n,
  });

  final String label;
  final String name;
  final int? age;
  final bool isPrimary;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color =
        isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (age != null) ...[
                  SizedBox(width: 6.w),
                  Text(
                    l10n.homeAgeSuffix(age!),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
