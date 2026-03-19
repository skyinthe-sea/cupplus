import '../../l10n/app_localizations.dart';

/// Converts income range DB code to localized label.
String incomeLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    // Current format
    'under_30m' => l10n.regIncome1,
    '30m_50m' => l10n.regIncome2,
    '50m_70m' => l10n.regIncome3,
    '70m_100m' => l10n.regIncome4,
    '100m_150m' => l10n.regIncome5,
    'over_150m' => l10n.regIncome6,
    // Legacy numeric format (만원 단위)
    'under_3000' => l10n.regIncome1,
    '3000_5000' => l10n.regIncome2,
    '5000_7000' => l10n.regIncome3,
    '7000_10000' => l10n.regIncome4,
    '10000_15000' => l10n.regIncome5,
    'over_15000' || '15000_plus' || '15000_Plus' => l10n.regIncome6,
    _ => _formatRangeFallback(val, '만원'),
  };
}

/// Converts asset range DB code to localized label.
String assetLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    // Current format
    'under_100m' => l10n.regAssetRange1,
    '100m_300m' => l10n.regAssetRange2,
    '300m_500m' => l10n.regAssetRange3,
    '500m_1b' => l10n.regAssetRange4,
    'over_1b' => l10n.regAssetRange5,
    // Legacy numeric format (백만원 단위)
    'under_100' => l10n.regAssetRange1,
    '100_300' => l10n.regAssetRange2,
    '300_500' => l10n.regAssetRange3,
    '500_1000' => l10n.regAssetRange4,
    'over_1000' || '1000_plus' || '1000_Plus' => l10n.regAssetRange5,
    _ => _formatRangeFallback(val, ''),
  };
}

/// Converts education level DB code to localized label.
String educationLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'high_school' => l10n.regEduHighSchool,
    'associate' => l10n.regEduAssociate,
    'bachelor' => l10n.regEduBachelor,
    'master' => l10n.regEduMaster,
    'doctorate' => l10n.regEduDoctorate,
    _ => val,
  };
}

/// Converts body type DB code to localized label.
String bodyTypeLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'slim' => l10n.regBodySlim,
    'slightly_slim' => l10n.regBodySlightlySlim,
    'average' => l10n.regBodyAverage,
    'slightly_chubby' => l10n.regBodySlightlyChubby,
    'chubby' => l10n.regBodyChubby,
    _ => val,
  };
}

/// Converts drinking DB code to localized label.
String drinkingLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'none' => l10n.regDrinkingNone,
    'social' => l10n.regDrinkingSocial,
    'regular' => l10n.regDrinkingRegular,
    _ => val,
  };
}

/// Converts smoking DB code to localized label.
String smokingLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'none' => l10n.regSmokingNone,
    'sometimes' => l10n.regSmokingSometimes,
    'regular' => l10n.regSmokingRegular,
    _ => val,
  };
}

/// Converts marital history DB code to localized label.
String maritalLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'first_marriage' => l10n.regMaritalFirst,
    'remarriage' => l10n.regMaritalRemarriage,
    'divorced' => l10n.regMaritalDivorced,
    _ => val,
  };
}

/// Converts religion DB code to localized label.
String religionLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'none' => l10n.regReligionNone,
    'christian' => l10n.regReligionChristian,
    'catholic' => l10n.regReligionCatholic,
    'buddhist' => l10n.regReligionBuddhist,
    'other' => l10n.regReligionOther,
    _ => val,
  };
}

/// Converts parents status DB code to localized label.
String parentsLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'both_alive' => l10n.regParentsBothAlive,
    'father_only' => l10n.regParentsFatherOnly,
    'mother_only' => l10n.regParentsMotherOnly,
    'deceased' => l10n.regParentsDeceased,
    _ => val,
  };
}

/// Best-effort formatting for unknown range values like "5000_7000".
/// Handles: "under_X", "over_X", "X_plus"/"X_Plus", "X_Y" numeric pairs.
String _formatRangeFallback(String val, String unit) {
  final lower = val.toLowerCase();

  if (lower.startsWith('under_')) {
    final num = val.substring(6);
    final formatted = _formatNumber(num);
    if (formatted != null) return '$formatted$unit 미만';
  }
  if (lower.startsWith('over_')) {
    final num = val.substring(5);
    final formatted = _formatNumber(num);
    if (formatted != null) return '$formatted$unit 이상';
  }

  // "1000_plus" / "1000_Plus" → "1,000 이상"
  if (lower.endsWith('_plus')) {
    final num = val.substring(0, val.length - 5);
    final formatted = _formatNumber(num);
    if (formatted != null) return '$formatted$unit 이상';
  }

  // "5000_7000" → "5,000~7,000"
  final parts = val.split('_');
  if (parts.length == 2) {
    final a = _formatNumber(parts[0]);
    final b = _formatNumber(parts[1]);
    if (a != null && b != null) return '$a~$b$unit';
  }

  // Give up — return as-is
  return val;
}

/// Tries to parse and comma-format a numeric string.
String? _formatNumber(String s) {
  final n = int.tryParse(s);
  if (n == null) return null;
  final str = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
    buf.write(str[i]);
  }
  return buf.toString();
}
