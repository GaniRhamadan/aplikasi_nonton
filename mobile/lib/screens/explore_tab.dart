import 'dart:async';
import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_card.dart';
import '../widgets/continue_watching_card.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final AnimeService _animeService = AnimeService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<AnimeItem> _animeList = [];
  bool _isLoading = true;
  final Set<String> _selectedGenreSlugs = {};
  WatchHistoryItem? _latestHistory;

  // Primary popular genres for quick horizontal bar
  final List<Map<String, String>> _quickGenres = [
    {'name': 'Action', 'slug': 'action'},
    {'name': 'Adventure', 'slug': 'adventure'},
    {'name': 'Comedy', 'slug': 'comedy'},
    {'name': 'Fantasy', 'slug': 'fantasy'},
    {'name': 'Isekai', 'slug': 'isekai'},
    {'name': 'Romance', 'slug': 'romance'},
    {'name': 'Sci-Fi', 'slug': 'sci-fi'},
    {'name': 'Shounen', 'slug': 'shounen'},
    {'name': 'Supernatural', 'slug': 'supernatural'},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _fetchAnime();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  Future<void> _checkForAppUpdate() async {
    final update = await UpdateService.checkForUpdate();
    if (mounted && update != null) {
      UpdateService.showUpdateModal(context, update);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    final history = StorageService.getHistory();
    setState(() {
      _latestHistory = history.isNotEmpty ? history.first : null;
    });
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (text.trim().isNotEmpty) {
        _searchAnime(text);
      } else {
        _fetchAnime();
      }
    });
  }

  Future<void> _searchAnime(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isLoading = true;
      _animeList = [];
    });

    final results = await _animeService.searchAnime(clean);
    if (mounted) {
      setState(() {
        _animeList = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAnime() async {
    setState(() {
      _isLoading = true;
      _animeList = [];
    });

    List<AnimeItem> results;
    if (_selectedGenreSlugs.isEmpty) {
      results = await _animeService.getPopularAnime();
    } else {
      results = await _animeService.getAnimeByGenres(_selectedGenreSlugs.toList());
    }

    if (mounted) {
      setState(() {
        _animeList = results;
        _isLoading = false;
      });
    }
  }

  void _toggleQuickGenre(String slug) {
    setState(() {
      _searchController.clear();
      if (_selectedGenreSlugs.contains(slug)) {
        _selectedGenreSlugs.remove(slug);
      } else {
        _selectedGenreSlugs.add(slug);
      }
    });
    _fetchAnime();
  }

  void _clearAllGenres() {
    setState(() {
      _selectedGenreSlugs.clear();
      _searchController.clear();
    });
    _fetchAnime();
  }

  String _getGenreName(String slug) {
    final found = AnimeService.allGenres.firstWhere(
      (g) => g['slug'] == slug,
      orElse: () => {'name': slug, 'slug': slug},
    );
    return found['name'] ?? slug;
  }

  void _showMultiGenrePickerSheet() {
    // Local copy of selections during modal interaction
    final tempSelected = Set<String>.from(_selectedGenreSlugs);
    String modalSearchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableGenres = AnimeService.allGenres.where((g) {
              final slug = g['slug'] ?? '';
              final name = g['name'] ?? '';
              if (slug.isEmpty) return false;
              if (modalSearchQuery.isEmpty) return true;
              return name.toLowerCase().contains(modalSearchQuery.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.82,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Pilih Multi-Genre',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (tempSelected.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${tempSelected.length} dipilih',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Bisa memilih lebih dari satu genre sekaligus',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    // Filter Search Input in Sheet
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (val) {
                          setModalState(() {
                            modalSearchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari genre (Action, Isekai, Romance...)...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AppColors.surfaceMuted,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.border),

                    // Genre Checkbox Grid
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: availableGenres.length,
                        itemBuilder: (context, index) {
                          final item = availableGenres[index];
                          final name = item['name'] ?? '';
                          final slug = item['slug'] ?? '';
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
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentMuted
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: 1.3,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.accent
                                            : AppColors.textPrimary,
                                        fontSize: 12.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Action Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          if (tempSelected.isNotEmpty) ...[
                            OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempSelected.clear();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(90, 48),
                              ),
                              child: const Text('Reset'),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  _selectedGenreSlugs.clear();
                                  _selectedGenreSlugs.addAll(tempSelected);
                                  _searchController.clear();
                                });
                                _fetchAnime();
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: Text(
                                tempSelected.isEmpty
                                    ? 'Terapkan (Semua Genre)'
                                    : 'Terapkan (${tempSelected.length} Genre)',
                              ),
                            ),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        _loadHistory();
        if (_searchController.text.isNotEmpty) {
          await _searchAnime(_searchController.text);
        } else {
          await _fetchAnime();
        }
      },
      child: CustomScrollView(
        slivers: [
          // App Bar with Clean Title - Pinned to prevent status bar overlap
          SliverAppBar(
            floating: false,
            pinned: true,
            snap: false,
            elevation: 0,
            scrolledUnderElevation: 1,
            backgroundColor: AppColors.surface,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AniMobile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Search Input & Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar with explicit Search button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onSubmitted: _searchAnime,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Cari anime (Naruto, Solo Leveling, dll)...',
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.textSecondary, size: 22),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      _fetchAnime();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _searchAnime(_searchController.text),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(64, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text('Cari'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Horizontal Quick Bar: "Semua", Multi-Genres Toggle, "Pilih Genre (42+)"
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickGenres.length + 2,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        // 1. "Semua" button
                        if (index == 0) {
                          final isAll = _selectedGenreSlugs.isEmpty &&
                              _searchController.text.isEmpty;
                          return InkWell(
                            onTap: _clearAllGenres,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isAll
                                    ? AppColors.textPrimary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isAll
                                      ? AppColors.textPrimary
                                      : AppColors.border,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Semua',
                                  style: TextStyle(
                                    color: isAll
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: isAll
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // 2. "Pilih Genre (42+)" modal button
                        if (index == _quickGenres.length + 1) {
                          final hasCount = _selectedGenreSlugs.isNotEmpty;
                          return OutlinedButton.icon(
                            onPressed: _showMultiGenrePickerSheet,
                            icon: const Icon(Icons.tune_rounded, size: 16),
                            label: Text(
                              hasCount
                                  ? 'Filter Genre (${_selectedGenreSlugs.length})'
                                  : 'Pilih Multi-Genre (93 Genre)',
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(120, 38),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              foregroundColor: hasCount
                                  ? Colors.white
                                  : AppColors.accent,
                              backgroundColor: hasCount
                                  ? AppColors.accent
                                  : AppColors.accentMuted,
                              side: BorderSide(
                                color: hasCount
                                    ? AppColors.accent
                                    : AppColors.accentBorder,
                              ),
                            ),
                          );
                        }

                        // 3. Quick genre toggle pills
                        final item = _quickGenres[index - 1];
                        final name = item['name'] ?? '';
                        final slug = item['slug'] ?? '';
                        final isSelected = _selectedGenreSlugs.contains(slug);

                        return InkWell(
                          onTap: () => _toggleQuickGenre(slug),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentMuted
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (isSelected) ...[
                                  const Icon(Icons.check,
                                      size: 14, color: AppColors.accent),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Active Filter Chips Bar (if multiple genres selected)
                  if (_selectedGenreSlugs.isNotEmpty &&
                      _searchController.text.isEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ..._selectedGenreSlugs.map((slug) {
                          return Chip(
                            label: Text(_getGenreName(slug)),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => _toggleQuickGenre(slug),
                            backgroundColor: AppColors.accentMuted,
                            side: const BorderSide(color: AppColors.accentBorder),
                            labelStyle: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }),
                        ActionChip(
                          label: const Text('Hapus Semua'),
                          onPressed: _clearAllGenres,
                          backgroundColor: AppColors.surfaceMuted,
                          side: const BorderSide(color: AppColors.border),
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Continue Watching Card (if history exists)
                  if (_latestHistory != null)
                    ContinueWatchingCard(item: _latestHistory!),

                  // Section Title & Filter Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? 'Hasil Pencarian: "${_searchController.text}"'
                              : _selectedGenreSlugs.isEmpty
                                  ? 'Anime Tren & Populer'
                                  : 'Filter Genre: ${_selectedGenreSlugs.map(_getGenreName).join(" + ")}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        )
                      else
                        Text(
                          '${_animeList.length} Anime',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Anime Grid or Loading/Empty State
          if (_isLoading && _animeList.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.accent,
                ),
              ),
            )
          else if (_animeList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada anime yang cocok',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedGenreSlugs.isNotEmpty
                            ? 'Coba kurangi kombinasi genre yang dipilih atau ganti kata kunci.'
                            : 'Pastikan ejaan judul sudah benar atau coba cari genre lain.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _clearAllGenres,
                        child: const Text('Reset Filter & Tampilkan Semua'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final anime = _animeList[index];
                    return AnimeCard(anime: anime);
                  },
                  childCount: _animeList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
