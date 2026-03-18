import 'package:shared_preferences/shared_preferences.dart';

import '../providers/subscription_provider.dart';

class DevSubscriptionService {
  static const _key = 'dev_subscription_tier';

  static Future<SubscriptionTier?> getTier() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return null;
    return SubscriptionTier.values.where((t) => t.name == value).firstOrNull;
  }

  static Future<void> setTier(SubscriptionTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, tier.name);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
