import 'package:flutter/foundation.dart';

@immutable
class ClientSummary {
  const ClientSummary({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.birthYear,
    required this.occupation,
    this.company,
    this.education,
    this.heightCm,
    this.isVerified = false,
    this.matchStatus,
    this.profilePhotoUrl,
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
  final String? matchStatus;
  final String? profilePhotoUrl;

  int get age => DateTime.now().year - birthYear;
}
