import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/supabase_config.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/providers/home_providers.dart';
import '../../verification/providers/verification_provider.dart';

class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final homeColors = theme.extension<HomeColors>()!;
    final detailAsync = ref.watch(matchDetailProvider(matchId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16.sp, color: homeColors.pointColor),
            SizedBox(width: 6.w),
            Text(
              l10n.matchDetailTitle,
              style: TextStyle(
                fontFamily: serifFontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

class _MatchDetailBody extends ConsumerStatefulWidget {
  const _MatchDetailBody({required this.data, required this.matchId});

  final Map<String, dynamic> data;
  final String matchId;

  @override
  ConsumerState<_MatchDetailBody> createState() => _MatchDetailBodyState();
}

class _MatchDetailBodyState extends ConsumerState<_MatchDetailBody>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final homeColors = theme.extension<HomeColors>()!;
    final pointColor = homeColors.pointColor;

    final match = widget.data['match'] as Map<String, dynamic>;
    final clientA = widget.data['client_a'] as Map<String, dynamic>?;
    final clientB = widget.data['client_b'] as Map<String, dynamic>?;
    final managerName = widget.data['manager_name'] as String?;
    final conversationId = widget.data['conversation_id'] as String?;
    final isSender = widget.data['is_sender'] as bool? ?? true;
    final status = match['status'] as String? ?? 'pending';
    final notes = match['notes'] as String?;

    final myClient = isSender ? clientA : clientB;
    final otherClient = isSender ? clientB : clientA;

    final (statusLabel, statusColor) = _statusInfo(status, l10n, theme);
    final showReceivedActions = !isSender && status == 'pending';
    final showSentPending = isSender && status == 'pending';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        children: [
          // ── Invitation header ──
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  homeColors.pendingCardBg.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 14.sp, color: pointColor),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.matchInvitation.toUpperCase(),
                      style: TextStyle(
                        fontFamily: serifFontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: pointColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                // Status badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status),
                          size: 15.r, color: statusColor),
                      SizedBox(width: 6.w),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      if (isSender && status == 'pending') ...[
                        SizedBox(width: 6.w),
                        Text(
                          '· ${l10n.matchCardSent}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: statusColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // ── My client card ──
          _InvitationProfileCard(
            client: myClient,
            label: l10n.matchCardMyClient,
            isPrimary: true,
            onTap: myClient != null
                ? () => context.push(
                    AppRoutes.profileDetail(myClient['id'] as String),
                    extra: true)
                : null,
          ),

          // ── Heart divider ──
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: pointColor.withValues(alpha: 0.15),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: pointColor.withValues(alpha: 0.5),
                      size: 22.r,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: pointColor.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),

          // ── Other client card ──
          _InvitationProfileCard(
            client: otherClient,
            label: l10n.matchCardOtherClient,
            isPrimary: false,
            onTap: otherClient != null
                ? () => context.push(
                    AppRoutes.profileDetail(otherClient['id'] as String),
                    extra: true)
                : null,
          ),

          SizedBox(height: 20.h),

          // ── Match info section ──
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  homeColors.pendingCardBg.withValues(alpha: 0.15),
                  homeColors.cardColor,
                ],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: pointColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: l10n.matchDetailCreatedBy,
                  value: managerName ?? '-',
                ),
                Divider(
                    height: 16.h,
                    color: pointColor.withValues(alpha: 0.08)),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.matchDetailCreatedAt,
                  value: _formatDate(match['matched_at']),
                ),
                if (match['responded_at'] != null) ...[
                  Divider(
                      height: 16.h,
                      color: pointColor.withValues(alpha: 0.08)),
                  _InfoRow(
                    icon: Icons.reply_rounded,
                    label: l10n.matchDetailRespondedAt,
                    value: _formatDate(match['responded_at']),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ── Memo section ──
          GestureDetector(
            onTap: () => _editNote(context, ref, match, l10n),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: homeColors.cardColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: homeColors.borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 20.r,
                    color: pointColor.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeMatchMemo,
                          style: TextStyle(
                            fontFamily: serifFontFamily,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: pointColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          (notes != null && notes.isNotEmpty)
                              ? notes
                              : l10n.homeMatchMemoHint,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: (notes != null && notes.isNotEmpty)
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                            fontStyle: (notes != null && notes.isNotEmpty)
                                ? FontStyle.normal
                                : FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.r,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // ── Action buttons ──

          // Received pending → accept / decline
          if (showReceivedActions) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _InvitationButton(
                    onPressed: () =>
                        _acceptMatch(context, ref, match, l10n),
                    icon: Icons.check_rounded,
                    label: l10n.homeMatchAccept,
                    backgroundColor: homeColors.ctaBar,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: _InvitationButton(
                    onPressed: () =>
                        _declineMatch(context, ref, match, l10n),
                    icon: Icons.close_rounded,
                    label: l10n.homeMatchDecline,
                    backgroundColor: Colors.transparent,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    borderColor: theme.colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],

          // Sent pending → waiting + cancel
          if (showSentPending) ...[
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: pointColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: pointColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded,
                      size: 18.r, color: pointColor.withValues(alpha: 0.6)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      l10n.matchDetailWaitingResponse,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            _InvitationButton(
              onPressed: () =>
                  _cancelMatch(context, ref, match, l10n),
              icon: Icons.close_rounded,
              label: l10n.homeMatchCancel,
              backgroundColor: Colors.transparent,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              borderColor: theme.colorScheme.outlineVariant,
            ),
            SizedBox(height: 12.h),
          ],

          // Chat button
          if (conversationId != null) ...[
            _InvitationButton(
              onPressed: () =>
                  context.push(AppRoutes.chatRoom(conversationId)),
              icon: Icons.chat_bubble_rounded,
              label: l10n.matchDetailOpenChat,
              backgroundColor: homeColors.ctaBar,
              foregroundColor: Colors.white,
            ),
          ],

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ── Action handlers ──

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
      builder: (ctx) => _InvitationDialog(
        icon: Icons.verified_user_outlined,
        title: l10n.matchSheetVerificationRequired,
        content: l10n.matchSheetVerificationBody,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.matchSheetGoVerify,
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () {
          Navigator.pop(ctx);
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
      builder: (ctx) => _InvitationDialog(
        icon: Icons.favorite_rounded,
        title: l10n.homeMatchAccept,
        content: l10n.matchDetailAcceptConfirm,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.homeMatchAccept,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('matches').update({
        'status': 'accepted',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', match['id']);

      ref.invalidate(matchDetailProvider(widget.matchId));
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
        builder: (ctx) => _InvitationDialog(
          icon: Icons.heart_broken_rounded,
          title: l10n.homeMatchDecline,
          contentWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.homeMatchDeclineReason,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.homeMatchMemoHint,
                  hintStyle: TextStyle(fontSize: 13.sp),
                  contentPadding: EdgeInsets.all(12.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ),
          cancelLabel: l10n.commonCancel,
          confirmLabel: l10n.homeMatchDecline,
        ),
      );

      if (confirmed != true || !context.mounted) return;

      final client = ref.read(supabaseClientProvider);
      final updates = <String, dynamic>{
        'status': 'declined',
        'responded_at': DateTime.now().toIso8601String(),
      };
      if (reasonController.text.trim().isNotEmpty) {
        updates['notes'] = reasonController.text.trim();
      }

      await client.from('matches').update(updates).eq('id', match['id']);

      ref.invalidate(matchDetailProvider(widget.matchId));
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
      builder: (ctx) => _InvitationDialog(
        icon: Icons.cancel_outlined,
        title: l10n.homeMatchCancel,
        content: l10n.homeMatchCancelConfirm,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.homeMatchCancel,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('matches').update({
        'status': 'cancelled',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', match['id']);

      ref.invalidate(matchDetailProvider(widget.matchId));
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
        builder: (ctx) => _InvitationDialog(
          icon: Icons.edit_note_rounded,
          title: l10n.homeMatchMemo,
          contentWidget: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.homeMatchMemoHint,
              hintStyle: TextStyle(fontSize: 13.sp),
              contentPadding: EdgeInsets.all(12.r),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            style: TextStyle(fontSize: 13.sp),
          ),
          cancelLabel: l10n.commonCancel,
          confirmLabel: l10n.commonSave,
        ),
      );

      if (saved != true || !context.mounted) return;

      final client = ref.read(supabaseClientProvider);
      await client
          .from('matches')
          .update({'notes': controller.text.trim()}).eq('id', match['id']);

      ref.invalidate(matchDetailProvider(widget.matchId));
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

  // ── Helpers ──

  (String, Color) _statusInfo(
      String status, AppLocalizations l10n, ThemeData theme) {
    final homeColors = theme.extension<HomeColors>()!;
    return switch (status) {
      'pending' => (l10n.matchStatusPending, homeColors.pointColor),
      'accepted' => (l10n.matchStatusAccepted, theme.colorScheme.secondary),
      'declined' => (l10n.matchStatusDeclined, theme.colorScheme.tertiary),
      'cancelled' => (l10n.matchStatusCancelled, theme.colorScheme.onSurfaceVariant),
      'meeting_scheduled' => (
        l10n.matchStatusMeetingScheduled,
        theme.colorScheme.secondary
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Private widgets
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _InvitationProfileCard extends StatelessWidget {
  const _InvitationProfileCard({
    required this.client,
    required this.label,
    required this.isPrimary,
    this.onTap,
  });

  final Map<String, dynamic>? client;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final homeColors = theme.extension<HomeColors>()!;
    final pointColor = homeColors.pointColor;

    if (client == null) {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: homeColors.cardColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: homeColors.borderColor),
        ),
        child: Center(
            child: Text('-', style: theme.textTheme.bodyLarge)),
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
      try {
        final birth = DateTime.parse(birthDate);
        age = DateTime.now().year - birth.year;
      } catch (_) {}
    }

    // Gender uses app palette: F → tertiary (dusty rose), M → secondary (muted violet)
    final genderIcon =
        gender == 'F' ? Icons.female_rounded : Icons.male_rounded;
    final genderColor =
        gender == 'F' ? theme.colorScheme.tertiary : theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              homeColors.pendingCardBg.withValues(alpha: isPrimary ? 0.2 : 0.08),
              homeColors.cardColor,
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isPrimary
                ? pointColor.withValues(alpha: 0.35)
                : homeColors.borderColor,
            width: isPrimary ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: genderColor.withValues(alpha: 0.1),
                child: Icon(genderIcon, color: genderColor, size: 22.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? pointColor.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isPrimary
                              ? pointColor
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: serifFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Wrap(
                      spacing: 6.w,
                      children: [
                        if (age != null)
                          Text(l10n.homeAgeSuffix(age),
                              style: _chipStyle(theme)),
                        if (occupation.isNotEmpty)
                          Text(occupation, style: _chipStyle(theme)),
                        if (education.isNotEmpty)
                          Text(education, style: _chipStyle(theme)),
                        if (heightCm != null)
                          Text(l10n.homeHeightCm(heightCm),
                              style: _chipStyle(theme)),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                  size: 22.r,
                ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _chipStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 12.sp,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 16.r,
              color: homeColors.pointColor.withValues(alpha: 0.5)),
          SizedBox(width: 10.w),
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationButton extends StatelessWidget {
  const _InvitationButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final isOutlined = backgroundColor == Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
            boxShadow: !isOutlined
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.r, color: foregroundColor),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog with invitation tone — uses app palette only.
class _InvitationDialog extends StatelessWidget {
  const _InvitationDialog({
    this.icon,
    required this.title,
    this.content,
    this.contentWidget,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
  });

  final IconData? icon;
  final String title;
  final String? content;
  final Widget? contentWidget;
  final String? cancelLabel;
  final String? confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeColors = theme.extension<HomeColors>()!;
    final pointColor = homeColors.pointColor;

    return Dialog(
      backgroundColor: homeColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: pointColor.withValues(alpha: 0.12)),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              homeColors.pendingCardBg.withValues(alpha: 0.15),
              homeColors.cardColor,
            ],
            stops: const [0.0, 0.35],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✦ accent
              Icon(Icons.auto_awesome,
                  size: 12.sp,
                  color: pointColor.withValues(alpha: 0.5)),
              SizedBox(height: 12.h),

              // Icon — always uses pointColor
              if (icon != null) ...[
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: pointColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28.r,
                    color: pointColor,
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Title
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

              // Content
              if (content != null) ...[
                SizedBox(height: 10.h),
                Text(
                  content!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:
                        homeColors.textPrimary.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (contentWidget != null) ...[
                SizedBox(height: 14.h),
                contentWidget!,
              ],

              SizedBox(height: 24.h),

              // Buttons — confirm uses ctaBar, cancel uses muted text
              Row(
                children: [
                  if (cancelLabel != null) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: onCancel ??
                            () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          cancelLabel!,
                          style: TextStyle(
                            color: homeColors.textPrimary
                                .withValues(alpha: 0.5),
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
                        onPressed: onConfirm ??
                            () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: homeColors.ctaBar,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          confirmLabel!,
                          style: const TextStyle(
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
      ),
    );
  }
}
