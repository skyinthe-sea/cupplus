import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/my_clients_provider.dart';

class MyClientEditScreen extends ConsumerStatefulWidget {
  const MyClientEditScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<MyClientEditScreen> createState() => _MyClientEditScreenState();
}

class _MyClientEditScreenState extends ConsumerState<MyClientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _majorCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _familyDetailCtrl;
  late final TextEditingController _residenceAreaCtrl;
  late final TextEditingController _healthNotesCtrl;
  late final TextEditingController _personalityTypeCtrl;
  late final TextEditingController _idealNotesCtrl;

  // State
  String _gender = 'M';
  String? _birthDate;
  String? _educationLevel;
  int? _heightCm;
  String? _bodyType;
  String? _religion;
  String? _annualIncomeRange;
  String? _maritalHistory;
  bool _hasChildren = false;
  int _childrenCount = 0;
  String? _parentsStatus;
  String? _drinking;
  String? _smoking;
  String? _assetRange;
  String? _residenceType;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _occupationCtrl = TextEditingController();
    _companyCtrl = TextEditingController();
    _schoolCtrl = TextEditingController();
    _majorCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _familyDetailCtrl = TextEditingController();
    _residenceAreaCtrl = TextEditingController();
    _healthNotesCtrl = TextEditingController();
    _personalityTypeCtrl = TextEditingController();
    _idealNotesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _occupationCtrl.dispose();
    _companyCtrl.dispose();
    _schoolCtrl.dispose();
    _majorCtrl.dispose();
    _bioCtrl.dispose();
    _familyDetailCtrl.dispose();
    _residenceAreaCtrl.dispose();
    _healthNotesCtrl.dispose();
    _personalityTypeCtrl.dispose();
    _idealNotesCtrl.dispose();
    super.dispose();
  }

  /// Returns [value] only if it is in [allowed], otherwise null.
  String? _validOrNull(String? value, List<String> allowed) =>
      value != null && allowed.contains(value) ? value : null;

  static const _educationLevels = ['high_school', 'associate', 'bachelor', 'master', 'doctorate'];
  static const _bodyTypes = ['slim', 'slightly_slim', 'average', 'slightly_chubby', 'chubby'];
  static const _religions = ['무교', '기독교', '천주교', '불교', '기타'];
  static const _incomeRanges = ['under_30m', '30m_50m', '50m_70m', '70m_100m', '100m_150m', 'over_150m'];
  static const _maritalHistories = ['first_marriage', 'remarriage', 'divorced'];
  static const _parentsStatuses = ['both_alive', 'father_only', 'mother_only', 'deceased'];
  static const _drinkingVals = ['none', 'social', 'regular'];
  static const _smokingVals = ['none', 'sometimes', 'regular'];
  static const _assetRanges = ['under_100m', '100m_300m', '300m_500m', '500m_1b', 'over_1b'];
  static const _residenceTypes = ['own', 'rent_deposit', 'rent_monthly', 'with_parents'];

  void _initFromDetail(ClientDetail detail) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = detail.fullName;
    _phoneCtrl.text = detail.phone ?? '';
    _emailCtrl.text = detail.email ?? '';
    _occupationCtrl.text = detail.occupation ?? '';
    _companyCtrl.text = detail.company ?? '';
    _schoolCtrl.text = detail.school ?? '';
    _majorCtrl.text = detail.major ?? '';
    _bioCtrl.text = detail.bio ?? '';
    _gender = detail.gender;
    _birthDate = detail.birthDate;
    _educationLevel = _validOrNull(detail.educationLevel, _educationLevels);
    _heightCm = detail.heightCm;
    _bodyType = _validOrNull(detail.bodyType, _bodyTypes);
    _religion = _validOrNull(detail.religion, _religions);
    _annualIncomeRange = _validOrNull(detail.annualIncomeRange, _incomeRanges);
    _maritalHistory = _validOrNull(detail.maritalHistory, _maritalHistories);
    _hasChildren = detail.hasChildren;
    _childrenCount = detail.childrenCount ?? 0;
    _familyDetailCtrl.text = detail.familyDetail ?? '';
    _parentsStatus = _validOrNull(detail.parentsStatus, _parentsStatuses);
    _drinking = _validOrNull(detail.drinking, _drinkingVals);
    _smoking = _validOrNull(detail.smoking, _smokingVals);
    _assetRange = _validOrNull(detail.assetRange, _assetRanges);
    _residenceAreaCtrl.text = detail.residenceArea ?? '';
    _residenceType = _validOrNull(detail.residenceType, _residenceTypes);
    _healthNotesCtrl.text = detail.healthNotes ?? '';
    _personalityTypeCtrl.text = detail.personalityType ?? '';
    _idealNotesCtrl.text = detail.idealNotes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(myClientDetailProvider(widget.clientId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return detailAsync.when(
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.errorNotFound)),
          );
        }
        _initFromDetail(detail);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myClientEditTitle),
            actions: [
              TextButton(
                onPressed: _saving ? null : () => _save(l10n),
                child: _saving
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.commonSave),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              children: [
                // Name
                _buildField(
                  label: l10n.regNameLabel,
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regNameHint),
                    validator: (v) {
                      if (v == null || v.trim().length < 2) {
                        return l10n.regNameValidation;
                      }
                      return null;
                    },
                  ),
                ),

                // Gender
                _buildField(
                  label: l10n.profileGender,
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'M',
                        label: Text(l10n.commonMale),
                      ),
                      ButtonSegment(
                        value: 'F',
                        label: Text(l10n.commonFemale),
                      ),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (v) =>
                        setState(() => _gender = v.first),
                  ),
                ),

                // Birth date
                _buildField(
                  label: l10n.profileBirthDate,
                  child: InkWell(
                    onTap: _pickBirthDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(
                        _birthDate ?? '-',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),

                // Phone
                _buildField(
                  label: l10n.regPhoneLabel,
                  child: TextFormField(
                    controller: _phoneCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regPhoneHint),
                    keyboardType: TextInputType.phone,
                  ),
                ),

                // Email
                _buildField(
                  label: l10n.regEmailLabel,
                  child: TextFormField(
                    controller: _emailCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regEmailHint),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),

                // Occupation
                _buildField(
                  label: l10n.regOccupationLabel,
                  child: TextFormField(
                    controller: _occupationCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regOccupationHint),
                  ),
                ),

                // Company
                _buildField(
                  label: l10n.regCompanyLabel,
                  child: TextFormField(
                    controller: _companyCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regCompanyHint),
                  ),
                ),

                // Education level
                _buildField(
                  label: l10n.regEducationLevel,
                  child: DropdownButtonFormField<String>(
                    value: _educationLevel,
                    items: [
                      DropdownMenuItem(
                          value: 'high_school',
                          child: Text(l10n.regEduHighSchool)),
                      DropdownMenuItem(
                          value: 'associate',
                          child: Text(l10n.regEduAssociate)),
                      DropdownMenuItem(
                          value: 'bachelor',
                          child: Text(l10n.regEduBachelor)),
                      DropdownMenuItem(
                          value: 'master', child: Text(l10n.regEduMaster)),
                      DropdownMenuItem(
                          value: 'doctorate',
                          child: Text(l10n.regEduDoctorate)),
                    ],
                    onChanged: (v) =>
                        setState(() => _educationLevel = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // School
                _buildField(
                  label: l10n.regSchoolLabel,
                  child: TextFormField(
                    controller: _schoolCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regSchoolHint),
                  ),
                ),

                // Major
                _buildField(
                  label: l10n.regMajorLabel,
                  child: TextFormField(
                    controller: _majorCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regMajorHint),
                  ),
                ),

                // Height
                _buildField(
                  label: l10n.regHeightLabel,
                  child: Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: (_heightCm ?? 170).toDouble(),
                          min: 140,
                          max: 200,
                          divisions: 60,
                          label: '${_heightCm ?? 170}cm',
                          onChanged: (v) =>
                              setState(() => _heightCm = v.round()),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${_heightCm ?? 170}cm',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body type
                _buildField(
                  label: l10n.regBodyTypeLabel,
                  child: DropdownButtonFormField<String>(
                    value: _bodyType,
                    items: [
                      DropdownMenuItem(
                          value: 'slim', child: Text(l10n.regBodySlim)),
                      DropdownMenuItem(
                          value: 'slightly_slim',
                          child: Text(l10n.regBodySlightlySlim)),
                      DropdownMenuItem(
                          value: 'average',
                          child: Text(l10n.regBodyAverage)),
                      DropdownMenuItem(
                          value: 'slightly_chubby',
                          child: Text(l10n.regBodySlightlyChubby)),
                      DropdownMenuItem(
                          value: 'chubby',
                          child: Text(l10n.regBodyChubby)),
                    ],
                    onChanged: (v) => setState(() => _bodyType = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Religion
                _buildField(
                  label: l10n.regReligionLabel,
                  child: DropdownButtonFormField<String>(
                    value: _religion,
                    items: [
                      DropdownMenuItem(
                          value: '무교', child: Text(l10n.regReligionNone)),
                      DropdownMenuItem(
                          value: '기독교',
                          child: Text(l10n.regReligionChristian)),
                      DropdownMenuItem(
                          value: '천주교',
                          child: Text(l10n.regReligionCatholic)),
                      DropdownMenuItem(
                          value: '불교',
                          child: Text(l10n.regReligionBuddhist)),
                      DropdownMenuItem(
                          value: '기타', child: Text(l10n.regReligionOther)),
                    ],
                    onChanged: (v) => setState(() => _religion = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Income
                _buildField(
                  label: l10n.regIncomeLabel,
                  child: DropdownButtonFormField<String>(
                    value: _annualIncomeRange,
                    items: [
                      DropdownMenuItem(
                          value: 'under_30m', child: Text(l10n.regIncome1)),
                      DropdownMenuItem(
                          value: '30m_50m', child: Text(l10n.regIncome2)),
                      DropdownMenuItem(
                          value: '50m_70m', child: Text(l10n.regIncome3)),
                      DropdownMenuItem(
                          value: '70m_100m', child: Text(l10n.regIncome4)),
                      DropdownMenuItem(
                          value: '100m_150m', child: Text(l10n.regIncome5)),
                      DropdownMenuItem(
                          value: 'over_150m', child: Text(l10n.regIncome6)),
                    ],
                    onChanged: (v) =>
                        setState(() => _annualIncomeRange = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Bio
                _buildField(
                  label: l10n.regBioLabel,
                  child: TextFormField(
                    controller: _bioCtrl,
                    decoration:
                        InputDecoration(hintText: l10n.regBioHint),
                    maxLines: 4,
                    maxLength: 300,
                  ),
                ),

                // Marital history
                _buildField(
                  label: l10n.regMaritalHistoryLabel,
                  child: DropdownButtonFormField<String>(
                    value: _maritalHistory,
                    items: [
                      DropdownMenuItem(
                          value: 'first_marriage',
                          child: Text(l10n.regMaritalFirst)),
                      DropdownMenuItem(
                          value: 'remarriage',
                          child: Text(l10n.regMaritalRemarriage)),
                      DropdownMenuItem(
                          value: 'divorced',
                          child: Text(l10n.regMaritalDivorced)),
                    ],
                    onChanged: (v) =>
                        setState(() => _maritalHistory = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Has children
                _buildField(
                  label: l10n.profileChildren,
                  child: SwitchListTile(
                    value: _hasChildren,
                    onChanged: (v) => setState(() => _hasChildren = v),
                    title: Text(l10n.profileChildren),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                // Children count
                if (_hasChildren)
                  _buildField(
                    label: l10n.profileChildrenCount(0),
                    child: DropdownButtonFormField<int>(
                      value: _childrenCount > 0 ? _childrenCount : null,
                      items: List.generate(
                        10,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}'),
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _childrenCount = v ?? 0),
                      decoration: const InputDecoration(),
                    ),
                  ),

                // Family detail
                _buildField(
                  label: l10n.profileFamilyDetail,
                  child: TextFormField(
                    controller: _familyDetailCtrl,
                    decoration: const InputDecoration(),
                  ),
                ),

                // Parents status
                _buildField(
                  label: l10n.profileParentsStatus,
                  child: DropdownButtonFormField<String>(
                    value: _parentsStatus,
                    items: [
                      DropdownMenuItem(
                          value: 'both_alive',
                          child: Text(l10n.regParentsBothAlive)),
                      DropdownMenuItem(
                          value: 'father_only',
                          child: Text(l10n.regParentsFatherOnly)),
                      DropdownMenuItem(
                          value: 'mother_only',
                          child: Text(l10n.regParentsMotherOnly)),
                      DropdownMenuItem(
                          value: 'deceased',
                          child: Text(l10n.regParentsDeceased)),
                    ],
                    onChanged: (v) =>
                        setState(() => _parentsStatus = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Drinking
                _buildField(
                  label: l10n.profileDrinking,
                  child: DropdownButtonFormField<String>(
                    value: _drinking,
                    items: [
                      DropdownMenuItem(
                          value: 'none',
                          child: Text(l10n.regDrinkingNone)),
                      DropdownMenuItem(
                          value: 'social',
                          child: Text(l10n.regDrinkingSocial)),
                      DropdownMenuItem(
                          value: 'regular',
                          child: Text(l10n.regDrinkingRegular)),
                    ],
                    onChanged: (v) =>
                        setState(() => _drinking = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Smoking
                _buildField(
                  label: l10n.profileSmoking,
                  child: DropdownButtonFormField<String>(
                    value: _smoking,
                    items: [
                      DropdownMenuItem(
                          value: 'none',
                          child: Text(l10n.regSmokingNone)),
                      DropdownMenuItem(
                          value: 'sometimes',
                          child: Text(l10n.regSmokingSometimes)),
                      DropdownMenuItem(
                          value: 'regular',
                          child: Text(l10n.regSmokingRegular)),
                    ],
                    onChanged: (v) =>
                        setState(() => _smoking = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Asset range
                _buildField(
                  label: l10n.profileAssetRange,
                  child: DropdownButtonFormField<String>(
                    value: _assetRange,
                    items: [
                      DropdownMenuItem(
                          value: 'under_100m',
                          child: Text(l10n.regAssetRange1)),
                      DropdownMenuItem(
                          value: '100m_300m',
                          child: Text(l10n.regAssetRange2)),
                      DropdownMenuItem(
                          value: '300m_500m',
                          child: Text(l10n.regAssetRange3)),
                      DropdownMenuItem(
                          value: '500m_1b',
                          child: Text(l10n.regAssetRange4)),
                      DropdownMenuItem(
                          value: 'over_1b',
                          child: Text(l10n.regAssetRange5)),
                    ],
                    onChanged: (v) =>
                        setState(() => _assetRange = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Residence area
                _buildField(
                  label: l10n.profileResidenceArea,
                  child: TextFormField(
                    controller: _residenceAreaCtrl,
                    decoration: const InputDecoration(),
                  ),
                ),

                // Residence type
                _buildField(
                  label: l10n.profileResidenceType,
                  child: DropdownButtonFormField<String>(
                    value: _residenceType,
                    items: [
                      DropdownMenuItem(
                          value: 'own',
                          child: Text(l10n.regResidenceOwn)),
                      DropdownMenuItem(
                          value: 'rent_deposit',
                          child: Text(l10n.regResidenceRentDeposit)),
                      DropdownMenuItem(
                          value: 'rent_monthly',
                          child: Text(l10n.regResidenceRentMonthly)),
                      DropdownMenuItem(
                          value: 'with_parents',
                          child: Text(l10n.regResidenceWithParents)),
                    ],
                    onChanged: (v) =>
                        setState(() => _residenceType = v),
                    decoration: const InputDecoration(),
                  ),
                ),

                // Personality type
                _buildField(
                  label: l10n.profilePersonalityType,
                  child: TextFormField(
                    controller: _personalityTypeCtrl,
                    decoration: const InputDecoration(),
                  ),
                ),

                // Health notes
                _buildField(
                  label: l10n.profileHealthNotes,
                  child: TextFormField(
                    controller: _healthNotesCtrl,
                    decoration: const InputDecoration(),
                  ),
                ),

                // Ideal partner notes
                _buildField(
                  label: l10n.profileIdealNotes,
                  child: TextFormField(
                    controller: _idealNotesCtrl,
                    decoration: const InputDecoration(),
                    maxLines: 3,
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.myClientEditTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.commonError)),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          child,
        ],
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final initial = _birthDate != null
        ? DateTime.tryParse(_birthDate!) ?? DateTime(1990)
        : DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final updates = <String, dynamic>{
      'full_name': _nameCtrl.text.trim(),
      'gender': _gender,
      'birth_date': _birthDate,
      'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      'occupation': _occupationCtrl.text.trim().isEmpty
          ? null
          : _occupationCtrl.text.trim(),
      'company':
          _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      'education_level': _educationLevel,
      'school':
          _schoolCtrl.text.trim().isEmpty ? null : _schoolCtrl.text.trim(),
      'major': _majorCtrl.text.trim().isEmpty ? null : _majorCtrl.text.trim(),
      'height_cm': _heightCm,
      'body_type': _bodyType,
      'religion': _religion,
      'annual_income_range': _annualIncomeRange,
      'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      'marital_history': _maritalHistory,
      'has_children': _hasChildren,
      'children_count': _hasChildren ? _childrenCount : null,
      'family_detail': _familyDetailCtrl.text.trim().isEmpty ? null : _familyDetailCtrl.text.trim(),
      'parents_status': _parentsStatus,
      'drinking': _drinking,
      'smoking': _smoking,
      'asset_range': _assetRange,
      'residence_area': _residenceAreaCtrl.text.trim().isEmpty ? null : _residenceAreaCtrl.text.trim(),
      'residence_type': _residenceType,
      'health_notes': _healthNotesCtrl.text.trim().isEmpty ? null : _healthNotesCtrl.text.trim(),
      'personality_type': _personalityTypeCtrl.text.trim().isEmpty ? null : _personalityTypeCtrl.text.trim(),
      'ideal_notes': _idealNotesCtrl.text.trim().isEmpty ? null : _idealNotesCtrl.text.trim(),
    };

    try {
      await ref.read(
        updateClientProvider(widget.clientId, updates).future,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.myClientEditSaved)),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.myClientEditFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
