import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../config/supabase_config.dart';
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
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                  _MatchTab(status: 'pending', showActions: true),
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
    this.showActions = false,
  });

  final String status;
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final matchesAsync = ref.watch(matchesByStatusProvider(status));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Text(
              status == 'pending'
                  ? l10n.matchesEmptyPendingTitle
                  : status == 'active'
                      ? l10n.matchesEmptyActiveTitle
                      : l10n.matchesEmptyDoneTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _MatchCard(
              match: match,
              showActions: showActions,
            );
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
    this.showActions = false,
  });

  final Map<String, dynamic> match;
  final bool showActions;

  String _genderLabel(String? gender, AppLocalizations l10n) {
    return switch (gender) {
      'M' => l10n.homeGenderMale,
      'F' => l10n.homeGenderFemale,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final clientA = match['client_a'] as Map<String, dynamic>?;
    final clientB = match['client_b'] as Map<String, dynamic>?;
    final clientAName = clientA?['full_name'] as String? ?? '?';
    final clientBName = clientB?['full_name'] as String? ?? '?';
    final clientAGenderLabel =
        _genderLabel(clientA?['gender'] as String?, l10n);
    final clientBGenderLabel =
        _genderLabel(clientB?['gender'] as String?, l10n);
    final status = match['status'] as String? ?? 'pending';
    final matchedAt = match['matched_at'] as String?;
    final notes = match['notes'] as String?;

    String dateText = '';
    if (matchedAt != null) {
      dateText = DateFormat('yyyy.MM.dd').format(DateTime.parse(matchedAt));
    }

    final statusColor = switch (status) {
      'pending' => Colors.amber.shade700,
      'accepted' || 'meeting_scheduled' => const Color(0xFF2E7D32),
      'declined' => const Color(0xFFC62828),
      'completed' => theme.colorScheme.primary,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    final statusText = switch (status) {
      'pending' => l10n.matchStatusPending,
      'accepted' => l10n.matchStatusAccepted,
      'declined' => l10n.matchStatusDeclined,
      'meeting_scheduled' => l10n.matchStatusMeetingScheduled,
      'completed' => l10n.matchStatusCompleted,
      _ => status,
    };

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$clientAName${clientAGenderLabel.isNotEmpty ? ' ($clientAGenderLabel)' : ''} ↔ $clientBName${clientBGenderLabel.isNotEmpty ? ' ($clientBGenderLabel)' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
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
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              dateText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (notes != null && notes.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (showActions) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  _ActionButton(
                    label: l10n.homeMatchAccept,
                    color: const Color(0xFF2E7D32),
                    onTap: () => _acceptMatch(context, ref, match, l10n),
                  ),
                  SizedBox(width: 8.w),
                  _ActionButton(
                    label: l10n.homeMatchDecline,
                    color: const Color(0xFFC62828),
                    onTap: () => _declineMatch(context, ref, match, l10n),
                  ),
                  SizedBox(width: 8.w),
                  _ActionButton(
                    label: l10n.homeMatchMemo,
                    color: theme.colorScheme.primary,
                    onTap: () => _editNote(context, ref, match, l10n),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _acceptMatch(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> match,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.homeMatchAccept),
        content: Text(l10n.commonConfirm),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
