import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../l10n/app_localizations.dart';

class StepAppearance extends ConsumerStatefulWidget {
  const StepAppearance({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<StepAppearance> createState() => _StepAppearanceState();
}

class _StepAppearanceState extends ConsumerState<StepAppearance> {
  int _selectedHeight = 170;
  String? _selectedBodyType;
  List<XFile> _photos = [];

  final _imagePicker = ImagePicker();
  final List<bool> _visible = List.filled(3, false);
  final List<bool> _bodyBounce = List.filled(5, false);

  // Photo animation: true means the photo slot is being shown
  final List<bool> _photoVisible = List.filled(5, false);

  static const _bodyTypeValues = [
    'slim',
    'slightly_slim',
    'average',
    'slightly_chubby',
    'chubby',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    final gender = d['gender'] as String? ?? 'F';
    _selectedHeight = (d['height_cm'] as int?) ?? (gender == 'M' ? 170 : 160);
    _selectedBodyType = d['body_type'] as String?;
    _photos = List<XFile>.from((d['photos'] as List<XFile>?) ?? []);

    for (int i = 0; i < _visible.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 100), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }

    for (int i = 0; i < _photos.length; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted && i < _photoVisible.length) {
          setState(() => _photoVisible[i] = true);
        }
      });
    }
  }

  void _notifyParent() {
    widget.onDataChanged({
      'height_cm': _selectedHeight,
      'body_type': _selectedBodyType,
      'photos': List<XFile>.from(_photos),
    });
  }

  void _selectBodyType(int index) {
    final val = _bodyTypeValues[index];
    setState(() {
      _selectedBodyType = _selectedBodyType == val ? null : val;
      _bodyBounce[index] = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _bodyBounce[index] = false);
    });
    _notifyParent();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= 5) {
      _showMaxPhotosSnackbar();
      return;
    }
    try {
      final xfile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (xfile != null && mounted) {
        final newIndex = _photos.length;
        setState(() {
          _photos.add(xfile);
        });
        // Trigger animation for new slot
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && newIndex < _photoVisible.length) {
            setState(() => _photoVisible[newIndex] = true);
          }
        });
        HapticFeedback.lightImpact();
        _notifyParent();
      }
    } catch (_) {}
  }

  void _showImageSourceSheet() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, size: 24.r),
                title: Text(
                  l10n.chatImagePickerCamera,
                  style: TextStyle(fontSize: 15.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, size: 24.r),
                title: Text(
                  l10n.chatImagePickerGallery,
                  style: TextStyle(fontSize: 15.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      // Reset photo visibility after removal
      for (int i = 0; i < _photoVisible.length; i++) {
        _photoVisible[i] = i < _photos.length;
      }
    });
    HapticFeedback.selectionClick();
    _notifyParent();
  }

  void _showMaxPhotosSnackbar() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.regPhotoMax),
        duration: const Duration(seconds: 2),
      ),
    );
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

    final bodyTypeLabels = [
      l10n.regBodySlim,
      l10n.regBodySlightlySlim,
      l10n.regBodyAverage,
      l10n.regBodySlightlyChubby,
      l10n.regBodyChubby,
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Height wheel picker
          _stagger(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regHeightLabel, required: true),
                SizedBox(height: 8.h),
                Container(
                  height: 150.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 40.h,
                    perspective: 0.003,
                    diameterRatio: 2.0,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                      initialItem: _selectedHeight - 140,
                    ),
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedHeight = 140 + index);
                      _notifyParent();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 61, // 140 to 200
                      builder: (context, index) {
                        final h = 140 + index;
                        final isSelected = h == _selectedHeight;
                        return Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              fontSize: isSelected ? 20.sp : 15.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? primary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                            ),
                            child: Text('$h'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      l10n.regHeightValue(_selectedHeight),
                      key: ValueKey(_selectedHeight),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Body type chips
          _stagger(
            1,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regBodyTypeLabel, required: false),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(bodyTypeLabels.length, (i) {
                    final val = _bodyTypeValues[i];
                    final isSelected = _selectedBodyType == val;
                    return _BounceChip(
                      label: bodyTypeLabels[i],
                      isSelected: isSelected,
                      bounce: _bodyBounce[i],
                      onTap: () => _selectBodyType(i),
                    );
                  }),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Profile photos
          _stagger(
            2,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: l10n.regPhotoLabel, required: false),
                SizedBox(height: 8.h),
                _buildPhotoGrid(l10n, theme, primary),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14.r,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10n.regPhotoHint,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
    AppLocalizations l10n,
    ThemeData theme,
    Color primary,
  ) {
    final slots = <Widget>[];

    // Add photo thumbnails
    for (int i = 0; i < _photos.length; i++) {
      slots.add(
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: _PhotoSlot(
            key: ValueKey(_photos[i].path),
            photo: _photos[i],
            isMain: i == 0,
            mainLabel: l10n.regPhotoMain,
            onRemove: () => _removePhoto(i),
          ),
        ),
      );
    }

    // Add button if < 5 photos
    if (_photos.length < 5) {
      slots.add(
        _AddPhotoButton(
          label: l10n.regPhotoAdd,
          onTap: _showImageSourceSheet,
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 8.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: slots,
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

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28.r,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    super.key,
    required this.photo,
    required this.isMain,
    required this.mainLabel,
    required this.onRemove,
  });
  final XFile photo;
  final bool isMain;
  final String mainLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(photo.path),
            fit: BoxFit.cover,
          ),
        ),
        if (isMain)
          Positioned(
            bottom: 4.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                mainLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14.r,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
