import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants.dart';
import '../../../config/supabase_config.dart';
import '../../../shared/models/client_summary.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../models/marketplace_filter.dart';
import '../models/marketplace_profile.dart';
import '../utils/match_scoring.dart';

part 'marketplace_providers.g.dart';

const _pageSize = 20;

@Riverpod(keepAlive: true)
class MarketplaceFilterNotifier extends _$MarketplaceFilterNotifier {
  @override
  MarketplaceFilter build() => const MarketplaceFilter();

  void updateGender(String? gender) {
    state = state.copyWith(gender: () => gender);
  }

  void updateAgeRange(int? min, int? max) {
    state = state.copyWith(
      minAge: () => min,
      maxAge: () => max,
    );
  }

  void updateHeightRange(int? min, int? max) {
    state = state.copyWith(
      minHeight: () => min,
      maxHeight: () => max,
    );
  }

  void updateReligion(String? religion) {
    state = state.copyWith(religion: () => religion);
  }

  void updateVerifiedOnly(bool value) {
    state = state.copyWith(isVerifiedOnly: value);
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: () => query?.isEmpty == true ? null : query,
    );
  }

  void updateEducationLevel(String? level) {
    state = state.copyWith(educationLevel: () => level);
  }

  void updateOccupationCategories(List<String> categories) {
    state = state.copyWith(occupationCategories: categories);
  }

  void updateIncomeRange(String? range) {
    state = state.copyWith(incomeRange: () => range);
  }

  void updateSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void updateDrinking(String? value) {
    state = state.copyWith(drinking: () => value);
  }

  void updateSmoking(String? value) {
    state = state.copyWith(smoking: () => value);
  }

  void updateMaritalHistory(String? value) {
    state = state.copyWith(maritalHistory: () => value);
  }

  void updateResidenceArea(String? value) {
    state = state.copyWith(residenceArea: () => value);
  }

  void clearFilters() {
    state = MarketplaceFilter(searchQuery: state.searchQuery);
  }

  void clearAll() {
    state = const MarketplaceFilter();
  }
}

/// Accumulates paginated profiles for a given gender tab.
/// Manages page state internally and exposes loadMore/refresh.
/// keepAlive: preserves scroll position + loaded data across tab switches.
@Riverpod(keepAlive: true)
class MarketplaceProfileList extends _$MarketplaceProfileList {
  int _currentPage = 0;
  bool _hasMore = true;
  List<MarketplaceProfile>? _cachedMyClients;

  bool get hasMore => _hasMore;

  @override
  Future<List<MarketplaceProfile>> build({String? genderOverride}) async {
    _currentPage = 0;
    _hasMore = true;
    _cachedMyClients = null; // Reset cache on filter change
    // Watch filter changes to refetch from page 0
    ref.watch(marketplaceFilterNotifierProvider);
    return _fetchPage(0, genderOverride: genderOverride);
  }

  Future<List<MarketplaceProfile>> _fetchPage(
    int page, {
    String? genderOverride,
  }) async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return [];

    final filter = ref.read(marketplaceFilterNotifierProvider);

    // Build query
    var query = client
        .from('clients')
        .select()
        .neq('manager_id', user.id)
        .eq('status', 'active');

    // Server-side gender filter: tab override takes priority
    final effectiveGender = genderOverride ?? filter.gender;
    if (effectiveGender != null) {
      query = query.eq('gender', effectiveGender);
    }

    // Age filter using proper date calculation
    if (filter.minAge != null) {
      final now = DateTime.now();
      final cutoff = DateTime(now.year - filter.minAge!, now.month, now.day);
      query = query.lte('birth_date', cutoff.toIso8601String().substring(0, 10));
    }
    if (filter.maxAge != null) {
      final now = DateTime.now();
      final cutoff = DateTime(now.year - filter.maxAge!, now.month, now.day);
      query = query.gte('birth_date', cutoff.toIso8601String().substring(0, 10));
    }

    if (filter.minHeight != null) {
      query = query.gte('height_cm', filter.minHeight!);
    }
    if (filter.maxHeight != null) {
      query = query.lte('height_cm', filter.maxHeight!);
    }

    if (filter.religion != null) {
      query = query.eq('religion', filter.religion!);
    }

    if (filter.incomeRange != null) {
      query = query.eq('annual_income_range', filter.incomeRange!);
    }

