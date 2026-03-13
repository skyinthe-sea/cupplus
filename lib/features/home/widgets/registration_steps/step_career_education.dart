import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';

class StepCareerEducation extends ConsumerStatefulWidget {
  const StepCareerEducation({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<StepCareerEducation> createState() =>
      _StepCareerEducationState();
}

class _StepCareerEducationState extends ConsumerState<StepCareerEducation> {
  late final TextEditingController _occupationController;
  late final TextEditingController _companyController;
  late final TextEditingController _schoolController;
  late final TextEditingController _majorController;

  String? _selectedEducation;
  String? _selectedIncome;
  bool _occupationError = false;

  // Stagger visibility
  final List<bool> _visible = List.filled(6, false);

  static const _educationValues = [
    'high_school',
    'associate',
    'bachelor',
    'master',
    'doctorate',
  ];

  static const _incomeValues = [
    'under_30m',
    '30m_50m',
    '50m_70m',
    '70m_100m',
    '100m_150m',
    'over_150m',
  ];

  // Bounce state per education chip
  final List<bool> _eduBounce = List.filled(5, false);

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _occupationController =
        TextEditingController(text: d['occupation'] as String? ?? '');
    _companyController =
        TextEditingController(text: d['company'] as String? ?? '');
    _schoolController =
        TextEditingController(text: d['school'] as String? ?? '');
    _majorController =
        TextEditingController(text: d['major'] as String? ?? '');
    _selectedEducation = d['education_level'] as String?;
    _selectedIncome = d['annual_income_range'] as String?;

    _occupationController.addListener(_notifyParent);
    _companyController.addListener(_notifyParent);
    _schoolController.addListener(_notifyParent);
    _majorController.addListener(_notifyParent);

    for (int i = 0; i < _visible.length; i++) {
      Future.delayed(Duration(milliseconds: 60 + i * 90), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  @override
  void dispose() {
    _occupationController.dispose();
    _companyController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onDataChanged({
      'occupation': _occupationController.text,
      'company': _companyController.text,
      'education_level': _selectedEducation,
      'school': _schoolController.text,
      'major': _majorController.text,
      'annual_income_range': _selectedIncome,
    });
  }

  void _selectEducation(int index) {
    final val = _educationValues[index];
    setState(() {
      _selectedEducation = _selectedEducation == val ? null : val;
      _eduBounce[index] = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _eduBounce[index] = false);
    });
    _notifyParent();
  }

  void _selectIncome(String val) {
    setState(() {
      _selectedIncome = val;
    });
    _notifyParent();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;

    final eduLabels = [
      l10n.regEduHighSchool,
      l10n.regEduAssociate,
      l10n.regEduBachelor,
      l10n.regEduMaster,
      l10n.regEduDoctorate,
    ];

    final incomeLabels = [
      l10n.regIncome1,
      l10n.regIncome2,
      l10n.regIncome3,
      l10n.regIncome4,
      l10n.regIncome5,
      l10n.regIncome6,
    ];

    InputDecoration fieldDeco(String hint, {Widget? prefix}) => InputDecoration(
          hintText: hint,
          prefixIcon: prefix,
          filled: true,
          fillColor: surfaceVariant.withValues(alpha: 0.5),
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Occupation
          _stagger(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regOccupationLabel, required: true),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _occupationController,
                  textInputAction: TextInputAction.next,
                  decoration: fieldDeco(
                    l10n.regOccupationHint,
                    prefix: Icon(
                      Icons.work_outline_rounded,
                      size: 20.r,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ).copyWith(
                    errorText:
                        _occupationError ? l10n.regOccupationRequired : null,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (v) {
                    setState(() => _occupationError = v.trim().isEmpty);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Company
          _stagger(
            1,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regCompanyLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _companyController,
                  textInputAction: TextInputAction.next,
                  decoration: fieldDeco(
                    l10n.regCompanyHint,
                    prefix: Icon(
                      Icons.business_outlined,
                      size: 20.r,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Education level chips
          _stagger(
            2,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regEducationLevel, required: false),
                SizedBox(height: 8.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(eduLabels.length, (i) {
                      final val = _educationValues[i];
                      final isSelected = _selectedEducation == val;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _BounceChip(
                          label: eduLabels[i],
                          isSelected: isSelected,
                          bounce: _eduBounce[i],
                          onTap: () => _selectEducation(i),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // School
          _stagger(
            3,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regSchoolLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _schoolController,
                  textInputAction: TextInputAction.next,
                  decoration: fieldDeco(
                    l10n.regSchoolHint,
                    prefix: Icon(
                      Icons.school_outlined,
                      size: 20.r,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Major
          _stagger(
            4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regMajorLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _majorController,
                  textInputAction: TextInputAction.done,
                  decoration: fieldDeco(l10n.regMajorHint),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Income range
          _stagger(
            5,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regIncomeLabel, required: false),
                SizedBox(height: 8.h),
                ...List.generate(incomeLabels.length, (i) {
                  final val = _incomeValues[i];
                  final isSelected = _selectedIncome == val;
                  return _IncomeRadioTile(
                    label: incomeLabels[i],
                    isSelected: isSelected,
                    onTap: () => _selectIncome(val),
                  );
                }),
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
            style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _BounceChip extends StatefulWidget {
  const _BounceChip({
    required this.label,
    required this.isSelected,
    required this.bounce,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final bool bounce;
  final VoidCallback onTap;

  @override
  State<_BounceChip> createState() => _BounceChipState();
}

class _BounceChipState extends State<_BounceChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_BounceChip old) {
    super.didUpdateWidget(old);
    if (widget.bounce && !old.bounce) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: widget.isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: widget.isSelected
                  ? primary
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: widget.isSelected
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: widget.isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomeRadioTile extends StatelessWidget {
  const _IncomeRadioTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? primary.withValues(alpha: 0.4)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primary : theme.colorScheme.outline,
                  width: isSelected ? 5 : 1.5,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primary : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
