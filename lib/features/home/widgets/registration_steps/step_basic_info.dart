import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';

class StepBasicInfo extends ConsumerStatefulWidget {
  const StepBasicInfo({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends ConsumerState<StepBasicInfo>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final FocusNode _nameFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _emailFocus;

  String _selectedGender = 'F';
  DateTime? _selectedBirthDate;
  bool _nameError = false;
  bool _emailError = false;

  // Stagger animation
  final List<bool> _visible = List.filled(5, false);
  bool _genderBounce = false;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _selectedGender = (d['gender'] as String?) ?? 'F';
    if (d['birth_date'] != null) {
      try {
        _selectedBirthDate = DateTime.parse(d['birth_date'] as String);
      } catch (_) {}
    }
    _nameController = TextEditingController(text: d['full_name'] as String? ?? '');
    _phoneController = TextEditingController(text: d['phone'] as String? ?? '');
    _emailController = TextEditingController(text: d['email'] as String? ?? '');
    _nameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _emailFocus = FocusNode();

    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);

    // Staggered fade-in
    for (int i = 0; i < _visible.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 100), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    widget.onDataChanged({
      'full_name': _nameController.text,
      'gender': _selectedGender,
      'birth_date': _selectedBirthDate?.toIso8601String().substring(0, 10),
      'phone': _phoneController.text,
      'email': _emailController.text,
    });
  }

  void _selectGender(String gender) {
    if (_selectedGender == gender) return;
    setState(() {
      _selectedGender = gender;
      _genderBounce = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _genderBounce = false);
    });
    _onFieldChanged();
  }

  void _showDatePicker() {
    final theme = Theme.of(context);
    final initial = _selectedBirthDate ?? DateTime(1995, 1, 1);
    final minDate = DateTime(1966, 1, 1);
    final maxDate = DateTime(2007, 12, 31);
    DateTime temp = initial;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => SizedBox(
        height: 320.h,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    child: Text(
                      AppLocalizations.of(sheetCtx)!.commonCancel,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedBirthDate = temp);
                      _onFieldChanged();
                      Navigator.pop(sheetCtx);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.commonConfirm,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: theme.brightness,
                  primaryColor: theme.colorScheme.primary,
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  onDateTimeChanged: (dt) => temp = dt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBirthDate(DateTime dt) {
    return '${dt.year}년 ${dt.month.toString().padLeft(2, '0')}월 ${dt.day.toString().padLeft(2, '0')}일';
  }

  String _formatPhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 3)}-${digits.substring(3)}';
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, digits.length.clamp(0, 11))}';
  }

  Widget _buildFadeField(int index, Widget child) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _visible[index] ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _visible[index] ? Offset.zero : const Offset(0, 0.05),
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          _buildFadeField(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regNameLabel, required: true),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  decoration: InputDecoration(
                    hintText: l10n.regNameHint,
                    errorText: _nameError ? l10n.regNameValidation : null,
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _nameError = v.isNotEmpty && v.trim().length < 2;
                    });
                    _onFieldChanged();
                  },
                  onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Gender toggle
          _buildFadeField(
            1,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.profileGender, required: true),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _GenderButton(
                        label: l10n.commonFemale,
                        icon: Icons.female_rounded,
                        isSelected: _selectedGender == 'F',
                        bounce: _genderBounce && _selectedGender == 'F',
                        onTap: () => _selectGender('F'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _GenderButton(
                        label: l10n.commonMale,
                        icon: Icons.male_rounded,
                        isSelected: _selectedGender == 'M',
                        bounce: _genderBounce && _selectedGender == 'M',
                        onTap: () => _selectGender('M'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Birth date picker
          _buildFadeField(
            2,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.profileBirthDate, required: true),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: _showDatePicker,
                  borderRadius: BorderRadius.circular(12.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _selectedBirthDate != null
                            ? primary.withValues(alpha: 0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 20.r,
                          color: _selectedBirthDate != null
                              ? primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _selectedBirthDate != null
                              ? _formatBirthDate(_selectedBirthDate!)
                              : '년도를 선택하세요',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: _selectedBirthDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.expand_more_rounded,
                          size: 20.r,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Phone field
          _buildFadeField(
            3,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regPhoneLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    hintText: l10n.regPhoneHint,
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
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      size: 20.r,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onChanged: (v) {
                    final formatted = _formatPhone(v);
                    if (formatted != v) {
                      _phoneController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                    _onFieldChanged();
                  },
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Email field
          _buildFadeField(
            4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regEmailLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: l10n.regEmailHint,
                    errorText: _emailError ? l10n.regEmailValidation : null,
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      size: 20.r,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _emailError = v.isNotEmpty &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
                    });
                    _onFieldChanged();
                  },
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

class _GenderButton extends StatefulWidget {
  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.bounce,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool bounce;
  final VoidCallback onTap;

  @override
  State<_GenderButton> createState() => _GenderButtonState();
}

class _GenderButtonState extends State<_GenderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_GenderButton old) {
    super.didUpdateWidget(old);
    if (widget.bounce && !old.bounce) {
      _ctrl.forward(from: 0);
    }
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 52.h,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? primary
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.isSelected
                  ? primary
                  : theme.colorScheme.outline.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  key: ValueKey(widget.isSelected),
                  size: 20.r,
                  color: widget.isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 6.w),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
