import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/marketplace_providers.dart';

class MarketplaceFilterSheet extends ConsumerStatefulWidget {
  const MarketplaceFilterSheet({super.key});

  @override
  ConsumerState<MarketplaceFilterSheet> createState() =>
      _MarketplaceFilterSheetState();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MarketplaceFilterSheet(),
    );
  }
}

class _MarketplaceFilterSheetState
    extends ConsumerState<MarketplaceFilterSheet> {
  late RangeValues _ageRange;
  late RangeValues _heightRange;
  String? _selectedReligion;
  late bool _verifiedOnly;

  static const _religions = [
    '무교',
    '기독교',
    '천주교',
    '불교',
    '원불교',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    final filter = ref.read(marketplaceFilterNotifierProvider);
    _ageRange = RangeValues(
      (filter.minAge ?? 20).toDouble(),
      (filter.maxAge ?? 45).toDouble(),
    );
    _heightRange = RangeValues(
      (filter.minHeight ?? 150).toDouble(),
      (filter.maxHeight ?? 195).toDouble(),
    );
    _selectedReligion = filter.religion;
    _verifiedOnly = filter.isVerifiedOnly;
  }

  void _apply() {
    final notifier = ref.read(marketplaceFilterNotifierProvider.notifier);
    final hasAgeFilter =
        _ageRange.start > 20 || _ageRange.end < 45;
    final hasHeightFilter =
        _heightRange.start > 150 || _heightRange.end < 195;

    notifier.updateAgeRange(
      hasAgeFilter ? _ageRange.start.round() : null,
      hasAgeFilter ? _ageRange.end.round() : null,
    );
    notifier.updateHeightRange(
      hasHeightFilter ? _heightRange.start.round() : null,
      hasHeightFilter ? _heightRange.end.round() : null,
    );
    notifier.updateReligion(_selectedReligion);
    notifier.updateVerifiedOnly(_verifiedOnly);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _ageRange = const RangeValues(20, 45);
      _heightRange = const RangeValues(150, 195);
      _selectedReligion = null;
      _verifiedOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Text(
                  l10n.marketplaceFilterTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clear,
                  child: Text(l10n.marketplaceFilterClear),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Age range
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.marketplaceFilterAge(
                    _ageRange.start.round(),
                    _ageRange.end.round(),
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                RangeSlider(
                  values: _ageRange,
                  min: 20,
                  max: 45,
                  divisions: 25,
                  labels: RangeLabels(
                    '${_ageRange.start.round()}',
                    '${_ageRange.end.round()}',
                  ),
                  onChanged: (values) =>
                      setState(() => _ageRange = values),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Height range
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.marketplaceFilterHeight(
                    _heightRange.start.round(),
                    _heightRange.end.round(),
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                RangeSlider(
                  values: _heightRange,
                  min: 150,
                  max: 195,
                  divisions: 45,
                  labels: RangeLabels(
                    '${_heightRange.start.round()}cm',
                    '${_heightRange.end.round()}cm',
                  ),
                  onChanged: (values) =>
                      setState(() => _heightRange = values),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Religion
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileReligion,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _religions.map((religion) {
                    final selected = _selectedReligion == religion;
                    return ChoiceChip(
                      label: Text(religion),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          _selectedReligion = value ? religion : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Verified toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 20.r,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    l10n.marketplaceFilterVerifiedOnly,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: _verifiedOnly,
                  onChanged: (value) =>
                      setState(() => _verifiedOnly = value),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Apply button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: FilledButton(
              onPressed: _apply,
              child: Text(l10n.marketplaceFilterApply),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }
}
