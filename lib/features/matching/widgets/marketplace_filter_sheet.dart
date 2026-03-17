import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../models/marketplace_filter.dart';
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

  void _apply() {
    final notifier = ref.read(marketplaceFilterNotifierProvider.notifier);
    final hasAgeFilter = _ageRange.start > 20 || _ageRange.end < 45;
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
    notifier.updateEducationLevel(_selectedEducation);
    notifier.updateOccupationCategories(_selectedOccupations);
    notifier.updateIncomeRange(_selectedIncome);
    notifier.updateSortOrder(_sortOrder);
    notifier.updateDrinking(_selectedDrinking);
    notifier.updateSmoking(_selectedSmoking);
    notifier.updateMaritalHistory(_selectedMaritalHistory);
    notifier.updateResidenceArea(_residenceAreaCtrl.text.trim().isEmpty ? null : _residenceAreaCtrl.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
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

            // Sort order toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Text(
                    l10n.marketplaceSortNewest,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
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

            // Education level
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketplaceFilterEducation,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _educationLevels.map((level) {
                      final selected = _selectedEducation == level;
                      return ChoiceChip(
                        label: Text(level),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            _selectedEducation = value ? level : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Occupation categories (multi-select)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketplaceFilterOccupation,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _occupationCategories.map((cat) {
                      final selected = _selectedOccupations.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedOccupations.add(cat);
                            } else {
                              _selectedOccupations.remove(cat);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Income range
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketplaceFilterIncome,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _incomeRanges.map((range) {
                      final selected = _selectedIncome == range;
                      return ChoiceChip(
                        label: Text(range),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            _selectedIncome = value ? range : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Drinking
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketplaceFilterDrinking,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _drinkingOptions.map((option) {
                      final selected = _selectedDrinking == option;
                      return ChoiceChip(
                        label: Text(_drinkingLabel(option, l10n)),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            _selectedDrinking = value ? option : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Smoking
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketplaceFilterSmoking,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _smokingOptions.map((option) {
                      final selected = _selectedSmoking == option;
                      return ChoiceChip(
                        label: Text(_smokingLabel(option, l10n)),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            _selectedSmoking = value ? option : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Marital History
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketplaceFilterMaritalHistory,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _maritalOptions.map((option) {
                      final selected = _selectedMaritalHistory == option;
                      return ChoiceChip(
                        label: Text(_maritalLabel(option, l10n)),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            _selectedMaritalHistory = value ? option : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Residence Area
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketplaceFilterResidenceArea,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _residenceAreaCtrl,
                    decoration: InputDecoration(
                      hintText: l10n.marketplaceFilterResidenceHint,
                    ),
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
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  child: Text(l10n.marketplaceFilterApply),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  String _drinkingLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'none' => l10n.regDrinkingNone,
      'social' => l10n.regDrinkingSocial,
      'regular' => l10n.regDrinkingRegular,
      _ => val,
    };
  }

  String _smokingLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'none' => l10n.regSmokingNone,
      'sometimes' => l10n.regSmokingSometimes,
      'regular' => l10n.regSmokingRegular,
      _ => val,
    };
  }

  String _maritalLabel(String val, AppLocalizations l10n) {
    return switch (val) {
      'first_marriage' => l10n.regMaritalFirst,
      'remarriage' => l10n.regMaritalRemarriage,
      'divorced' => l10n.regMaritalDivorced,
      _ => val,
    };
  }
}
