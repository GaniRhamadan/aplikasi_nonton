class SortFilterData {
  final String sort;
  final String category;
  final String region;
  final String genre;
  final List<String> genres;
  final String releaseYear;

  const SortFilterData({
    this.sort = 'Popularity',
    this.category = 'Episode',
    this.region = 'All',
    this.genre = 'All',
    this.genres = const [],
    this.releaseYear = 'All',
  });

  /// Returns list of currently active genres
  List<String> get activeGenres {
    if (genres.isNotEmpty) return genres;
    if (genre.isNotEmpty && genre != 'All') {
      return genre
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty && g != 'All')
          .toList();
    }
    return const [];
  }

  /// Factory for reset / default state
  factory SortFilterData.defaultFilter() {
    return const SortFilterData(
      sort: 'Popularity',
      category: 'Episode',
      region: 'All',
      genre: 'All',
      genres: [],
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
      genres: ['Action'],
      releaseYear: '2022',
    );
  }

  bool get hasActiveFilter =>
      sort != 'Popularity' ||
      genres.isNotEmpty ||
      (genre != 'All' && genre.isNotEmpty) ||
      category != 'Episode' ||
      (region != 'All' && region.isNotEmpty) ||
      (releaseYear != 'All' && releaseYear.isNotEmpty);

  SortFilterData copyWith({
    String? sort,
    String? category,
    String? region,
    String? genre,
    List<String>? genres,
    String? releaseYear,
  }) {
    final updatedGenres = genres ?? this.genres;
    final updatedGenre = genre ??
        (updatedGenres.isNotEmpty ? updatedGenres.join(', ') : this.genre);
    return SortFilterData(
      sort: sort ?? this.sort,
      category: category ?? this.category,
      region: region ?? this.region,
      genre: updatedGenre,
      genres: updatedGenres,
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
      genres.hashCode ^
      releaseYear.hashCode;
}
