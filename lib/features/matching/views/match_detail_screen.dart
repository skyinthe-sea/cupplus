import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/supabase_config.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../home/providers/home_providers.dart';
import '../../verification/providers/verification_provider.dart';

class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(matchDetailProvider(matchId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchDetailTitle, style: TextStyle(fontFamily: serifFontFamily, fontWeight: FontWeight.w700)),
      ),
      body: detailAsync.when(
        data: (data) {
          if (data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 48.r,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3)),
                  SizedBox(height: 12.h),
                  Text(l10n.matchDetailNotFound,
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          return _MatchDetailBody(data: data, matchId: matchId);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonError)),
      ),
    );
  }
}

class _MatchDetailBody extends ConsumerWidget {
  const _MatchDetailBody({required this.data, required this.matchId});

  final Map<String, dynamic> data;
  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final match = data['match'] as Map<String, dynamic>;
    final clientA = data['client_a'] as Map<String, dynamic>?;
    final clientB = data['client_b'] as Map<String, dynamic>?;
    final managerName = data['manager_name'] as String?;
    final conversationId = data['conversation_id'] as String?;
    final isSender = data['is_sender'] as bool? ?? true;
    final status = match['status'] as String? ?? 'pending';

    final myClient = isSender ? clientA : clientB;
    final otherClient = isSender ? clientB : clientA;

