import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../../home/widgets/illustration_placeholder.dart';
import '../providers/contract_provider.dart';
import '../services/contract_service.dart';

/// Shows contract history for a specific client.
class ContractHistoryScreen extends ConsumerWidget {
  const ContractHistoryScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final contractsAsync = ref.watch(clientContractsProvider(clientId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contractTitle)),
      body: contractsAsync.when(
        data: (contracts) {
          if (contracts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IllustrationImage(
                    assetPath: 'assets/images/illustrations/empty_contract.png',
                    width: 64.r,
                    height: 64.r,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.contractEmptyTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final c = contracts[index];
              return _ContractCard(
                contract: c,
                onTap: () => _showContractDetail(context, c, l10n, theme),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.commonError),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () =>
                    ref.invalidate(clientContractsProvider(clientId)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContractDetail(
    BuildContext context,
    Map<String, dynamic> contract,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final version = contract['contract_version'] as String? ?? '';
    final hash = contract['contract_hash'] as String? ?? '';
    final agreedAt = contract['agreed_at'] as String?;
    final marketing = contract['marketing_consent'] as bool? ?? false;
    final deviceInfo = contract['device_info'] as Map<String, dynamic>?;
    final date = agreedAt != null ? DateTime.tryParse(agreedAt) : null;

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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    '${l10n.contractVersion} $version',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Agreement metadata
                    _DetailRow(
                      label: l10n.contractAgreedAt,
                      value: date != null
                          ? '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
                          : '-',
                    ),
                    _DetailRow(
                      label: l10n.contractHashLabel,
                      value: hash.length > 16
                          ? '${hash.substring(0, 16)}...'
                          : hash,
                    ),
                    _DetailRow(
                      label: l10n.contractMarketingConsent,
                      value: marketing ? l10n.contractAgree : '-',
                    ),
                    if (deviceInfo != null)
                      _DetailRow(
                        label: l10n.contractDeviceInfo,
                        value: deviceInfo['platform'] as String? ?? '-',
                      ),
                    SizedBox(height: 24.h),

                    // Terms content
                    Text(
                      l10n.regAgreeTerms,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      termsContent,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.7,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Privacy content
                    Text(
                      l10n.regAgreePrivacy,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      privacyContent,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.7,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({required this.contract, required this.onTap});
  final Map<String, dynamic> contract;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final version = contract['contract_version'] as String? ?? '';
    final agreedAt = contract['agreed_at'] as String?;
    final marketing = contract['marketing_consent'] as bool? ?? false;
    final date = agreedAt != null ? DateTime.tryParse(agreedAt) : null;

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 24.r,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contract $version',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      date != null
                          ? '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}'
                          : '-',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (marketing)
                Chip(
                  label: Text('마케팅 동의', style: TextStyle(fontSize: 10.sp)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
