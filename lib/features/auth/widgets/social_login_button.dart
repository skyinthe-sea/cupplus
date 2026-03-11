import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

enum SocialLoginProvider { google, kakao }

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
    this.isLastUsed = false,
  });

  final SocialLoginProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isLastUsed;

  static const _kakaoYellow = Color(0xFFFEE500);
  static const _kakaoBrown = Color(0xFF3C1E1E);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isGoogle = provider == SocialLoginProvider.google;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isGoogle ? cs.surface : _kakaoYellow,
          foregroundColor: isGoogle ? cs.onSurface : _kakaoBrown,
          side: BorderSide(
            color: isGoogle ? cs.outlineVariant : _kakaoYellow,
            width: isGoogle ? 1 : 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: isGoogle ? cs.primary : _kakaoBrown,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isGoogle ? Icons.g_mobiledata_rounded : Icons.chat_bubble,
                    size: isGoogle ? 24.r : 18.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    isGoogle
                        ? l10n.authLoginWithGoogle
                        : l10n.authLoginWithKakao,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isLastUsed) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: (isGoogle ? cs.primary : _kakaoBrown)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        l10n.authLastUsed,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isGoogle ? cs.primary : _kakaoBrown,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