    final (statusLabel, statusColor) = _statusInfo(status, l10n, theme);
    final showReceivedActions = !isSender && status == 'pending';

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        // Status badge
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(status), size: 18.r, color: statusColor),
                SizedBox(width: 8.w),
                Text(
                  statusLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isSender && status == 'pending') ...[
                  SizedBox(width: 8.w),
                  Text(
                    '(${l10n.matchCardSent})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // My client card (primary border)
        _ProfileCard(
          client: myClient,
          label: l10n.matchCardMyClient,
          theme: theme,
          l10n: l10n,
          isPrimary: true,
          onTap: myClient != null
              ? () => context.push(
                  AppRoutes.profileDetail(myClient['id'] as String),
                  extra: true)
              : null,
        ),

        // Heart divider
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Expanded(child: Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Icon(
                  Icons.favorite_rounded,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                  size: 24.r,
                ),
              ),
              Expanded(child: Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
            ],
          ),
        ),

        // Other client card
        _ProfileCard(
          client: otherClient,
          label: l10n.matchCardOtherClient,
          theme: theme,
          l10n: l10n,
          isPrimary: false,
          onTap: otherClient != null
              ? () => context.push(
                  AppRoutes.profileDetail(otherClient['id'] as String),
                  extra: true)
              : null,
        ),

        SizedBox(height: 24.h),

        // Match info section
        _InfoSection(
          theme: theme,
          children: [
            _InfoRow(
              label: l10n.matchDetailCreatedBy,
              value: managerName ?? '-',
              theme: theme,
            ),
            _InfoRow(
              label: l10n.matchDetailCreatedAt,
              value: _formatDate(match['matched_at']),
              theme: theme,
            ),
            if (match['responded_at'] != null)
              _InfoRow(
                label: l10n.matchDetailRespondedAt,
                value: _formatDate(match['responded_at']),
                theme: theme,
              ),
            if (match['notes'] != null &&
                (match['notes'] as String).isNotEmpty)
              _InfoRow(
                label: l10n.homeMatchMemo,
                value: match['notes'] as String,
                theme: theme,
              ),
          ],
        ),

        SizedBox(height: 24.h),

        // Action buttons
        if (showReceivedActions) ...[
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      _acceptMatch(context, ref, match, l10n),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.homeMatchAccept),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _declineMatch(context, ref, match, l10n),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(l10n.homeMatchDecline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],

        if (isSender && status == 'pending') ...[
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded,
                    size: 20.r, color: Colors.amber.shade700),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.matchDetailWaitingResponse,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: () => _cancelMatch(context, ref, match, l10n),
            icon: const Icon(Icons.close_rounded),
            label: Text(l10n.homeMatchCancel),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC62828),
              side: const BorderSide(color: Color(0xFFC62828)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],

        if (conversationId != null) ...[
          SizedBox(height: 12.h),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.chatRoom(conversationId)),
            icon: const Icon(Icons.chat_bubble_rounded),
            label: Text(l10n.matchDetailOpenChat),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],

        SizedBox(height: 40.h),
      ],
    );
  }

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
      builder: (_) => AppDialog(
        icon: Icons.verified_user_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        title: l10n.matchSheetVerificationRequired,
        content: l10n.matchSheetVerificationBody,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.matchSheetGoVerify,
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          context.push(AppRoutes.verification);
        },
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
      builder: (_) => AppDialog(
        icon: Icons.check_circle_rounded,
        title: l10n.homeMatchAccept,
        content: l10n.matchDetailAcceptConfirm,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.homeMatchAccept,
      ),
    );

    if (confirmed != true) return;

    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('matches').update({
        'status': 'accepted',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', match['id']);

      ref.invalidate(matchDetailProvider(matchId));
      ref.invalidate(matchesByStatusProvider('pending'));
      ref.invalidate(matchesByStatusProvider('active'));
      ref.invalidate(homeTodayStatsProvider);
      ref.invalidate(activityFeedProvider);

      if (context.mounted) {
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
        builder: (_) => AppDialog(
          icon: Icons.close_rounded,
          title: l10n.homeMatchDecline,
          contentWidget: TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: l10n.homeMatchDeclineReason,
            ),
            maxLines: 2,
          ),
          cancelLabel: l10n.commonCancel,
          confirmLabel: l10n.homeMatchDecline,
          isDestructive: true,
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

      ref.invalidate(matchDetailProvider(matchId));
      ref.invalidate(matchesByStatusProvider('pending'));
      ref.invalidate(matchesByStatusProvider('done'));
      ref.invalidate(homeTodayStatsProvider);
      ref.invalidate(activityFeedProvider);

      if (context.mounted) {
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
      builder: (_) => AppDialog(
        icon: Icons.cancel_rounded,
        title: l10n.homeMatchCancel,
        content: l10n.homeMatchCancelConfirm,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.homeMatchCancel,
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('matches').update({
        'status': 'cancelled',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', match['id']);

      ref.invalidate(matchDetailProvider(matchId));
      ref.invalidate(matchesByStatusProvider('pending'));
      ref.invalidate(matchesByStatusProvider('done'));
      ref.invalidate(homeTodayStatsProvider);
      ref.invalidate(activityFeedProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeMatchCancelSuccess)),
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

  (String, Color) _statusInfo(
      String status, AppLocalizations l10n, ThemeData theme) {
    return switch (status) {
      'pending' => (l10n.matchStatusPending, Colors.amber.shade700),
      'accepted' => (l10n.matchStatusAccepted, Colors.green.shade600),
      'declined' => (l10n.matchStatusDeclined, theme.colorScheme.error),
      'cancelled' => (l10n.matchStatusCancelled, theme.colorScheme.error),
      'meeting_scheduled' => (
        l10n.matchStatusMeetingScheduled,
        theme.colorScheme.primary
      ),
      'completed' => (l10n.matchStatusCompleted, theme.colorScheme.secondary),
      _ => (status, theme.colorScheme.onSurfaceVariant),
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'pending' => Icons.schedule_rounded,
      'accepted' => Icons.check_circle_rounded,
      'declined' => Icons.cancel_rounded,
      'cancelled' => Icons.cancel_rounded,
      'meeting_scheduled' => Icons.event_rounded,
      'completed' => Icons.task_alt_rounded,
      _ => Icons.info_rounded,
    };
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      final dt = DateTime.parse(value as String);
      return DateFormat('yyyy.MM.dd HH:mm').format(dt);
    } catch (_) {
      return '-';
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.client,
    required this.label,
    required this.theme,
    required this.l10n,
    required this.isPrimary,
    this.onTap,
  });

  final Map<String, dynamic>? client;
  final String label;
  final ThemeData theme;
  final AppLocalizations l10n;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (client == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Center(child: Text('-', style: theme.textTheme.bodyLarge)),
        ),
      );
    }

    final name = client!['full_name'] as String? ?? '-';
    final gender = client!['gender'] as String? ?? '';
    final occupation = client!['occupation'] as String? ?? '';
    final education = client!['education'] as String? ?? '';
    final birthDate = client!['birth_date'] as String?;
    final heightCm = client!['height_cm'] as int?;

    int? age;
    if (birthDate != null) {
      final birth = DateTime.parse(birthDate);
      age = DateTime.now().year - birth.year;
    }

    final genderIcon =
        gender == 'F' ? Icons.female_rounded : Icons.male_rounded;
    final genderColor =
        gender == 'F' ? const Color(0xFFE91E63) : const Color(0xFF2196F3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isPrimary
                ? Theme.of(context).extension<HomeColors>()!.pointColor.withValues(alpha: 0.5)
                : Theme.of(context).extension<HomeColors>()!.borderColor,
            width: isPrimary ? 1.5 : 1,
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
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: genderColor.withValues(alpha: 0.12),
                child: Icon(genderIcon, color: genderColor, size: 24.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isPrimary
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: isPrimary
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        if (age != null)
                          _InfoChip(
                              text: l10n.homeAgeSuffix(age), theme: theme),
                        if (occupation.isNotEmpty)
                          _InfoChip(text: occupation, theme: theme),
                        if (education.isNotEmpty)
                          _InfoChip(text: education, theme: theme),
                        if (heightCm != null)
                          _InfoChip(
                              text: l10n.homeHeightCm(heightCm), theme: theme),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text, required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.theme, required this.children});

  final ThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: homeColors.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: homeColors.borderColor,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
