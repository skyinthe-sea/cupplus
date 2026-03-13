import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../models/client_note.dart';
import '../providers/client_notes_provider.dart';
import 'add_note_sheet.dart';

class ClientTimeline extends ConsumerWidget {
  const ClientTimeline({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(clientNotesProvider(clientId));
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.crmNotesTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => AddNoteSheet.show(context, clientId),
                    icon: Icon(Icons.add, size: 16.r),
                    label: Text(l10n.crmNoteAdd),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: Text(
                          l10n.crmNoteEmpty,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: notes.map((note) => _NoteItem(
                      note: note,
                      clientId: clientId,
                    )).toList(),
                  );
                },
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(child: Text(l10n.commonError)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteItem extends ConsumerWidget {
  const _NoteItem({required this.note, required this.clientId});

  final ClientNote note;
  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final typeColor = switch (note.noteType) {
      'preference' => Colors.purple,
      'meeting_feedback' => Colors.orange,
      'schedule' => Colors.blue,
      _ => theme.colorScheme.primary,
    };

    final typeLabel = switch (note.noteType) {
      'general' => l10n.crmNoteTypeGeneral,
      'preference' => l10n.crmNoteTypePreference,
      'meeting_feedback' => l10n.crmNoteTypeMeetingFeedback,
      'schedule' => l10n.crmNoteTypeSchedule,
      _ => note.noteType,
    };

    final date = note.createdAt;
    final dateStr = date != null
        ? '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: typeColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: note.isCompleted ? TextDecoration.lineThrough : null,
                    color: note.isCompleted
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (note.scheduledAt != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      '${l10n.crmNoteScheduleAt}: ${note.scheduledAt!.year}.${note.scheduledAt!.month.toString().padLeft(2, '0')}.${note.scheduledAt!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          if (note.noteType == 'schedule')
            IconButton(
              icon: Icon(
                note.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                size: 18.r,
                color: note.isCompleted ? Colors.green : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () => ref.read(
                toggleNoteCompletedProvider(note.id, clientId, isCompleted: !note.isCompleted).future,
              ),
              constraints: BoxConstraints(maxWidth: 32.r, maxHeight: 32.r),
              padding: EdgeInsets.zero,
            ),
          IconButton(
            icon: Icon(Icons.close, size: 14.r, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: Text(l10n.crmNoteDeleteConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.commonCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.commonDelete),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(deleteClientNoteProvider(note.id, clientId).future);
              }
            },
            constraints: BoxConstraints(maxWidth: 24.r, maxHeight: 24.r),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