    if (filter.drinking != null) {
      query = query.eq('drinking', filter.drinking!);
    }

    if (filter.smoking != null) {
      query = query.eq('smoking', filter.smoking!);
    }

    if (filter.maritalHistory != null) {
      query = query.eq('marital_history', filter.maritalHistory!);
    }

    if (filter.residenceArea != null) {
      final escaped = filter.residenceArea!
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      query = query.ilike('residence_area', '%$escaped%');
    }

    if (filter.searchQuery != null) {
      final escaped = filter.searchQuery!
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      final q = '%$escaped%';
      query = query.or('full_name.ilike.$q,occupation.ilike.$q,company.ilike.$q');
    }

    // Server-side education filter (ILIKE on free text)
    if (filter.educationLevel != null) {
      final escaped = filter.educationLevel!
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      query = query.ilike('education', '%$escaped%');
    }

    // Pagination
    final from = page * _pageSize;
    final to = from + _pageSize - 1;

    // Server-side sort (recommended uses created_at, then re-sorts client-side)
    final sortColumn = filter.sortOrder == SortOrder.mostLikes
        ? 'like_count'
        : 'created_at';
    final rows = await query
        .order(sortColumn, ascending: false)
        .range(from, to);

    if (rows.length < _pageSize) {
      _hasMore = false;
    }

    if (rows.isEmpty) return [];

    // Collect IDs for batch queries
    final clientIds = rows.map((r) => r['id'] as String).toList();
    final managerIds = rows
        .map((r) => r['manager_id'] as String?)
        .where((id) => id != null)
        .cast<String>()
        .toSet()
        .toList();

    // Batch queries in parallel
    final myLikesFuture = client
        .from('profile_likes')
        .select('client_id')
        .eq('manager_id', user.id)
        .inFilter('client_id', clientIds);

    final verifiedCountsFuture = client
        .from('verification_documents')
        .select('client_id')
        .inFilter('client_id', clientIds)
        .eq('status', 'approved');

    final managersFuture = managerIds.isNotEmpty
        ? client
            .from('managers')
            .select('id, full_name')
            .inFilter('id', managerIds)
        : Future.value(<Map<String, dynamic>>[]);

    final results = await Future.wait([
      myLikesFuture,
      verifiedCountsFuture,
      managersFuture,
    ]);

    // My likes set
    final myLikedIds = (results[0] as List<dynamic>)
        .map((r) => r['client_id'] as String)
        .toSet();

    // Verified client IDs
    final verifiedClientIds = (results[1] as List<dynamic>)
        .map((r) => r['client_id'] as String)
        .toSet();

    // Manager name map
    final managerNameMap = <String, String>{};
    for (final m in results[2] as List<dynamic>) {
      managerNameMap[m['id'] as String] = m['full_name'] as String;
    }

    // Build profiles
    var profiles = rows.map((row) {
      final clientId = row['id'] as String;
      final managerId = row['manager_id'] as String?;
      return MarketplaceProfile.fromMap(
        row,
        isLiked: myLikedIds.contains(clientId),
        likeCount: (row['like_count'] as int?) ?? 0,
        isVerified: verifiedClientIds.contains(clientId),
        managerName: managerId != null ? managerNameMap[managerId] : null,
      );
    }).toList();

    // Client-side filters that cannot be done server-side yet
    if (filter.occupationCategories.isNotEmpty) {
      profiles = profiles.where((p) {
        final occ = p.occupation.toLowerCase();
        return filter.occupationCategories
            .any((cat) => occ.contains(cat.toLowerCase()));
      }).toList();
    }

    // isVerifiedOnly: server can't easily filter via join, do it here
    if (filter.isVerifiedOnly) {
      profiles = profiles.where((p) => p.isVerified).toList();
    }

    // Recommended sort: score each profile against my clients' ideal preferences
    if (filter.sortOrder == SortOrder.recommended && profiles.isNotEmpty) {
      _cachedMyClients ??= await _fetchMyClients(client, user.id);
      final myClients = _cachedMyClients!;
      if (myClients.isNotEmpty) {
        profiles.sort((a, b) {
          final scoreA = _bestMatchScore(myClients, a);
          final scoreB = _bestMatchScore(myClients, b);
          return scoreB.compareTo(scoreA);
        });
      }
    }

    return profiles;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final currentState = state;
    if (currentState is! AsyncData<List<MarketplaceProfile>>) return;

