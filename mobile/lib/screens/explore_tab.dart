import 'dart:async';
import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_home_widgets.dart';

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
  String? _activeFilterTitle;

  // Selected genres in the 93-multi-genre picker sheet
  final Set<String> _selectedGenreSlugs = {};

  final List<String> _studios = [
    'MAPPA',
    'Ufotable',
    'Wit Studio',
    'CloverWorks',
    'Bones',
    'Kyoto Animation',
    'Madhouse',
    'Toei Animation',
    'A-1 Pictures',
  ];

  final List<String> _years = [
    '2026',
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      if (text.trim().isNotEmpty) {
        _searchAnime(text.trim());
      } else {
        setState(() {
          _searchResults = [];
          _activeFilterTitle = null;
        });
      }
    });
  }

  Future<void> _searchAnime(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isLoading = true;
      _activeFilterTitle = 'Pencarian: "$clean"';
    });

    final results = await _animeService.searchAnime(clean);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByGenre(String genreSlug, String genreName) async {
    setState(() {
      _isLoading = true;
      _activeFilterTitle = 'Kategori: $genreName';
      _searchController.text = genreName;
    });

    final results = await _animeService.getAnimeByGenre(genreSlug);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByStudio(String studio) async {
    setState(() {
      _isLoading = true;
      _activeFilterTitle = 'Studio: $studio';
      _searchController.text = studio;
    });

    final results = await _animeService.searchAnime(studio);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByYear(String year) async {
    setState(() {
      _isLoading = true;
      _activeFilterTitle = 'Tahun: $year';
      _searchController.text = year;
    });

    final results = await _animeService.searchAnime(year);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _activeFilterTitle = null;
      _searchResults = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearching =
        _searchController.text.isNotEmpty || _activeFilterTitle != null;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Search Bar at Top (matching Screenshot 1 & 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF13151D),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFF222533)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _searchAnime,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6B7280),
                      size: 22,
                    ),
                    hintText: 'Cari Anime..',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: isSearching
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 20, color: AppColors.textSecondary),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // 2. Body: Either Search Results Grid OR Discovery Categories
            Expanded(
              child: isSearching
                  ? _buildSearchResults()
                  : _buildDiscoveryHub(),
            ),
          ],
        ),
      ),
    );
  }

  /// Discovery Hub (matching Screenshot 1 & 2 with KATEGORI, STUDIO, and TAHUN)
  Widget _buildDiscoveryHub() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        // KATEGORI Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KATEGORI',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            InkWell(
              onTap: _showMultiGenrePickerSheet,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF1C1E26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Pastel Category Cards (matching Screenshot 1 & 2)
        GenreCategoryCard(
          genreTitle: 'Romance',
          characterImageUrl:
              'https://cdn.myanimelist.net/images/characters/11/382092.jpg',
          backgroundColor: const Color(0xFFDCE0E8),
          onTap: () => _filterByGenre('romance', 'Romance'),
        ),
        GenreCategoryCard(
          genreTitle: 'Horror',
          characterImageUrl:
              'https://cdn.myanimelist.net/images/characters/16/329598.jpg',
          backgroundColor: const Color(0xFFFFFFFF),
          onTap: () => _filterByGenre('horror', 'Horror'),
        ),
        GenreCategoryCard(
          genreTitle: 'Fantasy',
          characterImageUrl:
              'https://cdn.myanimelist.net/images/characters/2/411899.jpg',
          backgroundColor: const Color(0xFFF3ECE1),
          onTap: () => _filterByGenre('fantasy', 'Fantasy'),
        ),
        GenreCategoryCard(
          genreTitle: 'Action',
          characterImageUrl:
              'https://cdn.myanimelist.net/images/characters/7/492576.jpg',
          backgroundColor: const Color(0xFFE4DFEC),
          onTap: () => _filterByGenre('action', 'Action'),
        ),
        GenreCategoryCard(
          genreTitle: 'Comedy',
          characterImageUrl:
              'https://cdn.myanimelist.net/images/characters/13/14589.jpg',
          backgroundColor: const Color(0xFFFFF4DE),
          onTap: () => _filterByGenre('comedy', 'Comedy'),
        ),
        GenreCategoryCard(
          genreTitle: 'Isekai',
          characterImageUrl:
              'https://cdn.myanimelist.net/images/characters/14/434691.jpg',
          backgroundColor: const Color(0xFFDCF0FA),
          onTap: () => _filterByGenre('isekai', 'Isekai'),
        ),

        const SizedBox(height: 18),

        // STUDIO Section (matching Screenshot 1 & 2)
        const Text(
          'STUDIO',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _studios.length,
            itemBuilder: (context, index) {
              return StudioChip(
                studioName: _studios[index],
                onTap: () => _filterByStudio(_studios[index]),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // TAHUN Section (matching Screenshot 1 & 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TAHUN',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF1C1E26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _years.length,
            itemBuilder: (context, index) {
              return YearChip(
                year: _years[index],
                onTap: () => _filterByYear(_years[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Search & Filter Results Grid
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 54, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Tidak ditemukan anime untuk "${_searchController.text}"',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Kembali ke Kategori'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _activeFilterTitle ?? 'Hasil Pencarian',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_searchResults.length} Anime',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.44,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final anime = _searchResults[index];
              return AnimeVerticalCard(
                anime: anime,
                topSubtitle: anime.displayGenre,
                topSubtitleColor: AppColors.accent,
                showViews: true,
                showFavorites: true,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 93 Multi-Genre Picker Sheet
  void _showMultiGenrePickerSheet() {
    final tempSelected = Set<String>.from(_selectedGenreSlugs);
    String modalSearch = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableGenres = AnimeService.allGenres.where((g) {
              final slug = g['slug'] ?? '';
              final name = g['name'] ?? '';
              if (slug.isEmpty) return false;
              if (modalSearch.isEmpty) return true;
              return name.toLowerCase().contains(modalSearch.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pilih Genre Lengkap (93 Genre)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (val) {
                          setModalState(() => modalSearch = val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari nama genre...',
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.textSecondary),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: availableGenres.length,
                        itemBuilder: (context, index) {
                          final g = availableGenres[index];
                          final name = g['name'] ?? '';
                          final slug = g['slug'] ?? '';
                          final isChecked = tempSelected.contains(slug);

                          return CheckboxListTile(
                            value: isChecked,
                            title: Text(
                              name,
                              style: TextStyle(
                                color: isChecked
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                                fontWeight: isChecked
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            activeColor: AppColors.accent,
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  tempSelected.add(slug);
                                } else {
                                  tempSelected.remove(slug);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            if (tempSelected.isNotEmpty) {
                              setState(() {
                                _selectedGenreSlugs.clear();
                                _selectedGenreSlugs.addAll(tempSelected);
                                _isLoading = true;
                                _activeFilterTitle =
                                    'Multi-Genre (${tempSelected.length})';
                              });
                              final res = await _animeService
                                  .getAnimeByGenres(tempSelected.toList());
                              if (mounted) {
                                setState(() {
                                  _searchResults = res;
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          child: Text(
                            tempSelected.isEmpty
                                ? 'Tutup'
                                : 'Terapkan (${tempSelected.length} Genre)',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
