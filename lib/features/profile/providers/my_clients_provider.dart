import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';
import '../../../shared/models/client_summary.dart';

part 'my_clients_provider.g.dart';

/// Full client detail from DB
class ClientDetail {
  const ClientDetail({
    required this.id,
    required this.fullName,
    required this.gender,
    this.birthDate,
    this.phone,
    this.email,
    this.occupation,
    this.company,
    this.education,
    this.educationLevel,
    this.school,
    this.major,
    this.heightCm,
    this.bodyType,
    this.religion,
    this.annualIncomeRange,
    this.profilePhotoUrl,
    this.bio,
    this.hobbies = const [],
    this.status = 'active',
    this.createdAt,
    this.matchHistory = const [],
    // Family
    this.maritalHistory,
    this.hasChildren = false,
    this.childrenCount,
    this.familyDetail,
    this.parentsStatus,
    // Lifestyle
    this.drinking,
    this.smoking,
    this.healthNotes,
    // Personality
    this.personalityType,
    this.personalityTraits = const [],
    // Ideal partner
    this.idealMinAge,
    this.idealMaxAge,
    this.idealMinHeight,
    this.idealMaxHeight,
    this.idealEducationLevel,
    this.idealIncomeRange,
    this.idealReligion,
    this.idealNotes,
    // Assets / Residence
    this.assetRange,
    this.residenceArea,
    this.residenceType,
  });

  factory ClientDetail.fromMap(
    Map<String, dynamic> row, {
    List<Map<String, dynamic>> matchHistory = const [],
  }) {
    final rawHobbies = row['hobbies'];
    final hobbies = rawHobbies is List
        ? rawHobbies.map((e) => e.toString()).toList()
        : <String>[];

    final rawTraits = row['personality_traits'];
    final traits = rawTraits is List
        ? rawTraits.map((e) => e.toString()).toList()
        : <String>[];

    return ClientDetail(
      id: row['id'] as String,
      fullName: row['full_name'] as String? ?? '',
      gender: row['gender'] as String? ?? 'M',
      birthDate: row['birth_date'] as String?,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      occupation: row['occupation'] as String?,
      company: row['company'] as String?,
      education: row['education'] as String?,
      educationLevel: row['education_level'] as String?,
      school: row['school'] as String?,
      major: row['major'] as String?,
      heightCm: row['height_cm'] as int?,
      bodyType: row['body_type'] as String?,
      religion: row['religion'] as String?,
      annualIncomeRange: row['annual_income_range'] as String?,
      profilePhotoUrl: row['profile_photo_url'] as String?,
      bio: row['bio'] as String?,
      hobbies: hobbies,
      status: row['status'] as String? ?? 'active',
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'] as String)
          : null,
      matchHistory: matchHistory,
      // Family
      maritalHistory: row['marital_history'] as String?,
      hasChildren: (row['has_children'] as bool?) ?? false,
      childrenCount: row['children_count'] as int?,
      familyDetail: row['family_detail'] as String?,
      parentsStatus: row['parents_status'] as String?,
      // Lifestyle
      drinking: row['drinking'] as String?,
      smoking: row['smoking'] as String?,
      healthNotes: row['health_notes'] as String?,
      // Personality
      personalityType: row['personality_type'] as String?,
      personalityTraits: traits,
      // Ideal partner
      idealMinAge: row['ideal_min_age'] as int?,
      idealMaxAge: row['ideal_max_age'] as int?,
      idealMinHeight: row['ideal_min_height'] as int?,
      idealMaxHeight: row['ideal_max_height'] as int?,
      idealEducationLevel: row['ideal_education_level'] as String?,
      idealIncomeRange: row['ideal_income_range'] as String?,
      idealReligion: row['ideal_religion'] as String?,
      idealNotes: row['ideal_notes'] as String?,
      // Assets / Residence
      assetRange: row['asset_range'] as String?,
      residenceArea: row['residence_area'] as String?,
      residenceType: row['residence_type'] as String?,
    );
  }

