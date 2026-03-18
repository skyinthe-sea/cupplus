import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../../contract/services/contract_service.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../providers/home_providers.dart';
import '../widgets/registration_steps/step_basic_info.dart';
import '../widgets/registration_steps/step_career_education.dart';
import '../widgets/registration_steps/step_appearance.dart';
import '../widgets/registration_steps/step_personality.dart';
import '../widgets/registration_steps/step_family_lifestyle.dart';
import '../widgets/registration_steps/step_agreement.dart';
import '../widgets/registration_steps/registration_success_screen.dart';

// Contract hash is computed dynamically via contract_service.dart

class ClientRegistrationScreen extends ConsumerStatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  ConsumerState<ClientRegistrationScreen> createState() =>
      _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState
    extends ConsumerState<ClientRegistrationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  int _draftRevision = 0;
  bool _userHasInteracted = false;

  // Direction tracking for animation
  bool _goingForward = true;

  // Per-step data maps
  final List<Map<String, dynamic>> _stepData = [
    {}, // step 1: basic info
    {}, // step 2: career/education
    {}, // step 3: appearance
    {}, // step 4: personality
    {}, // step 5: family/lifestyle
    {}, // step 6: agreement
  ];

  // Dot bounce animations
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotScales;

  static const _totalSteps = 6;

  @override
  void initState() {
    super.initState();

    _dotControllers = List.generate(
      _totalSteps,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _dotScales = _dotControllers.map((c) {
      return TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    _dotControllers[0].forward(from: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClientLimit();
      _checkForDraft();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Client limit check ───────────────────────────────────────────────────

  Future<void> _checkClientLimit() async {
    final canRegister = await ref.read(canRegisterClientProvider.future);
    if (!canRegister && mounted) {
      final l10n = AppLocalizations.of(context)!;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(l10n.subscriptionClientLimitReached),
          content: Text(l10n.subscriptionUpgradePrompt),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ── Draft management ──────────────────────────────────────────────────────

  String _draftKey(String managerId) =>
      'draft_client_registration_$managerId';

  Future<String?> _getManagerId() async {
    final client = ref.read(supabaseClientProvider);
    return client.auth.currentUser?.id;
  }

  Future<void> _saveDraft() async {
    if (!_hasAnyInput()) return;
    final managerId = await _getManagerId();
    if (managerId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftData = <String, dynamic>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'step': _currentStep,
      };
      for (int i = 0; i < _stepData.length; i++) {
        final stepCopy = Map<String, dynamic>.from(_stepData[i]);
        // Convert XFile photos to path strings for serialization
        final photos = stepCopy.remove('photos');
        if (photos is List && photos.isNotEmpty) {
          stepCopy['photo_paths'] = photos
              .whereType<XFile>()
              .map((x) => x.path)
              .toList();
        }
        draftData['step_$i'] = stepCopy;
      }
      await prefs.setString(_draftKey(managerId), jsonEncode(draftData));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _loadDraft() async {
    final managerId = await _getManagerId();
    if (managerId == null) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey(managerId));
      if (raw == null) return null;
      final draft = jsonDecode(raw) as Map<String, dynamic>;
      // Check expiry (7 days)
      final ts = draft['timestamp'] as int? ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > const Duration(days: 7).inMilliseconds) {
        await prefs.remove(_draftKey(managerId));
        return null;
      }
      return draft;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteDraft() async {
    final managerId = await _getManagerId();
    if (managerId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey(managerId));
    } catch (_) {}
  }

  bool _draftHasData(Map<String, dynamic> draft) {
    for (int i = 0; i < _totalSteps; i++) {
      final stepMap = draft['step_$i'] as Map<String, dynamic>?;
      if (stepMap == null) continue;
      for (final value in stepMap.values) {
        if (value == null) continue;
        if (value is String && value.trim().isNotEmpty) return true;
        if (value is bool && value) return true;
        if (value is List && value.isNotEmpty) return true;
        if (value is int) {
          if (value == 170 || value == 160) continue;
          return true;
        }
        if (value is double) return true;
      }
    }
    return false;
  }

  Future<void> _checkForDraft() async {
    final draft = await _loadDraft();
    if (draft == null || !mounted) return;
    if (!_draftHasData(draft)) {
      await _deleteDraft();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final resume = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Text(
          l10n.regDraftFound,
          style: TextStyle(fontSize: 15.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.regDraftNew),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.regDraftContinue),
          ),
        ],
      ),
    );

    if (resume == true && mounted) {
      final savedStep = draft['step'] as int? ?? 0;
      for (int i = 0; i < _stepData.length; i++) {
        final saved = draft['step_$i'] as Map<String, dynamic>?;
        if (saved != null) {
          final stepMap = Map<String, dynamic>.from(saved);
          // Restore photo paths to XFile objects
          final paths = stepMap.remove('photo_paths');
          if (paths is List && paths.isNotEmpty) {
            final validPhotos = <XFile>[];
            for (final p in paths) {
              if (p is String) {
                final file = File(p);
                if (file.existsSync()) {
                  validPhotos.add(XFile(p));
                }
              }
            }
            if (validPhotos.isNotEmpty) {
              stepMap['photos'] = validPhotos;
            }
          }
          _stepData[i] = stepMap;
        }
      }
      setState(() {
        _currentStep = savedStep;
        _draftRevision++;
        _userHasInteracted = true;
      });
      if (savedStep > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _pageController.jumpToPage(savedStep);
        });
      }
    }
  }

  // ── Step navigation ───────────────────────────────────────────────────────

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        final d = _stepData[0];
        final name = (d['full_name'] as String? ?? '').trim();
        return name.length >= 2 &&
            (d['gender'] as String?) != null &&
            (d['birth_date'] as String?) != null;
      case 1:
        final occ = (_stepData[1]['occupation'] as String? ?? '').trim();
        return occ.isNotEmpty;
      case 2:
        return (_stepData[2]['height_cm'] as int?) != null ||
            (_stepData[2]['height_cm'] == null && true);
      case 3:
        return (_stepData[3]['religion'] as String?) != null;
      case 4:
        // Family/lifestyle step — all optional
        return true;
      case 5:
        return (_stepData[5]['agree_terms'] as bool? ?? false) &&
            (_stepData[5]['agree_privacy'] as bool? ?? false);
      default:
        return false;
    }
  }

  // Step 2 validity: height is required but we set a default so always valid
  // once the widget initializes.
  bool get _currentStepValid {
    if (_currentStep == 2) {
      // Height defaults to 170/160 so it's always set
      return true;
    }
    return _isStepValid(_currentStep);
  }

  void _goToNextStep() async {
    if (_currentStep >= _totalSteps - 1) return;
    await _saveDraft();
    if (!mounted) return;
    setState(() {
      _goingForward = true;
      _currentStep++;
    });
    _dotControllers[_currentStep].forward(from: 0);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToPrevStep() async {
    if (_currentStep <= 0) return;
    await _saveDraft();
    if (!mounted) return;
    setState(() {
      _goingForward = false;
      _currentStep--;
    });
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _onComplete() async {
    if (!_isStepValid(5)) return;

    // Re-check client limit (race condition guard)
    final canRegister = await ref.read(canRegisterClientProvider.future);
    if (!canRegister) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subscriptionClientLimitReached)),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final managerProfile = ref.read(managerProfileProvider).valueOrNull;
      final regionId = managerProfile?['region_id'] as String? ?? 'default';

      // Merge all step data
      final d1 = _stepData[0];
      final d2 = _stepData[1];
      final d3 = _stepData[2];
      final d4 = _stepData[3];
      final d5Family = _stepData[4];

      // Determine height with default
      final gender = d1['gender'] as String? ?? 'F';
      final defaultHeight = gender == 'M' ? 170 : 160;
      final heightCm = (d3['height_cm'] as int?) ?? defaultHeight;

      final hobbies = (d4['hobbies'] as List?)?.cast<String>() ?? <String>[];

      final insertData = <String, dynamic>{
        'manager_id': user.id,
        'region_id': regionId,
        'full_name': (d1['full_name'] as String? ?? '').trim(),
        'gender': d1['gender'] as String? ?? 'F',
        'birth_date': d1['birth_date'] as String?,
        'height_cm': heightCm,
        'status': 'active',
      };

      // Optional fields — only include if non-null/non-empty
      _setIfNotEmpty(insertData, 'phone', d1['phone'] as String?);
      _setIfNotEmpty(insertData, 'email', d1['email'] as String?);
      _setIfNotEmpty(insertData, 'occupation', d2['occupation'] as String?);
      _setIfNotEmpty(insertData, 'company', d2['company'] as String?);
      _setIfNotNull(insertData, 'education_level', d2['education_level']);
      _setIfNotEmpty(insertData, 'school', d2['school'] as String?);
      _setIfNotEmpty(insertData, 'major', d2['major'] as String?);
      _setIfNotNull(
        insertData,
        'annual_income_range',
        d2['annual_income_range'],
      );
      _setIfNotNull(insertData, 'body_type', d3['body_type']);
      _setIfNotNull(insertData, 'religion', d4['religion']);
      if (hobbies.isNotEmpty) {
        insertData['hobbies'] = hobbies;
      }
      _setIfNotEmpty(insertData, 'bio', d4['bio'] as String?);

      // Step 5: Family/Lifestyle
      _setIfNotNull(insertData, 'marital_history', d5Family['marital_history']);
      if (d5Family['has_children'] == true) {
        insertData['has_children'] = true;
        _setIfNotNull(insertData, 'children_count', d5Family['children_count']);
      }
      _setIfNotEmpty(insertData, 'family_detail', d5Family['family_detail'] as String?);
      _setIfNotNull(insertData, 'parents_status', d5Family['parents_status']);
      _setIfNotNull(insertData, 'drinking', d5Family['drinking']);
      _setIfNotNull(insertData, 'smoking', d5Family['smoking']);
      _setIfNotNull(insertData, 'asset_range', d5Family['asset_range']);
      _setIfNotEmpty(insertData, 'residence_area', d5Family['residence_area'] as String?);
      _setIfNotNull(insertData, 'residence_type', d5Family['residence_type']);
      _setIfNotEmpty(insertData, 'health_notes', d5Family['health_notes'] as String?);

      // Insert client
      final result =
          await supabase.from('clients').insert(insertData).select().single();

      final clientId = result['id'] as String;
      final clientName = result['full_name'] as String;

      // Upload photos if any
      final photos = (d3['photos'] as List<XFile>?) ?? [];
      if (photos.isNotEmpty) {
        String? firstPhotoUrl;
        for (int i = 0; i < photos.length; i++) {
          try {
            final photo = photos[i];
            final bytes = await photo.readAsBytes();
            final path = '$clientId/photo_$i.jpg';
            await supabase.storage
                .from('profile-photos')
                .uploadBinary(
                  path,
                  bytes,
                  fileOptions: const FileOptions(
                    contentType: 'image/jpeg',
                    upsert: true,
                  ),
                );
            if (i == 0) {
              firstPhotoUrl = 'profile-photos/$path';
            }
          } catch (_) {
            // Photo upload failure is non-fatal — client still registered
          }
        }

        // Update profile_photo_url if we got one
        if (firstPhotoUrl != null) {
          try {
            await supabase
                .from('clients')
                .update({'profile_photo_url': firstPhotoUrl})
                .eq('id', clientId);
          } catch (_) {}
        }
      }

      // Insert contract agreement with proper SHA-256 hash + device info
      final d6Agreement = _stepData[5];
      final agreeMarketing = (d6Agreement['agree_marketing'] as bool?) ?? false;
      try {
        await supabase.from('contract_agreements').insert({
          'client_id': clientId,
          'manager_id': user.id,
          'region_id': regionId,
          'contract_version': currentContractVersion,
          'contract_hash': computeContractHash(termsContent, privacyContent),
          'device_info': collectDeviceInfo(),
          'marketing_consent': agreeMarketing,
        });
      } catch (_) {
        // Contract insert failure is non-fatal
      }

      // Invalidate providers
      ref.invalidate(activityFeedProvider);
      ref.invalidate(homeRecommendedClientsProvider);
      ref.invalidate(homeTodayStatsProvider);

      // Delete draft
      await _deleteDraft();

      if (!mounted) return;

      // Navigate to success screen
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (ctx, a1, a2) => RegistrationSuccessScreen(
            clientId: clientId,
            clientName: clientName,
          ),
          transitionsBuilder: (tctx, anim, secAnim, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e, st) {
      debugPrint('Registration error: $e\n$st');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.commonError}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.commonRetry,
            textColor: Colors.white,
            onPressed: _onComplete,
          ),
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  static void _setIfNotEmpty(
    Map<String, dynamic> map,
    String key,
    String? value,
  ) {
    if (value != null && value.trim().isNotEmpty) {
      map[key] = value.trim();
    }
  }

  static void _setIfNotNull(
    Map<String, dynamic> map,
    String key,
    dynamic value,
  ) {
    if (value != null) {
      map[key] = value;
    }
  }

  // ── Exit dialog ───────────────────────────────────────────────────────────

  bool _hasAnyInput() {
    if (!_userHasInteracted) return false;
    for (final stepMap in _stepData) {
      for (final value in stepMap.values) {
        if (value == null) continue;
        if (value is String && value.trim().isNotEmpty) return true;
        if (value is bool && value) return true;
        if (value is List && value.isNotEmpty) return true;
        if (value is int || value is double) return true;
      }
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasAnyInput()) return true;

    final l10n = AppLocalizations.of(context)!;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.regExitTitle,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.regExitMessage,
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.regExitLeave),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      await _saveDraft();
      return true;
    }
    return false;
  }

  // ── Step titles ───────────────────────────────────────────────────────────

  String _stepTitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
        return l10n.regStep1Title;
      case 1:
        return l10n.regStep2Title;
      case 2:
        return l10n.regStep3Title;
      case 3:
        return l10n.regStep4Title;
      case 4:
        return l10n.regStep5Title;
      case 5:
        return l10n.regStep6Title;
      default:
        return '';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, size: 24.r),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            children: [
              // Dot indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_totalSteps, (i) {
                  final isActive = i == _currentStep;
                  final isDone = i < _currentStep;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: ScaleTransition(
                      scale: _dotScales[i],
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 10.r : 8.r,
                        height: isActive ? 10.r : 8.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isActive || isDone)
                              ? primary
                              : Colors.transparent,
                          border: (isActive || isDone)
                              ? null
                              : Border.all(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 4.h),
              // Step n/5 label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  l10n.regStepOf(
                    _currentStep + 1,
                    _totalSteps,
                  ),
                  key: ValueKey(_currentStep),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Step title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) {
                  final slideAnim = Tween<Offset>(
                    begin: _goingForward
                        ? const Offset(0.15, 0)
                        : const Offset(-0.15, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOut),
                  );
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: slideAnim, child: child),
                  );
                },
                child: Align(
                  key: ValueKey(_currentStep),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _stepTitle(l10n),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                key: ValueKey(_draftRevision),
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StepBasicInfo(
                    data: Map<String, dynamic>.from(_stepData[0]),
                    onDataChanged: (d) => setState(() {
                      _stepData[0] = d;
                      _userHasInteracted = true;
                    }),
                  ),
                  StepCareerEducation(
                    data: Map<String, dynamic>.from(_stepData[1]),
                    onDataChanged: (d) => setState(() {
                      _stepData[1] = d;
                      _userHasInteracted = true;
                    }),
                  ),
                  StepAppearance(
                    data: {
                      ..._stepData[2],
                      'gender': _stepData[0]['gender'],
                    },
                    onDataChanged: (d) => setState(() {
                      _stepData[2] = d;
                      _userHasInteracted = true;
                    }),
                  ),
                  StepPersonality(
                    data: Map<String, dynamic>.from(_stepData[3]),
                    onDataChanged: (d) => setState(() {
                      _stepData[3] = d;
                      _userHasInteracted = true;
                    }),
                  ),
                  StepFamilyLifestyle(
                    data: Map<String, dynamic>.from(_stepData[4]),
                    onDataChanged: (d) => setState(() {
                      _stepData[4] = d;
                      _userHasInteracted = true;
                    }),
                  ),
                  StepAgreement(
                    data: Map<String, dynamic>.from(_stepData[5]),
                    onDataChanged: (d) => setState(() {
                      _stepData[5] = d;
                      _userHasInteracted = true;
                    }),
                  ),
                ],
              ),
            ),

            // Bottom buttons
            _buildBottomButtons(l10n, theme, primary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(
    AppLocalizations l10n,
    ThemeData theme,
    Color primary,
  ) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isLastStep = _currentStep == _totalSteps - 1;
    final isFirstStep = _currentStep == 0;

    // Determine if next/complete is enabled
    final canProceed = _currentStepValid && !_isLoading;

    // For step 6, final button enabled only when required terms checked
    final canComplete =
        (_stepData[5]['agree_terms'] as bool? ?? false) &&
        (_stepData[5]['agree_privacy'] as bool? ?? false) &&
        !_isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h + bottomPad),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstStep) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _goToPrevStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  l10n.regPrevious,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: isLastStep
                ? FilledButton(
                    onPressed: canComplete ? _onComplete : null,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(0, 52.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.regComplete,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilledButton(
                      onPressed: canProceed ? _goToNextStep : null,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(0, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        disabledBackgroundColor:
                            theme.colorScheme.onSurface.withValues(alpha: 0.12),
                      ),
                      child: Text(
                        l10n.commonNext,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
