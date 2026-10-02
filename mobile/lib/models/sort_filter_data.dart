class SortFilterData {
  final String sort;
  final String category;
  final String region;
  final String genre;
  final String releaseYear;

  const SortFilterData({
    this.sort = 'Popularity',
    this.category = 'Episode',
    this.region = 'Japan',
    this.genre = 'Action',
    this.releaseYear = '2022',
  });

  /// Factory for reset / default state
  factory SortFilterData.defaultFilter() {
    return const SortFilterData(
      sort: 'Popularity',
      category: 'Episode',
      region: 'All',
      genre: 'All',
      releaseYear: 'All',
    );
  }

  /// Initial matching the screenshot
  factory SortFilterData.fromScreenshot() {
    return const SortFilterData(
      sort: 'Popularity',
      category: 'Episode',
      region: 'Japan',
      genre: 'Action',
      releaseYear: '2022',
    );
  }

  bool get hasActiveFilter =>
      genre != 'All' ||
      category != 'Episode' ||
      (region != 'All' && region.isNotEmpty) ||
      (releaseYear != 'All' && releaseYear.isNotEmpty);

  SortFilterData copyWith({
    String? sort,
    String? category,
    String? region,
    String? genre,
    String? releaseYear,
  }) {
    return SortFilterData(
      sort: sort ?? this.sort,
      category: category ?? this.category,
      region: region ?? this.region,
      genre: genre ?? this.genre,
      releaseYear: releaseYear ?? this.releaseYear,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortFilterData &&
          runtimeType == other.runtimeType &&
          sort == other.sort &&
          category == other.category &&
          region == other.region &&
          genre == other.genre &&
          releaseYear == other.releaseYear;

  @override
  int get hashCode =>
      sort.hashCode ^
      category.hashCode ^
      region.hashCode ^
      genre.hashCode ^
      releaseYear.hashCode;
}
