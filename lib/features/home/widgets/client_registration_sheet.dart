import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../providers/home_providers.dart';

class ClientRegistrationSheet extends ConsumerStatefulWidget {
  const ClientRegistrationSheet({super.key});

  @override
  ConsumerState<ClientRegistrationSheet> createState() =>
      _ClientRegistrationSheetState();
}

class _ClientRegistrationSheetState
    extends ConsumerState<ClientRegistrationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _occupationController = TextEditingController();
  String _gender = 'F';
  DateTime? _birthDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) return;

      final managerProfile = ref.read(managerProfileProvider).valueOrNull;
      final regionId = managerProfile?['region_id'] as String? ?? 'default';

      await client.from('clients').insert({
        'manager_id': user.id,
        'region_id': regionId,
        'full_name': _nameController.text.trim(),
        'gender': _gender,
        'birth_date': _birthDate?.toIso8601String().substring(0, 10),
        'occupation': _occupationController.text.trim().isNotEmpty
            ? _occupationController.text.trim()
            : null,
        'status': 'active',
      });

      // Invalidate providers to refresh data
      ref.invalidate(activityFeedProvider);
      ref.invalidate(homeRecommendedClientsProvider);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeClientRegSuccess)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 8.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.homeClientRegTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.profileName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.homeClientRegNameRequired : null,
            ),
            SizedBox(height: 12.h),

            // Gender
            Row(
              children: [
                Text(
                  l10n.profileGender,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(width: 16.w),
                ChoiceChip(
                  label: Text(l10n.commonFemale),
                  selected: _gender == 'F',
                  onSelected: (_) => setState(() => _gender = 'F'),
                ),
                SizedBox(width: 8.w),
                ChoiceChip(
                  label: Text(l10n.commonMale),
                  selected: _gender == 'M',
                  onSelected: (_) => setState(() => _gender = 'M'),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Birth date
            InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: _pickBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.profileBirthDate,
                  prefixIcon: const Icon(Icons.cake_outlined),
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.year}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.day.toString().padLeft(2, '0')}'
                      : '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Occupation
            TextFormField(
              controller: _occupationController,
              decoration: InputDecoration(
                labelText: l10n.profileOccupation,
                prefixIcon: const Icon(Icons.business_center_outlined),
              ),
            ),
            SizedBox(height: 24.h),

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
