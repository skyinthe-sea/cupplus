import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants.dart';
import '../../../config/supabase_config.dart';

part 'subscription_provider.g.dart';

/// Business date: before 04:44 counts as previous day
String _businessDate() {
  final now = DateTime.now();
  final resetToday = DateTime(now.year, now.month, now.day,
      AppConstants.dailyResetHour, AppConstants.dailyResetMinute);
  final effective = now.isBefore(resetToday)
      ? now.subtract(const Duration(days: 1))
      : now;
  return effective.toIso8601String().substring(0, 10);
}

/// Subscription tier enum
enum SubscriptionTier { free, standard, premium }

/// Whether RevenueCat SDK has been configured.
/// Set to true after Purchases.configure() in main.dart.
bool _revenueCatConfigured = false;

/// Call this after Purchases.configure() succeeds.
void markRevenueCatConfigured() => _revenueCatConfigured = true;

/// Current subscription tier based on RevenueCat entitlements.
/// Falls back to [SubscriptionTier.free] if RevenueCat is not configured.
@riverpod
Future<SubscriptionTier> currentSubscriptionTier(Ref ref) async {
  if (!_revenueCatConfigured) return SubscriptionTier.free;
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.all['premium']?.isActive == true) {
      return SubscriptionTier.premium;
    }
    if (customerInfo.entitlements.all['standard']?.isActive == true) {
      return SubscriptionTier.standard;
    }
  } catch (e) {
    debugPrint('RevenueCat not available: $e');
  }
  return SubscriptionTier.free;
}

/// Daily match limit based on subscription tier
@riverpod
Future<int?> dailyMatchLimit(Ref ref) async {
  final tier = await ref.watch(currentSubscriptionTierProvider.future);
  return switch (tier) {
    SubscriptionTier.free => AppConstants.freeMatchDailyLimit,
    SubscriptionTier.standard => AppConstants.standardMatchDailyLimit,
    SubscriptionTier.premium => null, // unlimited
  };
}

/// Today's match usage count from daily_match_counts table
@riverpod
Future<int> todayMatchUsage(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return 0;

  final today = _businessDate();
  final result = await client
      .from('daily_match_counts')
      .select('count')
      .eq('manager_id', user.id)
      .eq('match_date', today)
      .maybeSingle();

  return (result?['count'] as int?) ?? 0;
}

/// Check if manager can create a match today
@riverpod
Future<bool> canCreateMatch(Ref ref) async {
  final limit = await ref.watch(dailyMatchLimitProvider.future);
  if (limit == null) return true; // unlimited (premium)

  final used = await ref.watch(todayMatchUsageProvider.future);
  return used < limit;
}

/// Restore purchases via RevenueCat
@riverpod
Future<bool> restorePurchases(Ref ref) async {
  if (!_revenueCatConfigured) return false;
  try {
    final info = await Purchases.restorePurchases();
    ref.invalidate(currentSubscriptionTierProvider);
    return info.entitlements.all.values.any((e) => e.isActive);
  } catch (_) {
    return false;
  }
}

/// Available packages from RevenueCat offerings
@riverpod
Future<List<Package>> availablePackages(Ref ref) async {
  if (!_revenueCatConfigured) return [];
  try {
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? [];
  } catch (_) {
    return [];
  }
}

/// Purchase a specific package
@riverpod
Future<bool> purchasePackage(Ref ref, Package package) async {
  if (!_revenueCatConfigured) return false;
  try {
    await Purchases.purchasePackage(package);
    ref.invalidate(currentSubscriptionTierProvider);
    ref.invalidate(dailyMatchLimitProvider);
    return true;
  } catch (_) {
    return false;
  }
}
