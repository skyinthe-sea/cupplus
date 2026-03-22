import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
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
            return _MatchCard(match: match, index: index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.commonError)),
    );
  }
}

class _MatchCard extends StatefulWidget {
  const _MatchCard({
    required this.match,
    required this.index,
  });

  final Map<String, dynamic> match;
  final int index;

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final homeColors = theme.extension<HomeColors>()!;

    final match = widget.match;
    final myClient = match['my_client'] as Map<String, dynamic>?;
    final otherClient = match['other_client'] as Map<String, dynamic>?;
    final myClientName = myClient?['full_name'] as String? ?? '?';
    final otherClientName = otherClient?['full_name'] as String? ?? '?';
    final myAge = _calcAge(myClient?['birth_date'] as String?);
    final otherAge = _calcAge(otherClient?['birth_date'] as String?);
    final status = match['status'] as String? ?? 'pending';
    final isSender = match['is_sender'] as bool? ?? true;
    final matchedAt = match['matched_at'] as String?;

    String dateText = '';
    if (matchedAt != null) {
      dateText = DateFormat('yyyy.MM.dd').format(DateTime.parse(matchedAt));
    }

    final statusColor = switch (status) {
      'pending' => homeColors.pointColor,
      'accepted' || 'meeting_scheduled' => theme.colorScheme.secondary,
      'declined' => theme.colorScheme.tertiary,
      'cancelled' => theme.colorScheme.onSurfaceVariant,
      'completed' => theme.colorScheme.secondary,
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

    final directionText =
        isSender ? l10n.matchCardSent : l10n.matchCardReceived;
    final directionIcon =
        isSender ? Icons.call_made_rounded : Icons.call_received_rounded;

    final pointColor = homeColors.pointColor;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            final matchId = match['id'] as String?;
            if (matchId != null) {
              Navigator.of(context).pop();
              context.push(AppRoutes.matchDetail(matchId));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  homeColors.pendingCardBg.withValues(alpha: 0.3),
                  homeColors.cardColor,
                ],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: pointColor.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
              child: Column(
                children: [
                  // Title: ✦ MATCH INVITATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14.sp,
                        color: pointColor,
                      ),
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

                  SizedBox(height: 18.h),

                  // Two avatars with heart line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // My client avatar + info
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundColor:
                                  theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Text(
                                myClientName.isNotEmpty ? myClientName[0] : '?',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              myClientName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (myAge != null)
                              Text(
                                l10n.homeAgeSuffix(myAge),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Dashed line + heart
                      SizedBox(
                        width: 80.w,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: pointColor.withValues(alpha: 0.3),
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: ScaleTransition(
                                scale: _pulseAnimation,
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: 18.r,
                                  color: pointColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: pointColor.withValues(alpha: 0.3),
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Other client avatar + info
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundColor: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.1),
                              child: Text(
                                otherClientName.isNotEmpty
                                    ? otherClientName[0]
                                    : '?',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              otherClientName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (otherAge != null)
                              Text(
                                l10n.homeAgeSuffix(otherAge),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Bottom: direction + date + status
                  Row(
                    children: [
                      Icon(directionIcon, size: 12.sp,
                          color: theme.colorScheme.onSurfaceVariant),
                      SizedBox(width: 4.w),
                      Text(
                        directionText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // Status badge for non-pending
                  if (status != 'pending') ...[
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
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
        ),
      ),
    );
  }
}
