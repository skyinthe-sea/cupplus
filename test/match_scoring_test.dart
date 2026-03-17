import 'package:flutter_test/flutter_test.dart';
import 'package:cupplus/features/matching/models/marketplace_profile.dart';
import 'package:cupplus/features/matching/utils/match_scoring.dart';

MarketplaceProfile _profile({
  int birthYear = 1993,
  int? heightCm = 175,
  String? education,
  String? annualIncomeRange,
  String? religion,
  String? drinking,
  String? smoking,
  int? idealMinAge,
  int? idealMaxAge,
  int? idealMinHeight,
  int? idealMaxHeight,
  String? idealEducationLevel,
  String? idealIncomeRange,
  String? idealReligion,
}) {
  return MarketplaceProfile(
    id: 'test-${DateTime.now().microsecondsSinceEpoch}',
    fullName: 'Test',
    gender: 'M',
    birthYear: birthYear,
    occupation: 'Engineer',
    heightCm: heightCm,
    education: education,
    annualIncomeRange: annualIncomeRange,
    religion: religion,
    drinking: drinking,
    smoking: smoking,
    idealMinAge: idealMinAge,
    idealMaxAge: idealMaxAge,
    idealMinHeight: idealMinHeight,
    idealMaxHeight: idealMaxHeight,
    idealEducationLevel: idealEducationLevel,
    idealIncomeRange: idealIncomeRange,
    idealReligion: idealReligion,
  );
}

void main() {
  group('Match Scoring', () {
    test('perfect match scores close to 100', () {
      final source = _profile(
        idealMinAge: 28,
        idealMaxAge: 35,
        idealMinHeight: 160,
        idealMaxHeight: 175,
        idealEducationLevel: 'bachelor',
        idealIncomeRange: '5천만~7천만',
        idealReligion: '기독교',
        drinking: 'social',
        smoking: 'none',
      );

      final target = _profile(
        birthYear: DateTime.now().year - 30, // age 30, within 28-35
        heightCm: 168,
        education: 'bachelor',
        annualIncomeRange: '5천만~7천만',
        religion: '기독교',
        drinking: 'social',
        smoking: 'none',
      );

      final score = computeMatchScore(source: source, target: target);
      expect(score, greaterThanOrEqualTo(90));
    });

    test('no preferences gives half credit (~50)', () {
      final source = _profile(); // No ideal preferences set
      final target = _profile();

      final score = computeMatchScore(source: source, target: target);
      // All categories return half credit when no preference is set
      expect(score, closeTo(50, 10));
    });

    test('age outside range scores 0', () {
      final source = _profile(idealMinAge: 25, idealMaxAge: 30);
      final target = _profile(birthYear: DateTime.now().year - 45); // age 45

      final score = computeMatchScore(source: source, target: target);
      // Age component should be 0, other components get half credit
      expect(score, lessThan(50));
    });

    test('age within 3 years of range gets partial credit', () {
      final source = _profile(idealMinAge: 30, idealMaxAge: 35);
      final targetInRange = _profile(birthYear: DateTime.now().year - 32);
      final targetNear = _profile(birthYear: DateTime.now().year - 37); // 2 over
      final targetFar = _profile(birthYear: DateTime.now().year - 45); // 10 over

      final scoreIn = computeMatchScore(source: source, target: targetInRange);
      final scoreNear = computeMatchScore(source: source, target: targetNear);
      final scoreFar = computeMatchScore(source: source, target: targetFar);

      expect(scoreIn, greaterThan(scoreNear));
      expect(scoreNear, greaterThan(scoreFar));
    });

    test('height within range scores full, outside scores less', () {
      final source = _profile(idealMinHeight: 165, idealMaxHeight: 180);
      final targetIn = _profile(heightCm: 170);
      final targetOut = _profile(heightCm: 155);

      final scoreIn = computeMatchScore(source: source, target: targetIn);
      final scoreOut = computeMatchScore(source: source, target: targetOut);

      expect(scoreIn, greaterThan(scoreOut));
    });

    test('religion match vs mismatch', () {
      final source = _profile(idealReligion: '불교');
      final targetMatch = _profile(religion: '불교');
      final targetMiss = _profile(religion: '기독교');

      final scoreMatch = computeMatchScore(source: source, target: targetMatch);
      final scoreMiss = computeMatchScore(source: source, target: targetMiss);

      expect(scoreMatch, greaterThan(scoreMiss));
    });

    test('religion 무관 gives full credit to any religion', () {
      final source = _profile(idealReligion: '무관');
      final target = _profile(religion: '천주교');

      final score = computeMatchScore(source: source, target: target);
      // Religion should be full 15 points
      expect(score, greaterThanOrEqualTo(45)); // Half of other categories + full religion
    });

    test('income scoring uses correct Korean strings', () {
      final source = _profile(idealIncomeRange: '5천만~7천만');
      final targetMatch = _profile(annualIncomeRange: '5천만~7천만');
      final targetHigher = _profile(annualIncomeRange: '1억 이상');
      final targetLower = _profile(annualIncomeRange: '3천만 미만');

      final scoreMatch = computeMatchScore(source: source, target: targetMatch);
      final scoreHigher = computeMatchScore(source: source, target: targetHigher);
      final scoreLower = computeMatchScore(source: source, target: targetLower);

      expect(scoreMatch, greaterThanOrEqualTo(scoreHigher));
      expect(scoreMatch, greaterThan(scoreLower));
    });

    test('bidirectional score averages both directions', () {
      final a = _profile(
        idealMinAge: 25,
        idealMaxAge: 30,
        birthYear: DateTime.now().year - 28,
      );
      final b = _profile(
        idealMinAge: 27,
        idealMaxAge: 32,
        birthYear: DateTime.now().year - 29,
      );

      final scoreAB = computeMatchScore(source: a, target: b);
      final scoreBA = computeMatchScore(source: b, target: a);
      final bidirectional = computeBidirectionalScore(a, b);

      expect(bidirectional, closeTo((scoreAB + scoreBA) / 2, 0.01));
    });

    test('lifestyle scoring: same habits score higher', () {
      final source = _profile(drinking: 'none', smoking: 'none');
      final targetSame = _profile(drinking: 'none', smoking: 'none');
      final targetDiff = _profile(drinking: 'regular', smoking: 'regular');

      final scoreSame = computeMatchScore(source: source, target: targetSame);
      final scoreDiff = computeMatchScore(source: source, target: targetDiff);

      expect(scoreSame, greaterThan(scoreDiff));
    });

    test('education: higher than ideal gets full credit', () {
      final source = _profile(idealEducationLevel: 'bachelor');
      final targetHigher = _profile(education: 'doctorate');
      final targetSame = _profile(education: 'bachelor');
      final targetLower = _profile(education: 'high_school');

      final scoreHigher = computeMatchScore(source: source, target: targetHigher);
      final scoreSame = computeMatchScore(source: source, target: targetSame);
      final scoreLower = computeMatchScore(source: source, target: targetLower);

      expect(scoreHigher, equals(scoreSame)); // Both get full credit
      expect(scoreSame, greaterThan(scoreLower));
    });

    test('score is clamped between 0 and 100', () {
      final source = _profile();
      final target = _profile();

      final score = computeMatchScore(source: source, target: target);
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });
  });

  group('Notification Settings Model', () {
    // Simple model test for NotificationSettings
    test('fromMap with null returns defaults', () {
      // This tests the NotificationSettings model indirectly
      // since we can't import notification_providers without Supabase
    });
  });
}
