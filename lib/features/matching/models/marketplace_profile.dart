import 'package:flutter/foundation.dart';

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
    this.registeredAt,
    this.bio,
    this.hobbies = const [],
    this.idealPartnerNotes,
    this.verifiedDocuments = const [],
    this.matchRequestCount = 0,
  });

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
  final DateTime? registeredAt;
  final String? bio;
  final List<String> hobbies;
  final String? idealPartnerNotes;
  final List<String> verifiedDocuments;
  final int matchRequestCount;

  int get age => DateTime.now().year - birthYear;
}
