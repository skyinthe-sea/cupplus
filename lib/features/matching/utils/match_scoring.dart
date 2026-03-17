import '../models/marketplace_profile.dart';

/// Computes a compatibility score (0–100) between a source client and a
/// target marketplace profile based on the source's ideal partner preferences.
///
/// Scoring weights:
///   Age range match:     25 points
///   Height range match:  15 points
///   Education level:     15 points
///   Income range:        15 points
///   Religion:            15 points
///   Lifestyle match:     15 points (drinking + smoking)
double computeMatchScore({
  required MarketplaceProfile source,
  required MarketplaceProfile target,
}) {
  double score = 0;

  // 1. Age match (25 pts)
  score += _scoreAge(source, target);

  // 2. Height match (15 pts)
  score += _scoreHeight(source, target);

  // 3. Education level (15 pts)
  score += _scoreEducation(source, target);

  // 4. Income range (15 pts)
  score += _scoreIncome(source, target);

  // 5. Religion (15 pts)
  score += _scoreReligion(source, target);

  // 6. Lifestyle — drinking + smoking (15 pts)
  score += _scoreLifestyle(source, target);

  return score.clamp(0, 100);
}

/// Bidirectional score: average of A→B and B→A compatibility
double computeBidirectionalScore(MarketplaceProfile a, MarketplaceProfile b) {
  final scoreAB = computeMatchScore(source: a, target: b);
  final scoreBA = computeMatchScore(source: b, target: a);
  return (scoreAB + scoreBA) / 2;
}

// ─── Age (25 pts) ─────────────────────────────────────────────

double _scoreAge(MarketplaceProfile source, MarketplaceProfile target) {
  final minAge = source.idealMinAge;
  final maxAge = source.idealMaxAge;
  if (minAge == null && maxAge == null) return 12.5; // No preference → half credit

  final targetAge = target.age;
  final min = minAge ?? 20;
  final max = maxAge ?? 60;

  if (targetAge >= min && targetAge <= max) return 25;

  // Partial credit: within 3 years of range
  final distance = targetAge < min ? min - targetAge : targetAge - max;
  if (distance <= 3) return 25 * (1 - distance / 6);

  return 0;
}

// ─── Height (15 pts) ──────────────────────────────────────────

double _scoreHeight(MarketplaceProfile source, MarketplaceProfile target) {
  final minH = source.idealMinHeight;
  final maxH = source.idealMaxHeight;
  if (minH == null && maxH == null) return 7.5;

  final targetH = target.heightCm;
  if (targetH == null) return 7.5;

  final min = minH ?? 140;
  final max = maxH ?? 200;

  if (targetH >= min && targetH <= max) return 15;

  final distance = targetH < min ? min - targetH : targetH - max;
  if (distance <= 5) return 15 * (1 - distance / 10);

  return 0;
}

// ─── Education (15 pts) ───────────────────────────────────────

const _educationRank = {
  'high_school': 1,
  'associate': 2,
  'bachelor': 3,
  'master': 4,
  'doctorate': 5,
};

double _scoreEducation(MarketplaceProfile source, MarketplaceProfile target) {
  final idealLevel = source.idealEducationLevel;
  if (idealLevel == null) return 7.5;

  final targetEdu = target.education?.toLowerCase();
  if (targetEdu == null) return 7.5;

  final idealRank = _educationRank[idealLevel] ?? 3;

  // Try matching both education and education_level fields
  final targetRank = _educationRank[targetEdu] ??
      _inferEducationRank(targetEdu);

  if (targetRank >= idealRank) return 15;
  if (targetRank == idealRank - 1) return 10;
  return 3;
}

int _inferEducationRank(String edu) {
  final lower = edu.toLowerCase();
  if (lower.contains('박사') || lower.contains('doctor')) return 5;
  if (lower.contains('석사') || lower.contains('master') || lower.contains('대학원')) return 4;
  if (lower.contains('학사') || lower.contains('bachelor') || lower.contains('대학') || lower.contains('대졸')) return 3;
  if (lower.contains('전문대') || lower.contains('associate')) return 2;
  return 1;
}

// ─── Income (15 pts) ──────────────────────────────────────────

const _incomeRank = {
  '3천만 미만': 1,
  '3천만~5천만': 2,
  '5천만~7천만': 3,
  '7천만~1억': 4,
  '1억 이상': 5,
};

double _scoreIncome(MarketplaceProfile source, MarketplaceProfile target) {
  final idealIncome = source.idealIncomeRange;
  if (idealIncome == null) return 7.5;

  final targetIncome = target.annualIncomeRange;
  if (targetIncome == null) return 7.5;

  final idealRank = _incomeRank[idealIncome] ?? 3;
  final targetRank = _incomeRank[targetIncome] ?? 3;

  if (targetRank >= idealRank) return 15;
  if (targetRank == idealRank - 1) return 8;
  return 2;
}

// ─── Religion (15 pts) ────────────────────────────────────────

double _scoreReligion(MarketplaceProfile source, MarketplaceProfile target) {
  final idealReligion = source.idealReligion;
  if (idealReligion == null || idealReligion.isEmpty) return 7.5;

  final targetReligion = target.religion;
  if (targetReligion == null || targetReligion.isEmpty) return 5;

  if (idealReligion == '무관') return 15;
  return idealReligion == targetReligion ? 15 : 0;
}

// ─── Lifestyle (15 pts) ───────────────────────────────────────

double _scoreLifestyle(MarketplaceProfile source, MarketplaceProfile target) {
  double pts = 0;

  // Drinking (7.5 pts)
  final srcDrink = source.drinking;
  final tgtDrink = target.drinking;
  if (srcDrink == null || tgtDrink == null) {
    pts += 3.75;
  } else if (srcDrink == tgtDrink) {
    pts += 7.5;
  } else if ((srcDrink == 'social' && tgtDrink != 'regular') ||
      (tgtDrink == 'social' && srcDrink != 'regular')) {
    pts += 5;
  }

  // Smoking (7.5 pts)
  final srcSmoke = source.smoking;
  final tgtSmoke = target.smoking;
  if (srcSmoke == null || tgtSmoke == null) {
    pts += 3.75;
  } else if (srcSmoke == tgtSmoke) {
    pts += 7.5;
  } else if (srcSmoke == 'none' && tgtSmoke != 'none') {
    pts += 0; // Non-smoker prefers non-smoker
  } else {
    pts += 3;
  }

  return pts;
}
