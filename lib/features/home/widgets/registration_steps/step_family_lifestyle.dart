import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';

class StepFamilyLifestyle extends ConsumerStatefulWidget {
  const StepFamilyLifestyle({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<StepFamilyLifestyle> createState() =>
      _StepFamilyLifestyleState();
}

class _StepFamilyLifestyleState extends ConsumerState<StepFamilyLifestyle> {
  String? _maritalHistory;
  bool _hasChildren = false;
  int _childrenCount = 0;
  late final TextEditingController _familyDetailController;
  String? _parentsStatus;
  String? _drinking;
  String? _smoking;
  String? _assetRange;
  late final TextEditingController _residenceAreaController;
  String? _residenceType;
  late final TextEditingController _healthNotesController;

  // Stagger animation — 11 fields
  final List<bool> _visible = List.filled(11, false);

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _maritalHistory = d['marital_history'] as String?;
    _hasChildren = (d['has_children'] as bool?) ?? false;
    _childrenCount = (d['children_count'] as int?) ?? 0;
    _familyDetailController =
        TextEditingController(text: d['family_detail'] as String? ?? '');
    _parentsStatus = d['parents_status'] as String?;
    _drinking = d['drinking'] as String?;
    _smoking = d['smoking'] as String?;
    _assetRange = d['asset_range'] as String?;
    _residenceAreaController =
        TextEditingController(text: d['residence_area'] as String? ?? '');
    _residenceType = d['residence_type'] as String?;
    _healthNotesController =
        TextEditingController(text: d['health_notes'] as String? ?? '');

    _familyDetailController.addListener(_notifyParent);
    _residenceAreaController.addListener(_notifyParent);
    _healthNotesController.addListener(_notifyParent);

    // Staggered fade-in
    for (int i = 0; i < _visible.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 100), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  @override
  void dispose() {
    _familyDetailController.dispose();
    _residenceAreaController.dispose();
    _healthNotesController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onDataChanged({
      'marital_history': _maritalHistory,
      'has_children': _hasChildren,
      'children_count': _hasChildren ? _childrenCount : 0,
      'family_detail': _familyDetailController.text,
      'parents_status': _parentsStatus,
      'drinking': _drinking,
      'smoking': _smoking,
      'asset_range': _assetRange,
      'residence_area': _residenceAreaController.text,
      'residence_type': _residenceType,
      'health_notes': _healthNotesController.text,
    });
  }

  Widget _stagger(int i, Widget child) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: _visible[i] ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 280),
        offset: _visible[i] ? Offset.zero : const Offset(0, 0.04),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }

  Widget _buildChoiceChips({
    required List<String> values,
    required List<String> labels,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: List.generate(values.length, (i) {
        final isSelected = selected == values[i];
        return ChoiceChip(
          label: Text(labels[i]),
          selected: isSelected,
          onSelected: (_) {
            onSelected(isSelected ? null : values[i]);
            HapticFeedback.lightImpact();
          },
          selectedColor: primary,
          backgroundColor: Colors.transparent,
          side: BorderSide(
            color: isSelected
                ? primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1.5,
          ),
          labelStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          showCheckmark: false,
        );
      }),
    );
  }

