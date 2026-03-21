import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'marketplace_filter.dart';

@immutable
class FilterPreset {
  const FilterPreset({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
  });

  final String id;
  final String name;
  final MarketplaceFilter filter;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'filter': filter.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory FilterPreset.fromJson(Map<String, dynamic> json) {
    return FilterPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      filter:
          MarketplaceFilter.fromJson(json['filter'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static String encodeList(List<FilterPreset> presets) {
    return jsonEncode(presets.map((p) => p.toJson()).toList());
  }

  static List<FilterPreset> decodeList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => FilterPreset.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