  final String id;
  final String fullName;
  final String gender;
  final String? birthDate;
  final String? phone;
  final String? email;
  final String? occupation;
  final String? company;
  final String? education;
  final String? educationLevel;
  final String? school;
  final String? major;
  final int? heightCm;
  final String? bodyType;
  final String? religion;
  final String? annualIncomeRange;
  final String? profilePhotoUrl;
  final String? bio;
  final List<String> hobbies;
  final String status;
  final DateTime? createdAt;
  final List<Map<String, dynamic>> matchHistory;
  // Family
  final String? maritalHistory;
  final bool hasChildren;
  final int? childrenCount;
  final String? familyDetail;
  final String? parentsStatus;
  // Lifestyle
  final String? drinking;
  final String? smoking;
  final String? healthNotes;
  // Personality
  final String? personalityType;
  final List<String> personalityTraits;
  // Ideal partner
  final int? idealMinAge;
  final int? idealMaxAge;
  final int? idealMinHeight;
  final int? idealMaxHeight;
  final String? idealEducationLevel;
  final String? idealIncomeRange;
  final String? idealReligion;
  final String? idealNotes;
  // Assets / Residence
  final String? assetRange;
  final String? residenceArea;
  final String? residenceType;

  int? get birthYear {
    if (birthDate == null) return null;
    return DateTime.tryParse(birthDate!)?.year;
  }

  int? get age {
    final y = birthYear;
    if (y == null) return null;
    return DateTime.now().year - y;
  }
}

@riverpod
Future<List<ClientSummary>> myClients(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final result = await client
      .from('clients')
      .select()
      .eq('manager_id', user.id)
      .neq('status', 'withdrawn')
      .order('created_at', ascending: false);

  return result.map((row) {
    final birthDate = row['birth_date'] as String?;
    int birthYear = 1990;
    if (birthDate != null) {
      birthYear = DateTime.parse(birthDate).year;
    }

    return ClientSummary(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      gender: row['gender'] as String,
      birthYear: birthYear,
      occupation: row['occupation'] as String? ?? '',
      company: row['company'] as String?,
      education: row['education'] as String?,
      heightCm: row['height_cm'] as int?,
      profilePhotoUrl: row['profile_photo_url'] as String?,
      matchStatus: row['status'] as String?,
    );
  }).toList();
}

@riverpod
Future<ClientDetail?> myClientDetail(Ref ref, String clientId) async {
  final client = ref.watch(supabaseClientProvider);

  final result = await client
      .from('clients')
      .select()
      .eq('id', clientId)
      .maybeSingle();

  if (result == null) return null;

  // Fetch match history
  final matches = await client
      .from('matches')
      .select()
      .or('client_a_id.eq.$clientId,client_b_id.eq.$clientId')
      .order('matched_at', ascending: false)
      .limit(20);

  // Fetch counterpart client names
  final counterpartIds = <String>{};
  for (final m in matches) {
    final aId = m['client_a_id'] as String;
    final bId = m['client_b_id'] as String;
    counterpartIds.add(aId == clientId ? bId : aId);
  }

  final nameMap = <String, String>{};
  if (counterpartIds.isNotEmpty) {
    final names = await client
        .from('clients')
        .select('id, full_name')
        .inFilter('id', counterpartIds.toList());
    for (final n in names) {
      nameMap[n['id'] as String] = n['full_name'] as String;
    }
  }

  final enrichedMatches = matches.map((m) {
    final aId = m['client_a_id'] as String;
    final bId = m['client_b_id'] as String;
    final counterpartId = aId == clientId ? bId : aId;
    return {
      ...m,
      'counterpart_name': nameMap[counterpartId] ?? '?',
    };
  }).toList();

  return ClientDetail.fromMap(result, matchHistory: enrichedMatches);
}

@riverpod
Future<void> updateClientStatus(
  Ref ref,
  String clientId,
  String newStatus,
) async {
  final client = ref.read(supabaseClientProvider);

  await client
      .from('clients')
      .update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', clientId);

  ref.invalidate(myClientsProvider);
  ref.invalidate(myClientDetailProvider(clientId));
}

@riverpod
Future<void> updateClient(
  Ref ref,
  String clientId,
  Map<String, dynamic> updates,
) async {
  final client = ref.read(supabaseClientProvider);

  await client
      .from('clients')
      .update({
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', clientId);

  ref.invalidate(myClientsProvider);
  ref.invalidate(myClientDetailProvider(clientId));
}

@riverpod
Future<void> deleteClient(Ref ref, String clientId) async {
  // Soft delete: set status to 'withdrawn'
  // The DB trigger handles side effects (cancel matches, notify, etc.)
  await ref.read(updateClientStatusProvider(clientId, 'withdrawn').future);
}