    _currentPage++;
    final nextPage = await _fetchPage(
      _currentPage,
      genderOverride: genderOverride,
    );

    state = AsyncData([...currentState.value, ...nextPage]);
  }
}

// ─── Recommendation helpers ──────────────────────────────────

/// Fetch current user's active clients as MarketplaceProfile for scoring
Future<List<MarketplaceProfile>> _fetchMyClients(
  dynamic client,
  String userId,
) async {
  final rows = await client
      .from('clients')
      .select()
      .eq('manager_id', userId)
      .eq('status', 'active')
      .limit(20);

  return (rows as List<dynamic>)
      .map((row) => MarketplaceProfile.fromMap(row as Map<String, dynamic>))
      .toList();
}

/// Returns the best score among all my clients for a given target profile
double _bestMatchScore(
  List<MarketplaceProfile> myClients,
  MarketplaceProfile target,
) {
  double best = 0;
  for (final myClient in myClients) {
    final score = computeMatchScore(source: myClient, target: target);
    if (score > best) best = score;
  }
  return best;
}

@riverpod
Future<List<MarketplaceProfile>> likedProfiles(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  // Get my liked client IDs
  final likes = await client
      .from('profile_likes')
      .select('client_id')
      .eq('manager_id', user.id)
      .order('created_at', ascending: false);

  if (likes.isEmpty) return [];

  final clientIds = likes.map((r) => r['client_id'] as String).toList();

  // Fetch clients (include non-active for dimming)
  final rows = await client
      .from('clients')
      .select()
      .inFilter('id', clientIds);

  if (rows.isEmpty) return [];

  // Manager names
  final managerIds = rows
      .map((r) => r['manager_id'] as String?)
      .where((id) => id != null)
      .cast<String>()
      .toSet()
      .toList();

  // Parallel batch queries
  final managersFuture = managerIds.isNotEmpty
      ? client.from('managers').select('id, full_name').inFilter('id', managerIds)
      : Future.value(<Map<String, dynamic>>[]);
  final verifiedFuture = client
      .from('verification_documents')
      .select('client_id')
      .inFilter('client_id', clientIds)
      .eq('status', 'approved');

  final batchResults = await Future.wait([managersFuture, verifiedFuture]);

  final managerNameMap = <String, String>{};
  for (final m in batchResults[0] as List<dynamic>) {
    managerNameMap[m['id'] as String] = m['full_name'] as String;
  }

  final verifiedIds = (batchResults[1] as List<dynamic>)
      .map((r) => r['client_id'] as String)
      .toSet();

  // Build profiles in liked order
  final rowMap = <String, Map<String, dynamic>>{};
  for (final row in rows) {
    rowMap[row['id'] as String] = row;
  }

  return clientIds
      .where((id) => rowMap.containsKey(id))
      .map((id) {
    final row = rowMap[id]!;
    final managerId = row['manager_id'] as String?;
    return MarketplaceProfile.fromMap(
      row,
      isLiked: true,
      likeCount: (row['like_count'] as int?) ?? 0,
      isVerified: verifiedIds.contains(id),
      managerName: managerId != null ? managerNameMap[managerId] : null,
    );
  }).toList();
}

@riverpod
Future<void> toggleLike(Ref ref, String clientId, {required bool currentlyLiked}) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  if (currentlyLiked) {
    await client
        .from('profile_likes')
        .delete()
        .eq('manager_id', user.id)
        .eq('client_id', clientId);
  } else {
    await client.from('profile_likes').insert({
      'manager_id': user.id,
      'client_id': clientId,
    });
  }

  // Invalidate related providers
  ref.invalidate(marketplaceProfileListProvider);
  ref.invalidate(likedProfilesProvider);
  ref.invalidate(profileCountsProvider);
  ref.invalidate(marketplaceProfileByIdProvider);
}

