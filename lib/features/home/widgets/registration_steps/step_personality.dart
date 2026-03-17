import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';

class StepPersonality extends ConsumerStatefulWidget {
  const StepPersonality({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<StepPersonality> createState() => _StepPersonalityState();
}

class _StepPersonalityState extends ConsumerState<StepPersonality> {
  String? _selectedReligion;
  List<String> _selectedHobbies = [];
  late final TextEditingController _bioController;
  late final TextEditingController _customHobbyController;
  bool _showCustomInput = false;
  final List<bool> _visible = List.filled(4, false);
  final List<bool> _religionBounce = List.filled(5, false);
  final List<bool> _hobbyBounce = [];

  static const _religions = [
    'none',
    'christian',
    'catholic',
    'buddhist',
    'other',
  ];

  static const _defaultHobbies = [
    '여행', '등산', '요가', '운동', '독서',
    '요리', '카페', '영화', '음악', '게임',
    '사진', '그림', '맛집탐방', '캠핑', '낚시',
    '필라테스', '미술관', '볼링', '코딩', '와인',
  ];

  List<String> _allHobbies = [];

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _selectedReligion = d['religion'] as String?;
    _selectedHobbies =
        List<String>.from((d['hobbies'] as List<String>?) ?? []);
    _bioController =
        TextEditingController(text: d['bio'] as String? ?? '');
    _customHobbyController = TextEditingController();

    // Build hobby list: defaults + any custom ones already selected
    _allHobbies = List<String>.from(_defaultHobbies);
    for (final h in _selectedHobbies) {
      if (!_allHobbies.contains(h)) {
        _allHobbies.add(h);
      }
    }
    _hobbyBounce.addAll(List.filled(_allHobbies.length, false));

    _bioController.addListener(_notifyParent);

    for (int i = 0; i < _visible.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 100), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _customHobbyController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onDataChanged({
      'religion': _selectedReligion,
      'hobbies': List<String>.from(_selectedHobbies),
      'bio': _bioController.text,
    });
  }

  void _selectReligion(int index) {
    final val = _religions[index];
    setState(() {
      _selectedReligion = _selectedReligion == val ? null : val;
      _religionBounce[index] = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _religionBounce[index] = false);
    });
    _notifyParent();
  }

  void _toggleHobby(int index) {
    final hobby = _allHobbies[index];
    if (_selectedHobbies.contains(hobby)) {
      setState(() {
        _selectedHobbies.remove(hobby);
        if (index < _hobbyBounce.length) _hobbyBounce[index] = true;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && index < _hobbyBounce.length) {
          setState(() => _hobbyBounce[index] = false);
        }
      });
      _notifyParent();
    } else {
      if (_selectedHobbies.length >= 5) {
        HapticFeedback.heavyImpact();
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.regHobbiesMax),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
      setState(() {
        _selectedHobbies.add(hobby);
        if (index < _hobbyBounce.length) _hobbyBounce[index] = true;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && index < _hobbyBounce.length) {
          setState(() => _hobbyBounce[index] = false);
        }
      });
      HapticFeedback.lightImpact();
      _notifyParent();
    }
  }

  void _addCustomHobby() {
    final text = _customHobbyController.text.trim();
    if (text.isEmpty) return;
    if (text.length > 10) return;
    if (_allHobbies.contains(text)) {
      // Already in list — just select it
      if (!_selectedHobbies.contains(text)) {
        _toggleHobby(_allHobbies.indexOf(text));
      }
      _customHobbyController.clear();
      return;
    }
    if (_selectedHobbies.length >= 5) {
      HapticFeedback.heavyImpact();
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.regHobbiesMax)),
      );
      return;
    }
    setState(() {
      _allHobbies.add(text);
      _hobbyBounce.add(false);
      _selectedHobbies.add(text);
    });
    _customHobbyController.clear();
    _notifyParent();
  }

  void _removeHobby(String hobby) {
    setState(() => _selectedHobbies.remove(hobby));
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

    final religionLabels = [
      l10n.regReligionNone,
      l10n.regReligionChristian,
      l10n.regReligionCatholic,
      l10n.regReligionBuddhist,
      l10n.regReligionOther,
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Religion
          _stagger(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regReligionLabel, required: true),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(religionLabels.length, (i) {
                    final val = _religions[i];
                    final isSelected = _selectedReligion == val;
                    return _BounceChip(
                      label: religionLabels[i],
                      isSelected: isSelected,
                      bounce: _religionBounce[i],
                      onTap: () => _selectReligion(i),
                    );
                  }),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Hobbies
          _stagger(
            1,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FieldLabel(label: l10n.regHobbiesLabel, required: false),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        l10n.regHobbiesCount(
                          _selectedHobbies.length,
                        ),
                        key: ValueKey(_selectedHobbies.length),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _selectedHobbies.length >= 5
                              ? primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(_allHobbies.length, (i) {
                    final hobby = _allHobbies[i];
                    final isSelected = _selectedHobbies.contains(hobby);
                    return _BounceChip(
                      label: hobby,
                      isSelected: isSelected,
                      bounce: i < _hobbyBounce.length
                          ? _hobbyBounce[i]
                          : false,
                      onTap: () => _toggleHobby(i),
                    );
                  }),
                ),
                SizedBox(height: 12.h),
                // Custom hobby input toggle
                GestureDetector(
                  onTap: () {
                    setState(() => _showCustomInput = !_showCustomInput);
                  },
                  child: Row(
                    children: [
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _showCustomInput ? 0.125 : 0,
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 18.r,
                          color: primary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        l10n.regHobbiesCustom,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showCustomInput)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _customHobbyController,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              hintText: '취미를 입력하세요',
                              filled: true,
                              fillColor: surfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                  color: primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                            ),
                            onFieldSubmitted: (_) => _addCustomHobby(),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        SizedBox(
                          height: 48.h,
                          child: FilledButton(
                            onPressed: _addCustomHobby,
                            style: FilledButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                              ),
                            ),
                            child: Text(
                              l10n.regHobbiesAdd,
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedHobbies.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: _selectedHobbies
                        .map(
                          (h) => _SelectedHobbyTag(
                            label: h,
                            onRemove: () => _removeHobby(h),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Bio
          _stagger(
            2,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regBioLabel, required: false),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 300,
                  buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        l10n.regBioCount(currentLength),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: currentLength >= 300
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: l10n.regBioHint,
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
                  ),
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
      duration: const Duration(milliseconds: 150),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
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
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
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
              fontWeight:
                  widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              color: widget.isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedHobbyTag extends StatefulWidget {
  const _SelectedHobbyTag({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  State<_SelectedHobbyTag> createState() => _SelectedHobbyTagState();
}

class _SelectedHobbyTagState extends State<_SelectedHobbyTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ctrl.forward();
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13.sp,
                color: primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: widget.onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14.r,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
