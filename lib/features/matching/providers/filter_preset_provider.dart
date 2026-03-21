import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/filter_preset.dart';
import '../models/marketplace_filter.dart';

const _storageKey = 'filter_presets_v1';
const maxPresets = 5;

class FilterPresetNotifier extends Notifier<List<FilterPreset>> {
  bool get canSave => state.length < maxPresets;
  @override
  List<FilterPreset> build() {
    _loadFromDisk();
    return [];
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json != null && json.isNotEmpty) {
      try {
        state = FilterPreset.decodeList(json);
      } catch (_) {
        // Corrupted data — reset
        state = [];
      }
    }
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, FilterPreset.encodeList(state));
  }

  Future<bool> savePreset(String name, MarketplaceFilter filter) async {
    if (!canSave) return false;
    final preset = FilterPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      filter: filter,
      createdAt: DateTime.now(),
    );
    state = [preset, ...state];
    await _saveToDisk();
    return true;
  }

  Future<void> deletePreset(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _saveToDisk();
  }

  Future<void> updatePreset(String id, String name, MarketplaceFilter filter) async {
    state = state.map((p) {
      if (p.id == id) {
        return FilterPreset(
          id: p.id,
          name: name,
          filter: filter,
          createdAt: p.createdAt,
        );
      }
      return p;
    }).toList();
    await _saveToDisk();
  }
}

final filterPresetNotifierProvider =
    NotifierProvider<FilterPresetNotifier, List<FilterPreset>>(
  FilterPresetNotifier.new,
);
