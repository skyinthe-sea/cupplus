import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/client_summary.dart';
import '../models/marketplace_profile.dart';
import '../providers/marketplace_providers.dart';
import 'client_selection_sheet.dart';

class RequestMatchButton extends ConsumerStatefulWidget {
  const RequestMatchButton({
    super.key,
    required this.profile,
  });

  final MarketplaceProfile profile;

  @override
  ConsumerState<RequestMatchButton> createState() => _RequestMatchButtonState();
}

class _RequestMatchButtonState extends ConsumerState<RequestMatchButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleMatchRequest() async {
    if (_isLoading) return;

    final l10n = AppLocalizations.of(context)!;
    final p = widget.profile;

    setState(() => _isLoading = true);

    try {
      // Fetch eligible clients (opposite gender)
      final clients = await ref.read(
        myEligibleClientsProvider(p.gender).future,
      );

      if (!mounted) return;

      if (clients.isEmpty) {
        _showInfoDialog(l10n.matchRequestNoEligible);
        return;
      }

      if (clients.length == 1) {
        _showConfirmDialog(clients.first, p);
      } else {
        final selected = await ClientSelectionSheet.show(context, clients);
        if (selected != null && mounted) {
          _showConfirmDialog(selected, p);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInfoDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.commonConfirm),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(ClientSummary myClient, MarketplaceProfile target) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileDetailMatchRequestTitle),
        content: Text(
          l10n.matchRequestConfirmMessage(myClient.fullName, target.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _executeMatch(myClient, target);
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _executeMatch(
      ClientSummary myClient, MarketplaceProfile target) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      final error = await ref.read(
        createMatchProvider(
          clientAId: myClient.id,
          clientBId: target.id,
        ).future,
      );

      if (!mounted) return;

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.matchRequestSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } else if (error == 'daily_limit') {
        _showInfoDialog(l10n.matchRequestDailyLimit);
      } else if (error == 'unverified') {
        _showVerificationDialog(l10n, isUnverified: true);
      } else if (error == 'pending') {
        _showVerificationDialog(l10n, isUnverified: false);
      } else {
        _showInfoDialog(error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showVerificationDialog(AppLocalizations l10n,
      {required bool isUnverified}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          isUnverified
              ? l10n.matchRequestVerificationRequired
              : l10n.matchRequestVerificationPending,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonConfirm),
          ),
          if (isUnverified)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.verification);
              },
              child: Text(l10n.matchRequestVerify),
            ),
        ],
      ),
    );
  }

  Future<void> _onLikeTap() async {
    try {
      await ref.read(
        toggleLikeProvider(
          widget.profile.id,
          currentlyLiked: widget.profile.isLiked,
        ).future,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commonError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final p = widget.profile;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: bottomPadding + 12.h,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.85)
                : theme.colorScheme.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Like button
              GestureDetector(
                onTap: _onLikeTap,
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: p.isLiked
                        ? const Color(0xFFB4637A).withValues(alpha: 0.12)
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: p.isLiked
                          ? const Color(0xFFB4637A).withValues(alpha: 0.3)
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        p.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20.r,
                        color: p.isLiked
                            ? const Color(0xFFB4637A)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      if (p.likeCount > 0)
                        Text(
                          '${p.likeCount}',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: p.isLiked
                                ? const Color(0xFFB4637A)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) {
                    _scaleController.reverse();
                    _handleMatchRequest();
                  },
                  onTapCancel: () => _scaleController.reverse(),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                l10n.profileDetailRequestMatch,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
