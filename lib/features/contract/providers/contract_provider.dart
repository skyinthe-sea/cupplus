import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';
import '../services/contract_service.dart';

part 'contract_provider.g.dart';

/// Fetch all contract agreements for a specific client
@riverpod
Future<List<Map<String, dynamic>>> clientContracts(
  Ref ref,
  String clientId,
) async {
  final client = ref.watch(supabaseClientProvider);

  final result = await client
      .from('contract_agreements')
      .select()
      .eq('client_id', clientId)
      .order('agreed_at', ascending: false);

  return result;
}

/// Fetch all contracts managed by current manager
@riverpod
Future<List<Map<String, dynamic>>> myContracts(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final result = await client
      .from('contract_agreements')
      .select('*, clients!inner(full_name)')
      .eq('manager_id', user.id)
      .order('agreed_at', ascending: false)
      .limit(100);

  return result;
}

/// Insert a contract agreement record
@riverpod
Future<void> createContractAgreement(
  Ref ref, {
  required String clientId,
  required String regionId,
  required bool marketingConsent,
}) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  final hash = computeContractHash(termsContent, privacyContent);

  await client.from('contract_agreements').insert({
    'client_id': clientId,
    'manager_id': user.id,
    'region_id': regionId,
    'contract_version': currentContractVersion,
    'contract_hash': hash,
    'device_info': collectDeviceInfo(),
    'marketing_consent': marketingConsent,
  });

  ref.invalidate(clientContractsProvider(clientId));
  ref.invalidate(myContractsProvider);
}
