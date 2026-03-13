import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../contract/services/contract_service.dart' as contract;

class StepAgreement extends ConsumerStatefulWidget {
  const StepAgreement({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<StepAgreement> createState() => _StepAgreementState();
}

class _StepAgreementState extends ConsumerState<StepAgreement> {
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeMarketing = false;

  // Bounce triggers
  bool _bounceTerms = false;
  bool _bouncePrivacy = false;
  bool _bounceMarketing = false;
  bool _bounceAll = false;

  bool get _allChecked => _agreeTerms && _agreePrivacy && _agreeMarketing;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _agreeTerms = (d['agree_terms'] as bool?) ?? false;
    _agreePrivacy = (d['agree_privacy'] as bool?) ?? false;
    _agreeMarketing = (d['agree_marketing'] as bool?) ?? false;
  }

  void _notifyParent() {
    widget.onDataChanged({
      'agree_terms': _agreeTerms,
      'agree_privacy': _agreePrivacy,
      'agree_marketing': _agreeMarketing,
    });
  }

  void _triggerBounce(String which) {
    setState(() {
      if (which == 'terms') _bounceTerms = true;
      if (which == 'privacy') _bouncePrivacy = true;
      if (which == 'marketing') _bounceMarketing = true;
      if (which == 'all') _bounceAll = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _bounceTerms = false;
          _bouncePrivacy = false;
          _bounceMarketing = false;
          _bounceAll = false;
        });
      }
    });
  }

  void _toggleAgreeAll() {
    final newVal = !_allChecked;
    if (newVal) {
      // Sequential check with 50ms delay each
      Future.delayed(const Duration(milliseconds: 0), () {
        if (!mounted) return;
        setState(() {
          _agreeTerms = true;
          _bounceTerms = true;
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          setState(() {
            _agreePrivacy = true;
            _bouncePrivacy = true;
          });
          Future.delayed(const Duration(milliseconds: 50), () {
            if (!mounted) return;
            setState(() {
              _agreeMarketing = true;
              _bounceMarketing = true;
            });
            _notifyParent();
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  _bounceTerms = false;
                  _bouncePrivacy = false;
                  _bounceMarketing = false;
                });
              }
            });
          });
        });
      });
      _triggerBounce('all');
    } else {
      setState(() {
        _agreeTerms = false;
        _agreePrivacy = false;
        _agreeMarketing = false;
      });
      _triggerBounce('all');
      _notifyParent();
    }
  }

  void _setTerms(bool val) {
    setState(() => _agreeTerms = val);
    _triggerBounce('terms');
    if (!val) {
      setState(() {});
    }
    _notifyParent();
  }

  void _setPrivacy(bool val) {
    setState(() => _agreePrivacy = val);
    _triggerBounce('privacy');
    _notifyParent();
  }

  void _setMarketing(bool val) {
    setState(() => _agreeMarketing = val);
    _triggerBounce('marketing');
    _notifyParent();
  }

  void _showTermsSheet(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: EdgeInsets.all(20.r),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.7,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(l10n.commonConfirm, style: TextStyle(fontSize: 15.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Contract content is centralized in contract_service.dart
  static String get _termsContent => contract.termsContent;
  static String get _privacyContent => contract.privacyContent;
  static String get _marketingContent => contract.marketingContent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1.0,
            child: Text(
              l10n.regAgreeDesc,
              style: TextStyle(
                fontSize: 15.sp,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Agreement card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Agree all
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  child: Row(
                    children: [
                      _BounceCheckbox(
                        value: _allChecked,
                        bounce: _bounceAll,
                        onChanged: (_) => _toggleAgreeAll(),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10n.regAgreeAll,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: theme.colorScheme.outlineVariant,
                ),

                // Terms
                _AgreementTile(
                  label: l10n.regAgreeTerms,
                  badge: l10n.regRequired,
                  value: _agreeTerms,
                  bounce: _bounceTerms,
                  badgeRequired: true,
                  onChanged: _setTerms,
                  onViewTap: () => _showTermsSheet(
                    context,
                    l10n.regAgreeTerms,
                    _termsContent,
                  ),
                  viewLabel: l10n.regView,
                ),

                // Privacy
                _AgreementTile(
                  label: l10n.regAgreePrivacy,
                  badge: l10n.regRequired,
                  value: _agreePrivacy,
                  bounce: _bouncePrivacy,
                  badgeRequired: true,
                  onChanged: _setPrivacy,
                  onViewTap: () => _showTermsSheet(
                    context,
                    l10n.regAgreePrivacy,
                    _privacyContent,
                  ),
                  viewLabel: l10n.regView,
                ),

                // Marketing
                _AgreementTile(
                  label: l10n.regAgreeMarketing,
                  badge: l10n.regOptional,
                  value: _agreeMarketing,
                  bounce: _bounceMarketing,
                  badgeRequired: false,
                  onChanged: _setMarketing,
                  onViewTap: () => _showTermsSheet(
                    context,
                    l10n.regAgreeMarketing,
                    _marketingContent,
                  ),
                  viewLabel: l10n.regView,
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

class _BounceCheckbox extends StatefulWidget {
  const _BounceCheckbox({
    required this.value,
    required this.bounce,
    required this.onChanged,
  });
  final bool value;
  final bool bounce;
  final ValueChanged<bool?> onChanged;

  @override
  State<_BounceCheckbox> createState() => _BounceCheckboxState();
}

class _BounceCheckboxState extends State<_BounceCheckbox>
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
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_BounceCheckbox old) {
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
    return ScaleTransition(
      scale: _scale,
      child: Checkbox(
        value: widget.value,
        onChanged: widget.onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({
    required this.label,
    required this.badge,
    required this.value,
    required this.bounce,
    required this.badgeRequired,
    required this.onChanged,
    required this.onViewTap,
    required this.viewLabel,
  });

  final String label;
  final String badge;
  final bool value;
  final bool bounce;
  final bool badgeRequired;
  final ValueChanged<bool> onChanged;
  final VoidCallback onViewTap;
  final String viewLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Row(
        children: [
          _BounceCheckbox(
            value: value,
            bounce: bounce,
            onChanged: (v) => onChanged(v ?? false),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: badgeRequired
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onViewTap,
            style: TextButton.styleFrom(
              foregroundColor: primary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              viewLabel,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}
