import 'package:flutter/foundation.dart';

enum SortOrder { newest, mostLikes, recommended }

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
    this.educationLevel,
    this.occupationCategories = const [],
    this.incomeRange,
    this.sortOrder = SortOrder.newest,
    this.drinking,
    this.smoking,
    this.maritalHistory,
    this.residenceArea,
  });

  final String? gender;
  final int? minAge;
  final int? maxAge;
  final int? minHeight;
  final int? maxHeight;
  final String? religion;
  final bool isVerifiedOnly;
  final String? searchQuery;
  final String? educationLevel;
  final List<String> occupationCategories;
  final String? incomeRange;
  final SortOrder sortOrder;
  final String? drinking;
  final String? smoking;
  final String? maritalHistory;
  final String? residenceArea;

  bool get hasActiveFilters =>
      minAge != null ||
      maxAge != null ||
      minHeight != null ||
      maxHeight != null ||
      religion != null ||
      isVerifiedOnly ||
      educationLevel != null ||
      occupationCategories.isNotEmpty ||
      incomeRange != null ||
      sortOrder != SortOrder.newest ||
      drinking != null ||
      smoking != null ||
      maritalHistory != null ||
      residenceArea != null;

  int get activeFilterCount {
    var count = 0;
    if (minAge != null || maxAge != null) count++;
    if (minHeight != null || maxHeight != null) count++;
    if (religion != null) count++;
    if (isVerifiedOnly) count++;
    if (educationLevel != null) count++;
    if (occupationCategories.isNotEmpty) count++;
    if (incomeRange != null) count++;
    if (sortOrder != SortOrder.newest) count++;
    if (drinking != null) count++;
    if (smoking != null) count++;
    if (maritalHistory != null) count++;
    if (residenceArea != null) count++;
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
    String? Function()? educationLevel,
    List<String>? occupationCategories,
    String? Function()? incomeRange,
    SortOrder? sortOrder,
    String? Function()? drinking,
    String? Function()? smoking,
    String? Function()? maritalHistory,
    String? Function()? residenceArea,
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
      educationLevel: educationLevel != null ? educationLevel() : this.educationLevel,
      occupationCategories: occupationCategories ?? this.occupationCategories,
      incomeRange: incomeRange != null ? incomeRange() : this.incomeRange,
      sortOrder: sortOrder ?? this.sortOrder,
      drinking: drinking != null ? drinking() : this.drinking,
      smoking: smoking != null ? smoking() : this.smoking,
      maritalHistory: maritalHistory != null ? maritalHistory() : this.maritalHistory,
      residenceArea: residenceArea != null ? residenceArea() : this.residenceArea,
    );
  }
}
