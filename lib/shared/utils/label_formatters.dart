import '../../l10n/app_localizations.dart';

/// Converts income range DB code to localized label.
String incomeLabel(String val, AppLocalizations l10n) {
  return switch (val) {
    'under_30m' => l10n.regIncome1,
    '30m_50m' => l10n.regIncome2,
    '50m_70m' => l10n.regIncome3,
    '70m_100m' => l10n.regIncome4,
    '100m_150m' => l10n.regIncome5,
    'over_150m' => l10n.regIncome6,
    _ => val,
  };
}