@riverpod
Future<MarketplaceProfile?> marketplaceProfileById(Ref ref, String id) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  final rows = await client
      .from('clients')
      .select()
      .eq('id', id)
      .limit(1);

  if (rows.isEmpty) return null;
  final row = rows.first;

  // Parallel: my like, verified docs, manager name
  final myLikeFuture = client
      .from('profile_likes')
      .select('id')
      .eq('manager_id', user.id)
      .eq('client_id', id)
      .maybeSingle();

  final verDocsFuture = client
      .from('verification_documents')
      .select('document_type')
      .eq('client_id', id)
      .eq('status', 'approved');

  final managerId = row['manager_id'] as String?;
  final managerFuture = managerId != null
      ? client.from('managers').select('full_name').eq('id', managerId).limit(1)
      : Future.value(<Map<String, dynamic>>[]);

  final listResults = await Future.wait([verDocsFuture, managerFuture]);
  final myLike = await myLikeFuture;

  final verDocs = listResults[0];
  final mgrRows = listResults[1];

  final docTypeNames = {
    'business_card': '명함',
    'employment_cert': '재직증명서',
    'degree_cert': '학위증명서',
    'income_cert': '소득증명서',
  };

  final verifiedDocuments = verDocs
      .map((d) => docTypeNames[d['document_type'] as String] ?? d['document_type'] as String)
      .toList();

  String? managerName;
  if (mgrRows.isNotEmpty) {
    managerName = mgrRows.first['full_name'] as String;
  }

  return MarketplaceProfile.fromMap(
    row,
    isLiked: myLike != null,
    likeCount: (row['like_count'] as int?) ?? 0,
    isVerified: verifiedDocuments.isNotEmpty,
    verifiedDocuments: verifiedDocuments,
    managerName: managerName,
  );
}

@riverpod
Future<List<ClientSummary>> myEligibleClients(Ref ref, String targetGender) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final oppositeGender = targetGender == 'M' ? 'F' : 'M';

  final rows = await client
      .from('clients')
      .select()
      .eq('manager_id', user.id)
      .eq('gender', oppositeGender)
      .eq('status', 'active')
      .order('full_name');

  return rows.map((row) {
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
    );
  }).toList();
}

@riverpod
Future<String?> createMatch(
  Ref ref, {
  required String clientAId,
  required String clientBId,
}) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return 'Not authenticated';

  // Check manager verification status + get region_id
  final mgrRows = await client
      .from('managers')
      .select('verification_status, region_id')
      .eq('id', user.id)
      .limit(1);

  if (mgrRows.isEmpty) return 'Manager not found';

  final verStatus = mgrRows.first['verification_status'] as String? ?? 'unverified';
  if (verStatus != 'verified') {
    return verStatus;
  }

  final myRegion = mgrRows.first['region_id'] as String? ?? '';

  // Get target client's region
  final targetClient = await client
      .from('clients')
      .select('region_id')
      .eq('id', clientBId)
      .maybeSingle();

  final targetRegion = targetClient?['region_id'] as String? ?? '';

  // Get daily limit from subscription tier
  int dailyLimit;
  try {
    dailyLimit = await ref.read(dailyMatchLimitProvider.future);
  } catch (_) {
    dailyLimit = AppConstants.freeMatchDailyLimit;
  }

  final result = await client.rpc('create_match_atomic', params: {
    'p_client_a_id': clientAId,
    'p_client_b_id': clientBId,
    'p_client_a_region': myRegion,
    'p_client_b_region': targetRegion,
    'p_daily_limit': dailyLimit,
  });

  final resultMap = result as Map<String, dynamic>?;
  if (resultMap != null && resultMap.containsKey('error')) {
    return resultMap['error'] as String;
  }

  // Invalidate
  ref.invalidate(marketplaceProfileListProvider);
  ref.invalidate(profileCountsProvider);

  return null; // Success
}

@riverpod
Future<({int all, int female, int male, int liked})> profileCounts(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return (all: 0, female: 0, male: 0, liked: 0);

  // Parallel count queries using Supabase count
  final allFuture = client
      .from('clients')
      .select()
      .neq('manager_id', user.id)
      .eq('status', 'active')
      .count();
  final femaleFuture = client
      .from('clients')
      .select()
      .neq('manager_id', user.id)
      .eq('status', 'active')
      .eq('gender', 'F')
      .count();
  final maleFuture = client
      .from('clients')
      .select()
      .neq('manager_id', user.id)
      .eq('status', 'active')
      .eq('gender', 'M')
      .count();
  final likedFuture = client
      .from('profile_likes')
      .select()
      .eq('manager_id', user.id)
      .count();

  final results = await Future.wait([allFuture, femaleFuture, maleFuture, likedFuture]);

  return (
    all: results[0].count,
    female: results[1].count,
    male: results[2].count,
    liked: results[3].count,
  );
}
