import 'dart:async';
import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/not_found_view.dart';
import 'anime_detail_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final AnimeService _animeService = AnimeService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = false;
  List<AnimeItem> _searchResults = [];
  List<AnimeItem> _popularRecommendations = [];

  // Multi-genre selection support
  final Set<String> _selectedGenreSlugs = {};
  bool _filterExactOnly = false;
  int _currentGenrePage = 1;
  bool _isLoadingMore = false;

  // Curated popular genres in the horizontal row for instant 1-tap multi-toggle
  static const List<Map<String, String>> _quickGenres = [
    {'name': 'Semua', 'slug': ''},
    {'name': 'Action', 'slug': 'action'},
    {'name': 'Adventure', 'slug': 'adventure'},
    {'name': 'Comedy', 'slug': 'comedy'},
    {'name': 'Drama', 'slug': 'drama'},
    {'name': 'Fantasy', 'slug': 'fantasy'},
    {'name': 'Isekai', 'slug': 'isekai'},
    {'name': 'Romance', 'slug': 'romance'},
    {'name': 'Supernatural', 'slug': 'supernatural'},
    {'name': 'Sci-Fi', 'slug': 'sci-fi'},
    {'name': 'Slice of Life', 'slug': 'slice-of-life'},
    {'name': 'Mystery', 'slug': 'mystery'},
    {'name': 'Psychological', 'slug': 'psychological'},
    {'name': 'Horror', 'slug': 'horror'},
    {'name': 'Shounen', 'slug': 'shounen'},
    {'name': 'Seinen', 'slug': 'seinen'},
    {'name': 'Sports', 'slug': 'sports'},
    {'name': 'Mecha', 'slug': 'mecha'},
    {'name': 'Magic', 'slug': 'magic'},
    {'name': 'Military', 'slug': 'military'},
    {'name': 'Martial Arts', 'slug': 'martial-arts'},
    {'name': 'Music', 'slug': 'music'},
    {'name': 'Historical', 'slug': 'historical'},
    {'name': 'Demons', 'slug': 'demons'},
    {'name': 'Super Power', 'slug': 'super-power'},
    {'name': 'Vampire', 'slug': 'vampire'},
    {'name': 'Ecchi', 'slug': 'ecchi'},
    {'name': 'Harem', 'slug': 'harem'},
    {'name': 'School', 'slug': 'school'},
    {'name': 'Thriller', 'slug': 'thriller'},
    {'name': 'Game', 'slug': 'game'},
    {'name': 'Parody', 'slug': 'parody'},
    {'name': 'Space', 'slug': 'space'},
  ];

  final List<String> _trendingTags = [
    'Solo Leveling',
    'One Piece',
    'Jujutsu Kaisen',
    'DanDaDan',
    'Bleach',
    'Frieren',
    'Demon Slayer',
    'Chainsaw Man',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final results = await _animeService.getPalingPopuler();
    if (mounted) {
      setState(() {
        _popularRecommendations = results;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 320), () {
      _applySearch();
    });
  }

  Future<void> _applySearch() async {
    final query = _searchController.text.trim();
    final hasQuery = query.isNotEmpty;
    final hasGenres = _selectedGenreSlugs.isNotEmpty;

    if (!hasQuery && !hasGenres) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentGenrePage = 1;
    });

    try {
      if (hasQuery && !hasGenres) {
        final results = await _animeService.searchAnime(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        }
      } else if (!hasQuery && hasGenres) {
        // Multi-genre without query
        List<AnimeItem> results;
        if (_selectedGenreSlugs.length == 1) {
          results =
              await _animeService.getAnimeByGenre(_selectedGenreSlugs.first);
        } else {
          results = await _animeService
              .getAnimeByGenres(_selectedGenreSlugs.toList());
        }
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        }
      } else {
        // Both query and multi-genre filter
        final searchResults = await _animeService.searchAnime(query);
        List<AnimeItem> genreResults;
        if (_selectedGenreSlugs.length == 1) {
          genreResults =
              await _animeService.getAnimeByGenre(_selectedGenreSlugs.first);
        } else {
          genreResults = await _animeService
              .getAnimeByGenres(_selectedGenreSlugs.toList());
        }

        final Set<String> genreIds = genreResults.map((e) => e.id).toSet();
        final matched =
            searchResults.where((item) => genreIds.contains(item.id)).toList();

        if (mounted) {
          setState(() {
            _searchResults = matched.isNotEmpty ? matched : searchResults;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleGenre(String slug) {
    if (slug.isEmpty) {
      // 'Semua' selected -> clear all filters
      setState(() {
        _selectedGenreSlugs.clear();
        _filterExactOnly = false;
      });
    } else {
      setState(() {
        if (_selectedGenreSlugs.contains(slug)) {
          _selectedGenreSlugs.remove(slug);
        } else {
          _selectedGenreSlugs.add(slug);
        }
        _filterExactOnly = false;
      });
    }
    _applySearch();
  }

  void _onTrendingTap(String tag) {
    _searchController.text = tag;
    _applySearch();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedGenreSlugs.clear();
      _searchResults = [];
      _filterExactOnly = false;
      _currentGenrePage = 1;
    });
  }

  Future<void> _loadMoreAnime() async {
    if (_isLoadingMore || _selectedGenreSlugs.isEmpty) return;

    setState(() => _isLoadingMore = true);
    _currentGenrePage += 2;

    try {
      final List<AnimeItem> moreItems;
      if (_selectedGenreSlugs.length == 1) {
        moreItems = await _animeService.getAnimeByGenre(
          _selectedGenreSlugs.first,
          page: _currentGenrePage,
        );
      } else {
        moreItems = await _animeService.getAnimeByGenres(
          _selectedGenreSlugs.toList(),
          page: _currentGenrePage,
        );
      }

      if (mounted) {
        setState(() {
          final Set<String> existingKeys = _searchResults
              .map((e) => e.id.isNotEmpty ? e.id : e.slug)
              .toSet();
          for (final item in moreItems) {
            final key = item.id.isNotEmpty ? item.id : item.slug;
            if (existingKeys.add(key)) {
              _searchResults.add(item);
            }
          }
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  String _getGenreName(String slug) {
    for (final g in AnimeService.allGenres) {
      if (g['slug'] == slug) return g['name']!;
    }
    return slug;
  }

  /// Opens the interactive 90+ Genres modal bottom sheet with multi-select support
  void _openAllGenresBottomSheet() {
    final searchModalCtrl = TextEditingController();
    final Set<String> tempSelected = Set<String>.from(_selectedGenreSlugs);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchModalCtrl.text.trim().toLowerCase();
            final all = AnimeService.allGenres.where((g) {
              final slug = g['slug'] ?? '';
              if (slug.isEmpty) return false;
              if (query.isEmpty) return true;
              final name = (g['name'] ?? '').toLowerCase();
              return name.contains(query) || slug.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.5),
                  left: BorderSide(color: AppColors.border, width: 1.5),
                  right: BorderSide(color: AppColors.border, width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderHover,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header with counter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.category_rounded,
                            color: AppColors.accent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Pilih Genre Anime',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (tempSelected.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${tempSelected.length} dipilih',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'Bisa memilih lebih dari satu genre bersamaan',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 20),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                  ),

                  // Search field inside modal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.search_rounded,
                                color: AppColors.textMuted, size: 18),
                          ),
                          Expanded(
                            child: TextField(
                              controller: searchModalCtrl,
                              onChanged: (_) => setModalState(() {}),
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Cari nama genre (Isekai, Mecha, Vampire)...',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12.5,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 11),
                              ),
                            ),
                          ),
                          if (searchModalCtrl.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.close_rounded,
                                  size: 16, color: AppColors.textMuted),
                              onPressed: () {
                                searchModalCtrl.clear();
                                setModalState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick reset text if any selected
                  if (tempSelected.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${tempSelected.length} genre aktif terpilih',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempSelected.clear();
                              });
                            },
                            child: const Text(
                              'Reset Pilihan',
                              style: TextStyle(
                                color: Color(0xFFFF5252),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Divider(color: AppColors.border, height: 14),

                  // Genre Chips List (All 90+ genres with multi-toggle)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: all.map((g) {
                          final slug = g['slug']!;
                          final name = g['name']!;
                          final isSelected = tempSelected.contains(slug);

                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempSelected.remove(slug);
                                } else {
                                  tempSelected.add(slug);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 7.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: isSelected ? 1.4 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Bottom Action Bar to Apply
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempSelected.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: AppColors.borderHover),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(modalContext);
                                setState(() {
                                  _selectedGenreSlugs.clear();
                                  _selectedGenreSlugs.addAll(tempSelected);
                                });
                                _applySearch();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                tempSelected.isNotEmpty
                                    ? 'Terapkan (${tempSelected.length} Genre)'
                                    : 'Tampilkan Semua',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFiltering = _searchController.text.trim().isNotEmpty ||
        _selectedGenreSlugs.isNotEmpty;
    final List<AnimeItem> rawList =
        isFiltering ? _searchResults : _popularRecommendations;

    final int exactCount = (isFiltering && _selectedGenreSlugs.length > 1)
        ? rawList
            .where((item) => item.genres.length >= _selectedGenreSlugs.length)
            .length
        : 0;

    final displayList = (_filterExactOnly && exactCount > 0)
        ? rawList
            .where((item) => item.genres.length >= _selectedGenreSlugs.length)
            .toList()
        : rawList;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 1. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFiltering
                        ? AppColors.accent.withValues(alpha: 0.6)
                        : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari anime, judul, karakter...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _applySearch();
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Horizontal Genre Selector: Button for 90+ Genres + Multi-Select Quick Pills
            SizedBox(
              height: 36,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  // Button to open all 90+ genres modal
                  InkWell(
                    onTap: _openAllGenresBottomSheet,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedGenreSlugs.isNotEmpty
                            ? AppColors.accent.withValues(alpha: 0.2)
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _selectedGenreSlugs.isNotEmpty
                              ? AppColors.accent
                              : AppColors.border,
                          width: 1.3,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: _selectedGenreSlugs.isNotEmpty
                                ? AppColors.accent
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _selectedGenreSlugs.isNotEmpty
                                ? 'Genre (${_selectedGenreSlugs.length})'
                                : 'Semua Genre (90+)',
                            style: TextStyle(
                              color: _selectedGenreSlugs.isNotEmpty
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 'Semua' Reset Pill
                  InkWell(
                    onTap: () {
                      if (_selectedGenreSlugs.isNotEmpty) {
                        setState(() {
                          _selectedGenreSlugs.clear();
                        });
                        _applySearch();
                      }
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedGenreSlugs.isEmpty
                            ? AppColors.accent
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _selectedGenreSlugs.isEmpty
                              ? AppColors.accent
                              : AppColors.border,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'Semua',
                        style: TextStyle(
                          color: _selectedGenreSlugs.isEmpty
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: _selectedGenreSlugs.isEmpty
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Horizontal Quick Popular Genres (Multi-Select toggleable!)
                  ..._quickGenres.skip(1).map((g) {
                    final slug = g['slug']!;
                    final name = g['name']!;
                    final isSelected = _selectedGenreSlugs.contains(slug);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => _toggleGenre(slug),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.border,
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.accent.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. Active Genre Chips Row (When 1 or more genres are selected)
            if (_selectedGenreSlugs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 30,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._selectedGenreSlugs.map((slug) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.only(
                              left: 10, right: 6, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getGenreName(slug),
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _toggleGenre(slug),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGenreSlugs.clear();
                          });
                          _applySearch();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22171A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF4A252A), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_sweep_rounded,
                                  size: 13, color: Color(0xFFFF5A6E)),
                              SizedBox(width: 4),
                              Text(
                                'Hapus Semua',
                                style: TextStyle(
                                  color: Color(0xFFFF5A6E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 4. Trending Tags (Only shown when not actively typing and no genre selected)
            if (!isFiltering) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _trendingTags.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = _trendingTags[index];
                      return GestureDetector(
                        onTap: () => _onTrendingTap(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 5. Section Title & Reset Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isFiltering
                          ? (_searchController.text.trim().isNotEmpty
                              ? (_selectedGenreSlugs.isNotEmpty
                                  ? 'Hasil "${_searchController.text.trim()}" + ${_selectedGenreSlugs.map(_getGenreName).join(', ')} (${displayList.length})'
                                  : 'Hasil untuk "${_searchController.text.trim()}" (${displayList.length})')
                              : 'Filter: ${_selectedGenreSlugs.map(_getGenreName).join(' + ')} (${displayList.length})')
                          : 'Rekomendasi Anime Populer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (isFiltering)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isFiltering &&
                _selectedGenreSlugs.length > 1 &&
                rawList.isNotEmpty &&
                exactCount > 0)
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 6, bottom: 2),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_filterExactOnly) {
                          setState(() => _filterExactOnly = false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_filterExactOnly
                              ? AppColors.accent
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: !_filterExactOnly
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          'Semua Terkait (${rawList.length})',
                          style: TextStyle(
                            color: !_filterExactOnly
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (!_filterExactOnly) {
                          setState(() => _filterExactOnly = true);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _filterExactOnly
                              ? AppColors.accent
                              : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _filterExactOnly
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          'Kombinasi Lengkap ($exactCount)',
                          style: TextStyle(
                            color: _filterExactOnly
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // 6. Anime Content (SliverGrid with Lazy Loading - High Performance)
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              )
            else if (displayList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: NotFoundView(
                  keyword: _searchController.text.trim(),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.41,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final anime = displayList[index];
                      final history =
                          StorageService.getHistoryForAnime(anime.id, anime.slug);

                      return _ExploreAnimeCard(
                        anime: anime,
                        watchedEpisode: history?.episodeNumber,
                        watchedTotal: history?.totalEpisodes,
                      );
                    },
                    childCount: displayList.length,
                  ),
                ),
              ),

              // Load more button (for multi-genre / genre exploration)
              if (_selectedGenreSlugs.isNotEmpty && displayList.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    child: Center(
                      child: _isLoadingMore
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.accent,
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: _loadMoreAnime,
                              icon: const Icon(Icons.expand_more_rounded,
                                  size: 18),
                              label: const Text('Muat Lebih Banyak Anime'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: BorderSide(
                                    color: AppColors.border, width: 1.2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
            ],

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive card for Explore / Search Tab with zero pixel overflow
class _ExploreAnimeCard extends StatelessWidget {
  final AnimeItem anime;
  final int? watchedEpisode;
  final int? watchedTotal;

  const _ExploreAnimeCard({
    required this.anime,
    this.watchedEpisode,
    this.watchedTotal,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimeDetailScreen(anime: anime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasWatched = watchedEpisode != null && watchedEpisode! > 0;

    return InkWell(
      onTap: () => _navigateToDetail(context),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Poster Image (Responsive AspectRatio 0.70)
          AspectRatio(
            aspectRatio: 0.70,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  anime.posterUrl.isNotEmpty
                      ? Image.network(
                          anime.posterUrl,
                          fit: BoxFit.cover,
                          headers: const {
                            'User-Agent':
                                'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                            'Referer': 'https://hianime.at/',
                          },
                          cacheWidth: 360,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.surfaceMuted,
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholder(),

                  // Watched badge (Top Left)
                  if (hasWatched)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text(
                          'Ep. $watchedEpisode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // Mini watched progress bar at bottom of poster
                  if (hasWatched)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2.5,
                        color: Colors.black54,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (anime.totalEpisodes > 0 ||
                                  (watchedTotal ?? 0) > 0)
                              ? (watchedEpisode! /
                                      (anime.totalEpisodes > 0
                                          ? anime.totalEpisodes
                                          : watchedTotal!))
                                  .clamp(0.08, 1.0)
                              : 0.5,
                          child: Container(color: AppColors.accent),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 2. Genre in Orange
          Text(
            hasWatched
                ? 'Sampai Ep. $watchedEpisode'
                : anime.displayGenre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),

          // 3. Anime Title (2 lines max with controlled height)
          Text(
            anime.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),

          // 4. Views count
          Row(
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                size: 11,
                color: AppColors.viewsRed,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  anime.formattedViews,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.viewsRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: AppColors.textMuted,
          size: 26,
        ),
      ),
    );
  }
}
