import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/routes.dart';
import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';

class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final client = ref.watch(supabaseClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchDetailTitle),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchMatchDetail(client, matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
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

          final data = snapshot.data!;
          return _MatchDetailBody(data: data);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchMatchDetail(
    SupabaseClient client,
    String matchId,
  ) async {
    final matchRows = await client
        .from('matches')
        .select()
        .eq('id', matchId)
        .limit(1);

    if (matchRows.isEmpty) return null;
    final match = matchRows.first;

    // Fetch both clients
    final clientAId = match['client_a_id'] as String?;
    final clientBId = match['client_b_id'] as String?;

    final clientIds = [
      if (clientAId != null) clientAId,
      if (clientBId != null) clientBId,
    ];

    Map<String, Map<String, dynamic>> clientMap = {};
    if (clientIds.isNotEmpty) {
      final clientRows =
          await client.from('clients').select().inFilter('id', clientIds);
      for (final c in clientRows) {
        clientMap[c['id'] as String] = c;
      }
    }

    // Fetch manager name
    final managerId = match['manager_id'] as String?;
    String? managerName;
    if (managerId != null) {
      final mgrRows = await client
          .from('managers')
          .select('full_name')
          .eq('id', managerId)
          .limit(1);
      if (mgrRows.isNotEmpty) {
        managerName = mgrRows.first['full_name'] as String?;
      }
    }

    // Fetch conversation if exists (for chat navigation)
    String? conversationId;
    final convRows = await client
        .from('conversations')
        .select('id')
        .eq('match_id', matchId)
        .limit(1);
    if (convRows.isNotEmpty) {
      conversationId = convRows.first['id'] as String;
    }

    return {
      'match': match,
      'client_a': clientMap[clientAId],
      'client_b': clientMap[clientBId],
      'manager_name': managerName,
      'conversation_id': conversationId,
    };
  }
}

class _MatchDetailBody extends StatelessWidget {
  const _MatchDetailBody({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final match = data['match'] as Map<String, dynamic>;
    final clientA = data['client_a'] as Map<String, dynamic>?;
    final clientB = data['client_b'] as Map<String, dynamic>?;
    final managerName = data['manager_name'] as String?;
    final conversationId = data['conversation_id'] as String?;
    final status = match['status'] as String? ?? 'pending';

    final (statusLabel, statusColor) = _statusInfo(status, l10n, theme);

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
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Bilateral profile cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ClientProfileCard(
                client: clientA,
                label: l10n.matchDetailClientA,
                theme: theme,
                l10n: l10n,
                onTap: clientA != null
                    ? () => context
                        .push(AppRoutes.profileDetail(clientA['id'] as String))
                    : null,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40.h),
              child: Icon(
                Icons.favorite_rounded,
                color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                size: 24.r,
              ),
            ),
            Expanded(
              child: _ClientProfileCard(
                client: clientB,
                label: l10n.matchDetailClientB,
                theme: theme,
                l10n: l10n,
                onTap: clientB != null
                    ? () => context
                        .push(AppRoutes.profileDetail(clientB['id'] as String))
                    : null,
              ),
            ),
          ],
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

        // Actions
        if (conversationId != null)
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

        SizedBox(height: 40.h),
      ],
    );
  }

  (String, Color) _statusInfo(
      String status, AppLocalizations l10n, ThemeData theme) {
    return switch (status) {
      'pending' => (l10n.matchStatusPending, Colors.amber.shade700),
      'accepted' => (l10n.matchStatusAccepted, Colors.green.shade600),
      'declined' => (l10n.matchStatusDeclined, theme.colorScheme.error),
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

class _ClientProfileCard extends StatelessWidget {
  const _ClientProfileCard({
    required this.client,
    required this.label,
    required this.theme,
    required this.l10n,
    this.onTap,
  });

  final Map<String, dynamic>? client;
  final String label;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (client == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Center(child: Text('-', style: theme.textTheme.bodyLarge)),
        ),
      );
    }

    final name = client!['full_name'] as String? ?? '-';
    final gender = client!['gender'] as String? ?? '';
    final occupation = client!['occupation'] as String? ?? '';
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
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Column(
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8.h),
              CircleAvatar(
                radius: 28.r,
                backgroundColor: genderColor.withValues(alpha: 0.12),
                child: Icon(genderIcon, color: genderColor, size: 24.r),
              ),
              SizedBox(height: 8.h),
              Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              if (age != null)
                Text(
                  l10n.homeAgeSuffix(age),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (occupation.isNotEmpty)
                Text(
                  occupation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (heightCm != null)
                Text(
                  l10n.homeHeightCm(heightCm),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              SizedBox(height: 4.h),
              if (onTap != null)
                Text(
                  l10n.myProfileDetail,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
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
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