  InputDecoration _textFieldDecoration({
    required String hintText,
    Color? fillColor,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;

    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: fillColor ?? surfaceVariant.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0 — Marital History
          _stagger(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regMaritalHistoryLabel, required: true),
                SizedBox(height: 8.h),
                _buildChoiceChips(
                  values: const [
                    'first_marriage',
                    'remarriage',
                    'divorced',
                  ],
                  labels: [
                    l10n.regMaritalFirst,
                    l10n.regMaritalRemarriage,
                    l10n.regMaritalDivorced,
                  ],
                  selected: _maritalHistory,
                  onSelected: (v) {
                    setState(() => _maritalHistory = v);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 1 — Has Children (Switch)
          _stagger(
            1,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FieldLabel(label: l10n.regHasChildrenLabel, required: false),
                Switch.adaptive(
                  value: _hasChildren,
                  activeTrackColor: primary.withValues(alpha: 0.5),
                  activeThumbColor: primary,
                  onChanged: (v) {
                    setState(() {
                      _hasChildren = v;
                      if (!v) _childrenCount = 0;
                    });
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          // 2 — Children Count (conditional)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _hasChildren
                ? _stagger(
                    2,
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(
                            label: l10n.regChildrenCountLabel,
                            required: false,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              _StepperButton(
                                icon: Icons.remove,
                                onTap: _childrenCount > 0
                                    ? () {
                                        setState(() => _childrenCount--);
                                        _notifyParent();
                                      }
                                    : null,
                              ),
                              SizedBox(width: 16.w),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                child: Text(
                                  '$_childrenCount',
                                  key: ValueKey(_childrenCount),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              _StepperButton(
                                icon: Icons.add,
                                onTap: _childrenCount < 10
                                    ? () {
                                        setState(() => _childrenCount++);
                                        _notifyParent();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: 20.h),

          // 3 — Family Detail
          _stagger(
            3,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regFamilyDetailLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _familyDetailController,
                  maxLines: 3,
                  minLines: 2,
                  decoration:
                      _textFieldDecoration(hintText: l10n.regFamilyDetailHint),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 4 — Parents Status
          _stagger(
            4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regParentsStatusLabel, required: false),
                SizedBox(height: 8.h),
                _buildChoiceChips(
                  values: const [
                    'both_alive',
                    'father_only',
                    'mother_only',
                    'deceased',
                  ],
                  labels: [
                    l10n.regParentsBothAlive,
                    l10n.regParentsFatherOnly,
                    l10n.regParentsMotherOnly,
                    l10n.regParentsDeceased,
                  ],
                  selected: _parentsStatus,
                  onSelected: (v) {
                    setState(() => _parentsStatus = v);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 5 — Drinking
          _stagger(
            5,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regDrinkingLabel, required: false),
                SizedBox(height: 8.h),
                _buildChoiceChips(
                  values: const ['none', 'social', 'regular'],
                  labels: [
                    l10n.regDrinkingNone,
                    l10n.regDrinkingSocial,
                    l10n.regDrinkingRegular,
                  ],
                  selected: _drinking,
                  onSelected: (v) {
                    setState(() => _drinking = v);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 6 — Smoking
          _stagger(
            6,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regSmokingLabel, required: false),
                SizedBox(height: 8.h),
                _buildChoiceChips(
                  values: const ['none', 'sometimes', 'regular'],
                  labels: [
                    l10n.regSmokingNone,
                    l10n.regSmokingSometimes,
                    l10n.regSmokingRegular,
                  ],
                  selected: _smoking,
                  onSelected: (v) {
                    setState(() => _smoking = v);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 7 — Asset Range
          _stagger(
            7,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regAssetRangeLabel, required: false),
                SizedBox(height: 8.h),
                _buildChoiceChips(
                  values: const [
                    'under_100m',
                    '100m_300m',
                    '300m_500m',
                    '500m_1b',
                    'over_1b',
                  ],
                  labels: [
                    l10n.regAssetRange1,
                    l10n.regAssetRange2,
                    l10n.regAssetRange3,
                    l10n.regAssetRange4,
                    l10n.regAssetRange5,
                  ],
                  selected: _assetRange,
                  onSelected: (v) {
                    setState(() => _assetRange = v);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 8 — Residence Area
          _stagger(
            8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regResidenceAreaLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _residenceAreaController,
                  textInputAction: TextInputAction.next,
                  decoration: _textFieldDecoration(
                    hintText: l10n.regResidenceAreaHint,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 9 — Residence Type
          _stagger(
            9,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regResidenceTypeLabel, required: false),
                SizedBox(height: 8.h),
                _buildChoiceChips(
                  values: const [
                    'own',
                    'rent_deposit',
                    'rent_monthly',
                    'with_parents',
                  ],
                  labels: [
                    l10n.regResidenceOwn,
                    l10n.regResidenceRentDeposit,
                    l10n.regResidenceRentMonthly,
                    l10n.regResidenceWithParents,
                  ],
                  selected: _residenceType,
                  onSelected: (v) {
                    setState(() => _residenceType = v);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 10 — Health Notes
          _stagger(
            10,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regHealthNotesLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _healthNotesController,
                  maxLines: 3,
                  minLines: 2,
                  decoration:
                      _textFieldDecoration(hintText: l10n.regHealthNotesHint),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (required) ...[
          SizedBox(width: 4.w),
          Text(
            '*',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: isEnabled
              ? primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isEnabled
                ? primary.withValues(alpha: 0.4)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18.r,
          color: isEnabled
              ? primary
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
