import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/label_formatters.dart';
import '../models/filter_preset.dart';
import '../models/marketplace_filter.dart';
import '../providers/filter_preset_provider.dart';
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
  String? _selectedEducation;
  late List<String> _selectedOccupations;
  String? _selectedIncome;
  late SortOrder _sortOrder;
  String? _selectedDrinking;
  String? _selectedSmoking;
  String? _selectedMaritalHistory;
  final TextEditingController _residenceAreaCtrl = TextEditingController();

  static const _drinkingOptions = ['none', 'social', 'regular'];
  static const _smokingOptions = ['none', 'sometimes', 'regular'];
  static const _maritalOptions = ['first_marriage', 'remarriage', 'divorced'];

  static const _religions = [
    '무교',
    '기독교',
    '천주교',
    '불교',
    '원불교',
    '기타',
  ];

  static const _educationLevels = [
    '고졸',
    '전문대',
    '대졸',
    '석사',
    '박사',
  ];

  static const _occupationCategories = [
    'IT',
    '의료',
    '법조',
    '금융',
    '교육',
    '공무원',
    '기타',
  ];

  static const _incomeRanges = [
    '3천만 미만',
    '3천만~5천만',
    '5천만~7천만',
    '7천만~1억',
    '1억 이상',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromFilter(ref.read(marketplaceFilterNotifierProvider));
  }

  void _loadFromFilter(MarketplaceFilter filter) {
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
    _selectedEducation = filter.educationLevel;
    _selectedOccupations = List<String>.from(filter.occupationCategories);
    _selectedIncome = filter.incomeRange;
    _sortOrder = filter.sortOrder;
    _selectedDrinking = filter.drinking;
    _selectedSmoking = filter.smoking;
    _selectedMaritalHistory = filter.maritalHistory;
    _residenceAreaCtrl.text = filter.residenceArea ?? '';
  }

  @override
  void dispose() {
    _residenceAreaCtrl.dispose();
    super.dispose();
  }

  MarketplaceFilter _buildFilter() {
    final hasAgeFilter = _ageRange.start > 20 || _ageRange.end < 45;
    final hasHeightFilter =
        _heightRange.start > 150 || _heightRange.end < 195;
    return MarketplaceFilter(
      minAge: hasAgeFilter ? _ageRange.start.round() : null,
      maxAge: hasAgeFilter ? _ageRange.end.round() : null,
      minHeight: hasHeightFilter ? _heightRange.start.round() : null,
      maxHeight: hasHeightFilter ? _heightRange.end.round() : null,
      religion: _selectedReligion,
      isVerifiedOnly: _verifiedOnly,
      educationLevel: _selectedEducation,
      occupationCategories: _selectedOccupations,
      incomeRange: _selectedIncome,
      sortOrder: _sortOrder,
      drinking: _selectedDrinking,
      smoking: _selectedSmoking,
      maritalHistory: _selectedMaritalHistory,
      residenceArea: _residenceAreaCtrl.text.trim().isEmpty
          ? null
          : _residenceAreaCtrl.text.trim(),
    );
  }

  int get _activeCount {
    int count = 0;
    if (_ageRange.start > 20 || _ageRange.end < 45) count++;
    if (_heightRange.start > 150 || _heightRange.end < 195) count++;
    if (_selectedReligion != null) count++;
    if (_selectedEducation != null) count++;
    if (_selectedOccupations.isNotEmpty) count++;
    if (_selectedIncome != null) count++;
    if (_selectedDrinking != null) count++;
    if (_selectedSmoking != null) count++;
    if (_selectedMaritalHistory != null) count++;
    if (_residenceAreaCtrl.text.trim().isNotEmpty) count++;
    if (_verifiedOnly) count++;
    return count;
  }

  void _apply() {
    final filter = _buildFilter();
    ref.read(marketplaceFilterNotifierProvider.notifier).applyFilter(filter);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _ageRange = const RangeValues(20, 45);
      _heightRange = const RangeValues(150, 195);
      _selectedReligion = null;
      _verifiedOnly = false;
      _selectedEducation = null;
      _selectedOccupations = [];
      _selectedIncome = null;
      _sortOrder = SortOrder.newest;
      _selectedDrinking = null;
      _selectedSmoking = null;
      _selectedMaritalHistory = null;
      _residenceAreaCtrl.clear();
    });
  }

  void _applyPreset(FilterPreset preset) {
    setState(() => _loadFromFilter(preset.filter));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.filterPresetApplied),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSaveDialog() {
    if (_activeCount == 0) return;
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.filterPresetSaveTitle),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.filterPresetNameHint,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            _doSavePreset(nameCtrl.text.trim(), ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => _doSavePreset(nameCtrl.text.trim(), ctx),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  void _doSavePreset(String name, BuildContext dialogCtx) {
    if (name.isEmpty) return;
    final filter = _buildFilter();
    ref.read(filterPresetNotifierProvider.notifier).savePreset(name, filter);
    Navigator.pop(dialogCtx);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.filterPresetSaved),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deletePreset(FilterPreset preset) {
    final l10n = AppLocalizations.of(context)!;
    ref.read(filterPresetNotifierProvider.notifier).deletePreset(preset.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.filterPresetDeleted),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final presets = ref.watch(filterPresetNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // ── Drag handle ──
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Header ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded, size: 24.r),
                ),
                SizedBox(width: 12.w),
                Text(
                  l10n.marketplaceFilterTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Save preset button
                if (_activeCount > 0) ...[
                  if (presets.length >= maxPresets)
                    Icon(
                      Icons.bookmark_added_rounded,
                      size: 22.r,
                      color: theme.colorScheme.outlineVariant,
                    )
                  else
                    IconButton(
                      onPressed: _showSaveDialog,
                      icon: Icon(Icons.bookmark_add_outlined, size: 22.r),
                      tooltip: l10n.filterPresetSave,
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ],
            ),
          ),

          SizedBox(height: 8.h),
          Divider(
              height: 1,
              color:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),

          // ── Scrollable content ──
          Expanded(
            child: ListView(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: [
                // ── Saved presets ──
                if (presets.isNotEmpty) ...[
                  _SectionTitle(title: l10n.filterPresetTitle),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 40.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: presets.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final preset = presets[index];
                        return _PresetChip(
                          preset: preset,
                          onTap: () => _applyPreset(preset),
                          onDelete: () => _deletePreset(preset),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Sort order
                _SectionTitle(title: l10n.marketplaceSortNewest),
                SizedBox(height: 8.h),
                SegmentedButton<SortOrder>(
                  segments: [
                    ButtonSegment(
                      value: SortOrder.newest,
                      label: Text(l10n.marketplaceSortNewest),
                    ),
                    ButtonSegment(
                      value: SortOrder.mostLikes,
                      label: Text(l10n.marketplaceSortMostLikes),
                    ),
                    ButtonSegment(
                      value: SortOrder.recommended,
                      label: Text(l10n.marketplaceSortRecommended),
                    ),
                  ],
                  selected: {_sortOrder},
                  onSelectionChanged: (value) {
                    setState(() => _sortOrder = value.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(fontSize: 11.sp),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Age range
                _SectionTitle(
                  title: l10n.marketplaceFilterAge(
                    _ageRange.start.round(),
                    _ageRange.end.round(),
                  ),
                ),
                SliderTheme(
                  data: _sliderTheme(theme),
                  child: RangeSlider(
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
                ),

                SizedBox(height: 16.h),

                // Height range
                _SectionTitle(
                  title: l10n.marketplaceFilterHeight(
                    _heightRange.start.round(),
                    _heightRange.end.round(),
                  ),
                ),
                SliderTheme(
                  data: _sliderTheme(theme),
                  child: RangeSlider(
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
                ),

                SizedBox(height: 24.h),

                // Religion
                _buildChipSection(
                  title: l10n.profileReligion,
                  children: _religions.map((religion) {
                    return _FilterChip(
                      label: religion,
                      selected: _selectedReligion == religion,
                      onSelected: (v) => setState(() {
                        _selectedReligion = v ? religion : null;
                      }),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // Education level
                _buildChipSection(
                  title: l10n.marketplaceFilterEducation,
                  children: _educationLevels.map((level) {
                    return _FilterChip(
                      label: level,
                      selected: _selectedEducation == level,
                      onSelected: (v) => setState(() {
                        _selectedEducation = v ? level : null;
                      }),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // Occupation categories (multi-select)
                _buildChipSection(
                  title: l10n.marketplaceFilterOccupation,
                  children: _occupationCategories.map((cat) {
                    final selected = _selectedOccupations.contains(cat);
                    return _FilterChip(
                      label: cat,
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _selectedOccupations.add(cat);
                        } else {
                          _selectedOccupations.remove(cat);
                        }
                      }),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // Income range
                _buildChipSection(
                  title: l10n.marketplaceFilterIncome,
                  children: _incomeRanges.map((range) {
                    return _FilterChip(
                      label: range,
                      selected: _selectedIncome == range,
                      onSelected: (v) => setState(() {
                        _selectedIncome = v ? range : null;
                      }),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // Drinking
                _buildChipSection(
                  title: l10n.marketplaceFilterDrinking,
                  children: _drinkingOptions.map((option) {
                    return _FilterChip(
                      label: drinkingLabel(option, l10n),
                      selected: _selectedDrinking == option,
                      onSelected: (v) => setState(() {
                        _selectedDrinking = v ? option : null;
                      }),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // Smoking
                _buildChipSection(
                  title: l10n.marketplaceFilterSmoking,
                  children: _smokingOptions.map((option) {
                    return _FilterChip(
                      label: smokingLabel(option, l10n),
                      selected: _selectedSmoking == option,
                      onSelected: (v) => setState(() {
                        _selectedSmoking = v ? option : null;
                      }),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // Marital History
                _buildChipSection(
                  title: l10n.marketplaceFilterMaritalHistory,
                  children: _maritalOptions.map((option) {
                    return _FilterChip(
                      label: maritalLabel(option, l10n),
                      selected: _selectedMaritalHistory == option,
                      onSelected: (v) => setState(() {
                        _selectedMaritalHistory = v ? option : null;
                      }),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // Residence Area
                _SectionTitle(title: l10n.marketplaceFilterResidenceArea),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _residenceAreaCtrl,
                  decoration: InputDecoration(
                    hintText: l10n.marketplaceFilterResidenceHint,
                    prefixIcon:
                        Icon(Icons.location_on_outlined, size: 20.r),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                  ),
                ),

                SizedBox(height: 20.h),

                // Verified toggle
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
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

                SizedBox(height: 16.h),
              ],
            ),
          ),

          // ── Sticky bottom bar ──
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.4),
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                20.w, 12.h, 20.w, bottomPadding + 12.h),
            child: Row(
              children: [
                // Reset button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(l10n.marketplaceFilterClear),
                  ),
                ),
                SizedBox(width: 12.w),
                // Apply button
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      _activeCount > 0
                          ? '${l10n.marketplaceFilterApply} ($_activeCount)'
                          : l10n.marketplaceFilterApply,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliderThemeData _sliderTheme(ThemeData theme) {
    return SliderThemeData(
      activeTrackColor: theme.colorScheme.primary,
      inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
      thumbColor: theme.colorScheme.primary,
      overlayColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      trackHeight: 3.h,
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: children,
        ),
      ],
    );
  }
}

// ── Preset chip widget ──────────────────────────────────────────

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.onTap,
    required this.onDelete,
  });

  final FilterPreset preset;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final filterCount = preset.filter.activeFilterCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.filterPresetDeleteConfirm),
              content: Text(preset.name),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.commonCancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onDelete();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(l10n.commonDelete),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_rounded,
                size: 14.r,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                preset.name,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  l10n.filterPresetFilterCount(filterCount),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ──────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
