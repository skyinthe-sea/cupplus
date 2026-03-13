import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/client_notes_provider.dart';

class AddNoteSheet extends ConsumerStatefulWidget {
  const AddNoteSheet({super.key, required this.clientId});

  final String clientId;

  static Future<void> show(BuildContext context, String clientId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddNoteSheet(clientId: clientId),
    );
  }

  @override
  ConsumerState<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<AddNoteSheet> {
  final _contentCtrl = TextEditingController();
  String _noteType = 'general';
  DateTime? _scheduledAt;
  bool _saving = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_contentCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);

    try {
      await ref.read(
        addClientNoteProvider(
          clientId: widget.clientId,
          noteType: _noteType,
          content: _contentCtrl.text.trim(),
          scheduledAt: _noteType == 'schedule' ? _scheduledAt : null,
        ).future,
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.crmNoteSaved)),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _scheduledAt = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final noteTypes = [
      ('general', l10n.crmNoteTypeGeneral),
      ('preference', l10n.crmNoteTypePreference),
      ('meeting_feedback', l10n.crmNoteTypeMeetingFeedback),
      ('schedule', l10n.crmNoteTypeSchedule),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.crmNoteAdd,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),

          // Note type chips
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: noteTypes.map((t) {
              final selected = _noteType == t.$1;
              return ChoiceChip(
                label: Text(t.$2),
                selected: selected,
                onSelected: (_) => setState(() => _noteType = t.$1),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),

          // Content
          TextFormField(
            controller: _contentCtrl,
            decoration: InputDecoration(
              hintText: l10n.crmNoteContentHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 500,
          ),

          // Schedule date (only for schedule type)
          if (_noteType == 'schedule') ...[
            SizedBox(height: 8.h),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.crmNoteScheduleAt,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _scheduledAt != null
                      ? '${_scheduledAt!.year}.${_scheduledAt!.month.toString().padLeft(2, '0')}.${_scheduledAt!.day.toString().padLeft(2, '0')}'
                      : '',
                ),
              ),
            ),
          ],

          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.commonSave),
            ),
          ),
        ],
      ),
    );
  }
}
