import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../../auth/providers/nickname_provider.dart';

class NicknameEditDialog extends ConsumerStatefulWidget {
  const NicknameEditDialog({super.key, this.currentNickname});

  final String? currentNickname;

  static Future<bool?> show(BuildContext context, {String? currentNickname}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => NicknameEditDialog(currentNickname: currentNickname),
    );
  }

  @override
  ConsumerState<NicknameEditDialog> createState() => _NicknameEditDialogState();
}

class _NicknameEditDialogState extends ConsumerState<NicknameEditDialog> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool? _isAvailable;
  bool _isChecking = false;
  bool _isValid = false;

  static final _nicknameRegex = RegExp(r'^[a-zA-Z0-9가-힣_]{2,20}$');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname ?? '');
    _validateAndCheck(_controller.text);
    _controller.addListener(() => _onChanged(_controller.text));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final valid = _nicknameRegex.hasMatch(value);
    setState(() {
      _isValid = valid;
      _isAvailable = null;
      _isChecking = valid;
    });

    _debounce?.cancel();
    if (!valid) return;

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkAvailability(value);
    });
  }

  void _validateAndCheck(String value) {
    final valid = _nicknameRegex.hasMatch(value);
    setState(() => _isValid = valid);
    if (valid) _checkAvailability(value);
  }

  Future<void> _checkAvailability(String nickname) async {
    setState(() => _isChecking = true);
    try {
      final available = await ref.read(
        checkNicknameAvailableProvider(nickname).future,
      );
      if (mounted && _controller.text == nickname) {
        setState(() {
          _isAvailable = available;
          _isChecking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAvailable = null;
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    final nickname = _controller.text.trim();
    final success = await ref
        .read(nicknameNotifierProvider.notifier)
        .updateNickname(nickname);
    if (mounted) {
      if (success) {
        ref.invalidate(managerProfileProvider);
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commonError),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final nicknameState = ref.watch(nicknameNotifierProvider);
    final isSaving = nicknameState is AsyncLoading;
    final canSubmit = _isValid && _isAvailable == true && !isSaving;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 20.h,
        bottom: bottomInset + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            l10n.nicknameEditTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.nicknameRules,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: l10n.nicknameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              suffixIcon: _buildSuffix(cs),
            ),
          ),
          if (_controller.text.isNotEmpty) ...[
            SizedBox(height: 4.h),
            _buildStatusText(l10n, cs),
          ],
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton(
              onPressed: canSubmit ? _submit : null,
              child: isSaving
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Text(l10n.nicknameConfirm),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildSuffix(ColorScheme cs) {
    if (_controller.text.isEmpty) return null;
    if (_isChecking) {
      return Padding(
        padding: EdgeInsets.all(12.r),
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
      );
    }
    if (!_isValid) {
      return Icon(Icons.close_rounded, color: cs.error);
    }
    if (_isAvailable == true) {
      return const Icon(Icons.check_circle_rounded, color: Colors.green);
    }
    if (_isAvailable == false) {
      return Icon(Icons.close_rounded, color: cs.error);
    }
    return null;
  }

  Widget _buildStatusText(AppLocalizations l10n, ColorScheme cs) {
    if (!_isValid) {
      return Text(
        l10n.nicknameInvalid,
        style: TextStyle(color: cs.error, fontSize: 12.sp),
      );
    }
    if (_isAvailable == true) {
      return Text(
        l10n.nicknameAvailable,
        style: TextStyle(color: Colors.green, fontSize: 12.sp),
      );
    }
    if (_isAvailable == false) {
      return Text(
        l10n.nicknameUnavailable,
        style: TextStyle(color: cs.error, fontSize: 12.sp),
      );
    }
    return const SizedBox.shrink();
  }
}
