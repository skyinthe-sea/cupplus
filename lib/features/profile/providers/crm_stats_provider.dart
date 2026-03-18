import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';

part 'crm_stats_provider.g.dart';

class CrmStats {
  const CrmStats({
    this.totalClients = 0,
    this.activeClients = 0,
    this.pausedClients = 0,
    this.matchedClients = 0,
    this.maleClients = 0,
    this.femaleClients = 0,
    this.totalMatches = 0,
    this.acceptedMatches = 0,
    this.declinedMatches = 0,
    this.pendingMatches = 0,
    this.totalNotes = 0,
    this.thisMonthRegistrations = 0,
    this.thisMonthMatches = 0,
    this.avgAge = 0.0,
  });

  final int totalClients;
  final int activeClients;
  final int pausedClients;
  final int matchedClients;
  final int maleClients;
  final int femaleClients;
  final int totalMatches;
  final int acceptedMatches;
  final int declinedMatches;
  final int pendingMatches;
  final int totalNotes;
  final int thisMonthRegistrations;
  final int thisMonthMatches;
  final double avgAge;

  double get matchSuccessRate =>
      totalMatches > 0 ? (acceptedMatches / totalMatches * 100) : 0;

  double get matchDeclineRate =>
      totalMatches > 0 ? (declinedMatches / totalMatches * 100) : 0;
}

@riverpod
Future<CrmStats> crmStats(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return const CrmStats();

  try {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();

    // Parallel queries — split by return type
    final listResults = await Future.wait([
      client
          .from('clients')
          .select('status, gender, birth_date')
          .eq('manager_id', user.id)
          .neq('status', 'withdrawn'),
      client
          .from('matches')
          .select('status, matched_at')
          .eq('manager_id', user.id),
    ]);

    final countResults = await Future.wait([
      client.from('client_notes').select().eq('manager_id', user.id).count(),
      client.from('clients').select().eq('manager_id', user.id)
          .neq('status', 'withdrawn').gte('created_at', monthStart).count(),
      client.from('matches').select().eq('manager_id', user.id)
          .gte('matched_at', monthStart).count(),
    ]);

    final clients = listResults[0];
    final matches = listResults[1];
    final noteCount = countResults[0].count;
    final thisMonthRegs = countResults[1].count;
    final thisMonthMatches = countResults[2].count;

    // Client stats
    int active = 0, paused = 0, matched = 0, male = 0, female = 0;
    double totalAge = 0;
    int ageCount = 0;
    final currentYear = now.year;

    for (final c in clients) {
      final status = c['status'] as String?;
      if (status == 'active') active++;
      else if (status == 'paused') paused++;
      else if (status == 'matched') matched++;

      final gender = c['gender'] as String?;
      if (gender == 'M') male++;
      else if (gender == 'F') female++;

      final birthDate = c['birth_date'] as String?;
      if (birthDate != null) {
        final year = DateTime.tryParse(birthDate)?.year;
        if (year != null) {
          totalAge += currentYear - year;
          ageCount++;
        }
      }
    }

    // Match stats
    int accepted = 0, declined = 0, pending = 0;
    for (final m in matches) {
      final status = m['status'] as String?;
      if (status == 'accepted' || status == 'meeting_scheduled' || status == 'completed') {
        accepted++;
      } else if (status == 'declined' || status == 'cancelled') {
        declined++;
      } else if (status == 'pending') {
        pending++;
      }
    }

    return CrmStats(
      totalClients: clients.length,
      activeClients: active,
      pausedClients: paused,
      matchedClients: matched,
      maleClients: male,
      femaleClients: female,
      totalMatches: matches.length,
      acceptedMatches: accepted,
      declinedMatches: declined,
      pendingMatches: pending,
      totalNotes: noteCount,
      thisMonthRegistrations: thisMonthRegs,
      thisMonthMatches: thisMonthMatches,
      avgAge: ageCount > 0 ? totalAge / ageCount : 0,
    );
  } catch (e) {
    debugPrint('Failed to fetch CRM stats: $e');
    return const CrmStats();
  }
}
