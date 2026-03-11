import 'package:flutter/foundation.dart';

@immutable
class MarketplaceFilter {
  const MarketplaceFilter({
    this.gender,
    this.minAge,
    this.maxAge,
    this.minHeight,
    this.maxHeight,
    this.religion,
    this.isVerifiedOnly = false,
    this.searchQuery,
  });

  final String? gender;
  final int? minAge;
  final int? maxAge;
  final int? minHeight;
  final int? maxHeight;
  final String? religion;
  final bool isVerifiedOnly;
  final String? searchQuery;

  bool get hasActiveFilters =>
      minAge != null ||
      maxAge != null ||
      minHeight != null ||
      maxHeight != null ||
      religion != null ||
      isVerifiedOnly;

  int get activeFilterCount {
    var count = 0;
    if (minAge != null || maxAge != null) count++;
    if (minHeight != null || maxHeight != null) count++;
    if (religion != null) count++;
    if (isVerifiedOnly) count++;
    return count;
  }

  MarketplaceFilter copyWith({
    String? Function()? gender,
    int? Function()? minAge,
    int? Function()? maxAge,
    int? Function()? minHeight,
    int? Function()? maxHeight,
    String? Function()? religion,
    bool? isVerifiedOnly,
    String? Function()? searchQuery,
  }) {
    return MarketplaceFilter(
      gender: gender != null ? gender() : this.gender,
      minAge: minAge != null ? minAge() : this.minAge,
      maxAge: maxAge != null ? maxAge() : this.maxAge,
      minHeight: minHeight != null ? minHeight() : this.minHeight,
      maxHeight: maxHeight != null ? maxHeight() : this.maxHeight,
      religion: religion != null ? religion() : this.religion,
      isVerifiedOnly: isVerifiedOnly ?? this.isVerifiedOnly,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
    );
  }
}
