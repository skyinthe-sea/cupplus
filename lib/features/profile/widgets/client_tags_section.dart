import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/client_tags_provider.dart';

class ClientTagsSection extends ConsumerWidget {
  const ClientTagsSection({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tagsAsync = ref.watch(clientTagsProvider(clientId));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label_rounded, size: 18.r,
                  color: theme.colorScheme.primary),
              SizedBox(width: 6.w),
              Text(
                l10n.crmTagsTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add_rounded, size: 20.r),
                onPressed: () => _showAddTagSheet(context, ref),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) {
                return Text(
                  l10n.crmTagsEmpty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }
              return Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: tags.map((t) {
                  final tagName = t['tag'] as String? ?? '';
                  final tagId = t['id'] as String?;
                  final color = _parseColor(t['color'] as String?);
                  return Chip(
                    label: Text(
                      tagName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    backgroundColor: color.withValues(alpha: 0.1),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                    deleteIcon: Icon(Icons.close, size: 16.r, color: color),
                    onDeleted: tagId == null ? null : () async {
                      try {
                        await ref.read(
                          removeClientTagProvider(
                            tagId: tagId,
                            clientId: clientId,
                          ).future,
                        );
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.commonError)),
                          );
                        }
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              );
            },
            loading: () => SizedBox(
              height: 32.h,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTagSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 16.h,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
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
              l10n.crmTagsAdd,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            // Preset tags
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: kPresetTags.entries.map((e) {
                final color = _parseColor(e.value);
                return ActionChip(
                  label: Text(
                    e.key,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: color.withValues(alpha: 0.1),
                  side: BorderSide(color: color.withValues(alpha: 0.3)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref.read(addClientTagProvider(
                        clientId: clientId,
                        tag: e.key,
                        color: e.value,
                      ).future);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.commonError)),
                        );
                      }
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            // Custom tag input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    decoration: InputDecoration(
                      hintText: l10n.crmTagsCustomHint,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                FilledButton(
                  onPressed: () async {
                    final tag = customController.text.trim();
                    if (tag.isEmpty) return;
                    Navigator.pop(ctx);
                    try {
                      await ref.read(addClientTagProvider(
                        clientId: clientId,
                        tag: tag,
                      ).future);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.commonError)),
                        );
                      }
                    }
                  },
                  child: Text(l10n.crmTagsAddButton),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
    customController.dispose();
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFc8523a);
    final clean = hex.replaceFirst('#', '');
    if (clean.length != 6 || !RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return const Color(0xFFc8523a);
    }
    return Color(int.parse('FF$clean', radix: 16));
  }
}
