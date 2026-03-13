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
  String? _selectedDocType;
  XFile? _selectedImage;
  bool _submitting = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  final _docTypes = [
    'business_card',
    'employment_cert',
    'business_registration',
  ];

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
    final statusAsync = ref.watch(managerVerificationStatusProvider);
    final docsAsync = ref.watch(myVerificationDocumentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verificationTitle)),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          children: [
            // Current status
            statusAsync.when(
              data: (status) => _buildStatusBanner(status, l10n, theme),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: 16.h),

            // Show rejection reason if applicable
            docsAsync.when(
              data: (docs) {
                final rejected = docs
                    .where((d) => d['status'] == 'rejected')
                    .toList();
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

            // Description
            Text(
              l10n.verificationDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Document type selection
            Text(
              l10n.verificationDocTypeTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            ..._docTypes.map((type) => _buildDocTypeOption(type, l10n, theme)),

            SizedBox(height: 24.h),

            // Image upload area
            Text(
              l10n.verificationUpload,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            _buildImageUploadArea(l10n, theme),

            SizedBox(height: 32.h),

            // Submit button
            FilledButton(
              onPressed: (_selectedDocType != null &&
                      _selectedImage != null &&
                      !_submitting)
                  ? _submit
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _submitting
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      l10n.verificationSubmit,
                      style: TextStyle(
                        fontSize: 15.sp,
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
        icon: Icons.schedule_rounded,
        color: Colors.orange,
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
    return Container(
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

  Widget _buildDocTypeOption(
      String type, AppLocalizations l10n, ThemeData theme) {
    final isSelected = _selectedDocType == type;
    final label = switch (type) {
      'business_card' => l10n.verificationBusinessCard,
      'employment_cert' => l10n.verificationEmploymentCert,
      'business_registration' => l10n.verificationBusinessReg,
      _ => type,
    };
    final icon = switch (type) {
      'business_card' => Icons.badge_outlined,
      'employment_cert' => Icons.description_outlined,
      'business_registration' => Icons.store_outlined,
      _ => Icons.file_present_outlined,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _selectedDocType = type),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22.r,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 22.r,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadArea(AppLocalizations l10n, ThemeData theme) {
    if (_selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(_selectedImage!.path),
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: IconButton.filled(
              onPressed: () => setState(() => _selectedImage = null),
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40.r,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _pickImage(source: ImageSource.camera),
                  icon: Icon(Icons.camera_alt_outlined, size: 18.r),
                  label: Text(l10n.verificationCamera),
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  onPressed: () => _pickImage(source: ImageSource.gallery),
                  icon: Icon(Icons.photo_library_outlined, size: 18.r),
                  label: Text(l10n.verificationGallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({ImageSource? source}) async {
    if (source != null) {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked != null) setState(() => _selectedImage = picked);
      return;
    }

    // Show picker dialog
    final l10n = AppLocalizations.of(context)!;
    final chosen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.verificationCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.verificationGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (chosen != null) {
      final picked = await ImagePicker().pickImage(source: chosen);
      if (picked != null) setState(() => _selectedImage = picked);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDocType == null || _selectedImage == null) return;

    setState(() => _submitting = true);

    try {
      await ref.read(
        submitVerificationDocumentProvider(
          documentType: _selectedDocType!,
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
