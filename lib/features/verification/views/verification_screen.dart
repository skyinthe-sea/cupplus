import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/verification_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen>
    with SingleTickerProviderStateMixin {
  XFile? _selectedImage;
  bool _submitting = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusAsync = ref.watch(managerVerificationStatusProvider);
    final docsAsync = ref.watch(myVerificationDocumentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verificationTitle)),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          children: [
            // Status banner
            statusAsync.when(
              data: (status) => _buildStatusBanner(status, l10n, theme),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Rejection banner
            docsAsync.when(
              data: (docs) {
                final rejected =
                    docs.where((d) => d['status'] == 'rejected').toList();
                if (rejected.isNotEmpty) {
                  final reason =
                      rejected.first['rejection_reason'] as String?;
                  return _buildRejectedBanner(reason, l10n, theme);
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: 8.h),

            // Hero icon
            Center(
              child: Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 36.r,
                  color: cs.primary,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Description
            Text(
              l10n.verificationDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Accepted documents list
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.verificationAcceptedDocs,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _docItem(Icons.badge_outlined, l10n.verificationBusinessCard),
                  SizedBox(height: 6.h),
                  _docItem(Icons.description_outlined,
                      l10n.verificationEmploymentCert),
                  SizedBox(height: 6.h),
                  _docItem(
                      Icons.store_outlined, l10n.verificationBusinessReg),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // Upload area
            _buildUploadArea(l10n, theme),

            SizedBox(height: 24.h),

            // Submit button
            FilledButton(
              onPressed:
                  (_selectedImage != null && !_submitting) ? _submit : null,
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: _submitting
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Text(
                      l10n.verificationSubmit,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _docItem(IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16.r,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(
      String status, AppLocalizations l10n, ThemeData theme) {
    if (status == 'verified') {
      return _statusCard(
        icon: Icons.verified_rounded,
        color: Colors.green,
        text: l10n.verificationStatusVerified,
        theme: theme,
      );
    }
    if (status == 'pending') {
      return _statusCard(
        icon: Icons.hourglass_top_rounded,
        color: Colors.amber.shade700,
        text: l10n.verificationStatusPending,
        theme: theme,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required String text,
    required ThemeData theme,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedBanner(
      String? reason, AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_rounded,
                    color: theme.colorScheme.error, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  l10n.verificationRejectedMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (reason != null && reason.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                l10n.verificationRejectedReason(reason),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(AppLocalizations l10n, ThemeData theme) {
    final cs = theme.colorScheme;

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Image.file(
              File(_selectedImage!.path),
              width: double.infinity,
              height: 220.h,
              fit: BoxFit.cover,
            ),
            // Gradient overlay at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60.h,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black38, Colors.transparent],
                  ),
                ),
              ),
            ),
            // Remove button
            Positioned(
              top: 10.h,
              right: 10.w,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImage = null),
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 18.r, color: Colors.white),
                ),
              ),
            ),
            // Change button
            Positioned(
              bottom: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: _showPickerSheet,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 14.r, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        l10n.verificationChangeImage,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty upload area — tap to pick
    return GestureDetector(
      onTap: _showPickerSheet,
      child: Container(
        height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          color: cs.primary.withValues(alpha: 0.03),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_rounded,
                size: 26.r,
                color: cs.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.verificationUploadHint,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.verificationUploadSub,
              style: TextStyle(
                fontSize: 12.sp,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerSheet() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, size: 24.r),
                title: Text(l10n.verificationCamera),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, size: 24.r),
                title: Text(l10n.verificationGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (picked != null && mounted) {
      setState(() => _selectedImage = picked);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedImage == null) return;

    setState(() => _submitting = true);

    try {
      await ref.read(
        submitVerificationDocumentProvider(
          documentType: 'verification_doc',
          imageFile: _selectedImage!,
        ).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verificationSubmitSuccess)),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verificationSubmitFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
