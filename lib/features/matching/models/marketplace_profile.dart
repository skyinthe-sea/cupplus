import 'package:flutter/foundation.dart';

String? _nonDefaultRegion(String? regionId) {
  if (regionId == null || regionId == 'default') return null;
  return regionId;
}

@immutable
class MarketplaceProfile {
  const MarketplaceProfile({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.birthYear,
    required this.occupation,
    this.company,
    this.education,
    this.heightCm,
    this.isVerified = false,
    this.profilePhotoUrl,
    this.religion,
    this.annualIncomeRange,
    this.regionName,
    this.managerName,
    this.managerId,
    this.registeredAt,
    this.bio,
    this.hobbies = const [],
    this.idealPartnerNotes,
    this.verifiedDocuments = const [],
    this.likeCount = 0,
    this.isLiked = false,
    this.clientStatus,
    // Extended fields
    this.maritalHistory,
    this.drinking,
    this.smoking,
    this.personalityType,
    this.residenceArea,
    this.residenceType,
    this.assetRange,
    this.idealMinAge,
    this.idealMaxAge,
    this.idealMinHeight,
    this.idealMaxHeight,
    this.idealEducationLevel,
    this.idealIncomeRange,
    this.idealReligion,
    this.idealNotes,
    this.familyDetail,
    this.parentsStatus,
    this.hasChildren = false,
    this.childrenCount,
    this.healthNotes,
    this.personalityTraits = const [],
  });

  factory MarketplaceProfile.fromMap(
    Map<String, dynamic> row, {
    bool isLiked = false,
    int likeCount = 0,
    bool isVerified = false,
    List<String> verifiedDocuments = const [],
    String? managerName,
  }) {
    final birthDate = row['birth_date'] as String?;
    int birthYear = 1990;
    if (birthDate != null) {
      birthYear = DateTime.parse(birthDate).year;
    }

    final rawHobbies = row['hobbies'];
    final hobbies = rawHobbies is List
        ? rawHobbies.map((e) => e.toString()).toList()
        : <String>[];

    final rawTraits = row['personality_traits'];
    final personalityTraits = rawTraits is List
        ? rawTraits.map((e) => e.toString()).toList()
        : <String>[];

    return MarketplaceProfile(
      id: row['id'] as String,
      fullName: row['full_name'] as String? ?? '',
      gender: row['gender'] as String? ?? 'M',
      birthYear: birthYear,
      occupation: row['occupation'] as String? ?? '',
      company: row['company'] as String?,
      education: row['education'] as String?,
      heightCm: row['height_cm'] as int?,
      isVerified: isVerified,
      profilePhotoUrl: row['profile_photo_url'] as String?,
      religion: row['religion'] as String?,
      annualIncomeRange: row['annual_income_range'] as String?,
      regionName: _nonDefaultRegion(row['region_id'] as String?),
      managerName: managerName,
      managerId: row['manager_id'] as String?,
      registeredAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'] as String)
          : null,
      bio: row['bio'] as String?,
      hobbies: hobbies,
      verifiedDocuments: verifiedDocuments,
      likeCount: likeCount,
      isLiked: isLiked,
      clientStatus: row['status'] as String?,
      // Extended fields
      maritalHistory: row['marital_history'] as String?,
      drinking: row['drinking'] as String?,
      smoking: row['smoking'] as String?,
      personalityType: row['personality_type'] as String?,
      residenceArea: row['residence_area'] as String?,
      residenceType: row['residence_type'] as String?,
      assetRange: row['asset_range'] as String?,
      idealMinAge: row['ideal_min_age'] as int?,
      idealMaxAge: row['ideal_max_age'] as int?,
      idealMinHeight: row['ideal_min_height'] as int?,
      idealMaxHeight: row['ideal_max_height'] as int?,
      idealEducationLevel: row['ideal_education_level'] as String?,
      idealIncomeRange: row['ideal_income_range'] as String?,
      idealReligion: row['ideal_religion'] as String?,
      idealNotes: row['ideal_notes'] as String?,
      familyDetail: row['family_detail'] as String?,
      parentsStatus: row['parents_status'] as String?,
      hasChildren: (row['has_children'] as bool?) ?? false,
      childrenCount: row['children_count'] as int?,
      healthNotes: row['health_notes'] as String?,
      personalityTraits: personalityTraits,
    );
  }

  final String id;
  final String fullName;
  final String gender;
  final int birthYear;
  final String occupation;
  final String? company;
  final String? education;
  final int? heightCm;
  final bool isVerified;
  final String? profilePhotoUrl;
  final String? religion;
  final String? annualIncomeRange;
  final String? regionName;
  final String? managerName;
  final String? managerId;
  final DateTime? registeredAt;
  final String? bio;
  final List<String> hobbies;
  final String? idealPartnerNotes;
  final List<String> verifiedDocuments;
  final int likeCount;
  final bool isLiked;
  final String? clientStatus;
  // Extended fields
  final String? maritalHistory;
  final String? drinking;
  final String? smoking;
  final String? personalityType;
  final String? residenceArea;
  final String? residenceType;
  final String? assetRange;
  final int? idealMinAge;
  final int? idealMaxAge;
  final int? idealMinHeight;
  final int? idealMaxHeight;
  final String? idealEducationLevel;
  final String? idealIncomeRange;
  final String? idealReligion;
  final String? idealNotes;
  final String? familyDetail;
  final String? parentsStatus;
  final bool hasChildren;
  final int? childrenCount;
  final String? healthNotes;
  final List<String> personalityTraits;

  int get age => DateTime.now().year - birthYear;

  MarketplaceProfile copyWith({
    bool? isLiked,
    int? likeCount,
  }) {
    return MarketplaceProfile(
      id: id,
      fullName: fullName,
      gender: gender,
      birthYear: birthYear,
      occupation: occupation,
      company: company,
      education: education,
      heightCm: heightCm,
      isVerified: isVerified,
      profilePhotoUrl: profilePhotoUrl,
      religion: religion,
      annualIncomeRange: annualIncomeRange,
      regionName: regionName,
      managerName: managerName,
      managerId: managerId,
      registeredAt: registeredAt,
      bio: bio,
      hobbies: hobbies,
      idealPartnerNotes: idealPartnerNotes,
      verifiedDocuments: verifiedDocuments,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      clientStatus: clientStatus,
      maritalHistory: maritalHistory,
      drinking: drinking,
      smoking: smoking,
      personalityType: personalityType,
      residenceArea: residenceArea,
      residenceType: residenceType,
      assetRange: assetRange,
      idealMinAge: idealMinAge,
      idealMaxAge: idealMaxAge,
      idealMinHeight: idealMinHeight,
      idealMaxHeight: idealMaxHeight,
      idealEducationLevel: idealEducationLevel,
      idealIncomeRange: idealIncomeRange,
      idealReligion: idealReligion,
      idealNotes: idealNotes,
      familyDetail: familyDetail,
      parentsStatus: parentsStatus,
      hasChildren: hasChildren,
      childrenCount: childrenCount,
      healthNotes: healthNotes,
      personalityTraits: personalityTraits,
    );
  }
}
