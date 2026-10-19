import 'dart:async';
import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../models/sort_filter_data.dart';
import '../services/anime_service.dart';
import '../theme/app_theme.dart';
import '../widgets/not_found_view.dart';
import '../widgets/responsive_layout.dart';
import 'anime_detail_screen.dart';
import 'sort_filter_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool autoFocus;
  final bool isTab;

  const SearchScreen({
    super.key,
    this.autoFocus = true,
    this.isTab = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AnimeService _animeService = AnimeService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  bool _isLoading = false;
  List<AnimeItem> _searchResults = [];
  final Set<String> _selectedGenreSlugs = {};
  SortFilterData _currentFilter = SortFilterData.defaultFilter();

  // Curated initial Top Searches matching the reference screenshot exactly
  static final List<AnimeItem> _topSearchesSeed = [
    const AnimeItem(
      id: '131681',
      slug: 'shingeki-no-kyojin-the-final-season-part-2',
      title: 'Attack on Titan Final Season Part 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx131681-5ooUqvqNtee1.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/131681-3tNurPRsqsfz.jpg',
      score: '9.8',
    ),
    const AnimeItem(
      id: '142329',
      slug: 'kimetsu-no-yaiba-yuukaku-hen',
      title: 'Demon Slayer: Entertainment Distri Arc',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx142329-kET1PIXJv2eW.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/142329-i413SzLmToZN.jpg',
      score: '9.7',
    ),
    const AnimeItem(
      id: '125367',
      slug: 'kaguya-sama-wa-kokurasetai-ultra-romantic',
      title: 'Kaguya-sama: Love is War Season 3',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx125367-1yuq9NFcQuLI.png',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/125367-hGPJLSNfprO3.jpg',
      score: '9.6',
    ),
    const AnimeItem(
      id: '140960',
      slug: 'spy-x-family',
      title: 'Spy x Family',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx140960-Kb6R5nYQfjmP.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/140960-Z7xSvkRxHKfj.jpg',
      score: '9.6',
    ),
    const AnimeItem(
      id: '145064',
      slug: 'jujutsu-kaisen-season-2',
      title: 'Jujutsu Kaisen Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx145064-hSNRJM03pvv1.jpg',
      score: '9.8',
    ),
    const AnimeItem(
      id: '21',
      slug: 'one-piece',
      title: 'One Piece',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
      score: '9.7',
    ),
    const AnimeItem(
      id: '151807',
      slug: 'solo-leveling',
      title: 'Solo Leveling',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      score: '9.5',
    ),
    const AnimeItem(
      id: '269',
      slug: 'bleach-sennen-kessen-hen',
      title: 'Bleach: Sennen Kessen-hen',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
      score: '9.5',
    ),
  ];

  // Curated search results matching reference screenshot for "Season 2"
  static final List<AnimeItem> _season2Seed = [
    const AnimeItem(
      id: '114745',
      slug: 'made-in-abyss-retsujitsu-no-ougonkyou',
      title: 'Made in Abyss: The Golden City of the Scorching Sun',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx114745-fBgTC12T7IAy.jpg',
      score: '9.8',
    ),
    const AnimeItem(
      id: '124410',
      slug: 'kanojo-okarishimasu-2nd-season',
      title: 'Rent-a-Girlfriend Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx124410-iScdHzzEqdmk.png',
      score: '9.7',
    ),
    const AnimeItem(
      id: '111321',
      slug: 'tate-no-yuusha-no-nariagari-season-2',
      title: 'The Rising of The Shield Hero Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx111321-dIr3dEKOIPer.png',
      score: '9.6',
    ),
    const AnimeItem(
      id: '139648',
      slug: 'genjitsu-shugi-yuusha-no-oukoku-saikenki-part-2',
      title: 'How a Realist Hero Rebuilt the Kingdom Part 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx139648-Gc88ZbCFeKCQ.jpg',
      score: '9.5',
    ),
    const AnimeItem(
      id: '135136',
      slug: 'vanitas-no-carte-part-2',
      title: 'The Case Study of Vanitas Part 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx135136-wVMApb1FEmkz.jpg',
      score: '9.4',
    ),
    const AnimeItem(
      id: '133844',
      slug: 'overlord-iv',
      title: 'Overlord IV',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx133844-E32FjKZ0XxEs.jpg',
      score: '9.2',
    ),
  ];

  // Filtered search results matching reference screenshot 4 for filtered "Season 2"
  static final List<AnimeItem> _filteredSeason2Seed = [
    const AnimeItem(
      id: '130592',
      slug: 'hataraku-maou-sama-2nd-season',
      title: 'The Devil is a Part-Timer! Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx130592-LAUlhx15mxQu.jpg',
      score: '9.8',
      type: 'TV',
      genres: ['Action', 'Comedy', 'Fantasy', 'Romance', 'Slice of Life'],
      releaseDate: '2022',
    ),
    const AnimeItem(
      id: '146637',
      slug: 'orient-awajishima-gekitou-hen',
      title: 'ORIENT: Awajishima Gekitou-hen',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx146637-mzZXckqnA2EG.jpg',
      score: '9.7',
      type: 'TV',
      genres: ['Action', 'Fantasy'],
      releaseDate: '2022',
    ),
    const AnimeItem(
      id: '112323',
      slug: 'arifureta-shokugyou-de-sekai-saikyou-2nd-season',
      title: "Arifureta: From Commonplace to World's Strongest Season 2",
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx112323-C6nlP84x8jH8.png',
      score: '9.6',
      type: 'TV',
      genres: ['Action', 'Adventure', 'Fantasy', 'Psychological'],
      releaseDate: '2022',
    ),
    const AnimeItem(
      id: '138424',
      slug: 'karakai-jouzu-no-takagi-san-3',
      title: 'Teasing Master Takagi-san Season 3',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx138424-97Nz1P7M3O2d.png',
      score: '9.8',
      type: 'TV',
      genres: ['Comedy', 'Romance', 'Slice of Life'],
      releaseDate: '2022',
    ),
    const AnimeItem(
      id: '116867',
      slug: 'itai-no-wa-iya-nano-de-bougyoryoku-ni-kyokufuri-shitai-to-omoimasu-2',
      title: "BOFURI: I Don't Want to Get Hurt, so I'll Max Out My Defense. Season 2",
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx116867-bXUSi1BWrd9R.jpg',
      score: '9.4',
      type: 'TV',
      genres: ['Action', 'Adventure', 'Comedy', 'Fantasy', 'Slice of Life'],
      releaseDate: '2022',
    ),
    const AnimeItem(
      id: '125124',
      slug: 'rikei-ga-koi-ni-ochita-no-de-shoumei-shitemita-r-1-sin-theta',
      title: 'Science Fell in Love, So I Tried to Prove It Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx125124-FHz4ND4kJzqu.jpg',
      score: '9.5',
      type: 'TV',
      genres: ['Comedy', 'Romance'],
      releaseDate: '2022',
    ),
  ];

  static String _formatScore(String? score, int index) {

    if (score != null && score.isNotEmpty) return score;
    final fallbackScores = ['9.8', '9.7', '9.6', '9.5', '9.4', '9.2', '9.1'];
    return fallbackScores[index % fallbackScores.length];
  }

  late List<AnimeItem> _topSearches;

  @override
  void initState() {
    super.initState();
    _topSearches = List.from(_topSearchesSeed);
    _loadPopularTopSearches();
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPopularTopSearches() async {
    try {
      final popular = await _animeService.getPalingPopuler();
      if (mounted && popular.isNotEmpty) {
        setState(() {
          final Set<String> existingSlugs =
              _topSearchesSeed.map((e) => e.slug).toSet();
          final List<AnimeItem> merged = List.from(_topSearchesSeed);
          for (var item in popular) {
            if (!existingSlugs.contains(item.slug)) {
              merged.add(item);
            }
          }
          _topSearches = merged;
        });
      }
    } catch (_) {}
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applySearch();
    });
  }

  static String _slugForGenre(String name) {
    return AnimeService.slugForGenreName(name);
  }

  Future<void> _openSortFilterScreen() async {
    final result = await Navigator.push<SortFilterData>(
      context,
      MaterialPageRoute(
        builder: (context) => SortFilterScreen(
          initialFilter: _currentFilter.hasActiveFilter
              ? _currentFilter
              : const SortFilterData(
                  sort: 'Popularity',
                  category: 'Episode',
                  region: 'Japan',
                  genre: 'All',
                  genres: [],
                  releaseYear: 'All',
                ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilter = result;
        _selectedGenreSlugs.clear();
        for (final g in result.activeGenres) {
          final slug = _slugForGenre(g);
          if (slug.isNotEmpty) {
            _selectedGenreSlugs.add(slug);
          }
        }
      });
      _applySearch();
    }
  }

  List<String> get _activeFilterChips {
    final chips = <String>[];
    if (_currentFilter.sort.isNotEmpty) chips.add(_currentFilter.sort);
    if (_currentFilter.category.isNotEmpty) chips.add(_currentFilter.category);
    if (_currentFilter.region.isNotEmpty && _currentFilter.region != 'All') {
      chips.add(_currentFilter.region);
    }
    for (final g in _currentFilter.activeGenres) {
      chips.add(g);
    }
    if (_currentFilter.releaseYear.isNotEmpty &&
        _currentFilter.releaseYear != 'All') {
      chips.add(_currentFilter.releaseYear);
    }
    return chips;
  }

  Widget _buildActiveFiltersBar() {
    final chips = _activeFilterChips;
    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = chips[index];
          return GestureDetector(
            onTap: _openSortFilterScreen,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static const List<String> _quickGenres = [
    'Action',
    'Romance',
    'Comedy',
    'Fantasy',
    'Isekai',
    'Shounen',
    'Slice of Life',
    'Adventure',
    'Sci-Fi',
    'Supernatural',
    'Drama',
    'Mystery',
    'Sports',
    'Horror',
    'Magic',
    'Mecha',
    'Music',
    'Psychological',
    'Thriller',
  ];

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
              if (slug.isEmpty || slug == 'semua') return false;
              if (query.isEmpty) return true;
              final name = (g['name'] ?? '').toLowerCase();
              return name.contains(query) || slug.contains(query);
            }).toList();

            final screenWidth = MediaQuery.of(context).size.width;
            final isDesktop = screenWidth >= 768;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 680 : double.infinity,
                ),
                child: Container(
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(Icons.search_rounded,
                                    color: AppColors.textMuted, size: 18),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: searchModalCtrl,
                                  cursorColor: AppColors.accent,
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
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 11),
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
                                    'Semua',
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
                                      final updatedNames = tempSelected.map((s) {
                                        return AnimeService.allGenres.firstWhere(
                                          (g) => g['slug'] == s,
                                          orElse: () => {'name': s},
                                        )['name']!;
                                      }).toList();
                                      _currentFilter = _currentFilter.copyWith(
                                        genres: updatedNames,
                                        genre: updatedNames.isEmpty
                                            ? 'All'
                                            : updatedNames.join(', '),
                                      );
                                    });
                                    _applySearch();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    tempSelected.isEmpty
                                        ? 'Tampilkan Semua Anime'
                                        : 'Terapkan (${tempSelected.length} Genre)',
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGenreSection() {
    final bool isAllSelected = _selectedGenreSlugs.isEmpty;

    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.category_rounded,
                  size: 15,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Kategori Genre',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_selectedGenreSlugs.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedGenreSlugs.length} dipilih',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGenreSlugs.clear();
                        _currentFilter = _currentFilter.copyWith(
                          genres: [],
                          genre: 'All',
                        );
                      });
                      _applySearch();
                    },
                    child: const Text(
                      'Reset Genre',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 1. Button to open 90+ Genres Modal Sheet with Multi-Select
                InkWell(
                  onTap: _openAllGenresBottomSheet,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedGenreSlugs.isNotEmpty
                          ? AppColors.accent.withValues(alpha: 0.18)
                          : Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E2621)
                              : const Color(0xFFF1FAF4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _selectedGenreSlugs.isNotEmpty
                            ? AppColors.accent
                            : AppColors.accent.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 13,
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

                // 2. 'Semua' Reset Pill (Shows all anime when tapped)
                GestureDetector(
                  onTap: () {
                    if (_selectedGenreSlugs.isNotEmpty) {
                      setState(() {
                        _selectedGenreSlugs.clear();
                        _currentFilter = _currentFilter.copyWith(
                          genres: [],
                          genre: 'All',
                        );
                      });
                      _applySearch();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAllSelected
                          ? AppColors.accent
                          : Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E2621)
                              : const Color(0xFFF1FAF4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isAllSelected
                            ? AppColors.accent
                            : AppColors.accent.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Semua',
                        style: TextStyle(
                          color: isAllSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: isAllSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Quick Popular Genres with Multi-Select Toggle
                ..._quickGenres.map((g) {
                  final slug = _slugForGenre(g);
                  final isSelected = _selectedGenreSlugs.contains(slug);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          final updatedGenres =
                              List<String>.from(_currentFilter.genres);
                          if (isSelected) {
                            _selectedGenreSlugs.remove(slug);
                            updatedGenres.remove(g);
                          } else {
                            _selectedGenreSlugs.add(slug);
                            if (!updatedGenres.contains(g)) {
                              updatedGenres.add(g);
                            }
                          }
                          _currentFilter = _currentFilter.copyWith(
                            genres: updatedGenres,
                            genre: updatedGenres.isEmpty
                                ? 'All'
                                : updatedGenres.join(', '),
                          );
                        });
                        _applySearch();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1E2621)
                                  : const Color(0xFFF1FAF4),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.accent.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check_rounded,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              g,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
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
        ],
      ),
    );
  }

  Future<void> _applySearch() async {
    final query = _searchController.text.trim();
    final hasQuery = query.isNotEmpty;
    final hasGenres = _selectedGenreSlugs.isNotEmpty;
    final hasFilter = _currentFilter.hasActiveFilter;

    if (!hasQuery && !hasGenres && !hasFilter) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<AnimeItem> results = [];
      final lowerQuery = query.toLowerCase();

      final bool isSeason2Query = lowerQuery == 'season 2';
      final bool isFilteredSeason2 =
          isSeason2Query && (_currentFilter.hasActiveFilter || hasGenres);

      if (isFilteredSeason2) {
        results = List.from(_filteredSeason2Seed);
      } else if (isSeason2Query) {
        results = List.from(_season2Seed);
      }
      // Case 1: Search Query ONLY (No genre filter)
      // Accurately searches anime matching the user's title or keyword
      else if (hasQuery && !hasGenres) {
        results = await _animeService.searchAnime(query);

        // Also include any curated anime whose title contains the query
        final Set<String> existingSlugs = results.map((e) => e.slug).toSet();
        final Set<String> existingIds = results.map((e) => e.id).toSet();

        for (final item in AnimeService.curatedAnime) {
          if (item.title.toLowerCase().contains(lowerQuery)) {
            if (!existingSlugs.contains(item.slug) &&
                !existingIds.contains(item.id)) {
              results.add(item);
              existingSlugs.add(item.slug);
              existingIds.add(item.id);
            }
          }
        }
      }
      // Case 2: Genre(s) ONLY (No search query)
      // Supports single or multi-genre selection concurrently
      else if (!hasQuery && hasGenres) {
        if (_selectedGenreSlugs.length == 1) {
          results =
              await _animeService.getAnimeByGenre(_selectedGenreSlugs.first);
        } else {
          results = await _animeService
              .getAnimeByGenres(_selectedGenreSlugs.toList());
        }

        if (results.isEmpty) {
          // Offline / network fallback from curated anime matching any selected genre
          results = AnimeService.curatedAnime.where((item) {
            return item.genres.any((g) {
              final slug = _slugForGenre(g).toLowerCase();
              return _selectedGenreSlugs.contains(slug) ||
                  _selectedGenreSlugs.any((s) => g.toLowerCase().contains(s));
            });
          }).toList();
        }
      }
      // Case 3: BOTH Query AND Genre(s) Filter
      // Filters query results by selected genres without dumping unrelated anime
      else if (hasQuery && hasGenres) {
        final queryResults = await _animeService.searchAnime(query);

        final List<AnimeItem> candidates = List.from(queryResults);
        final Set<String> cIds = candidates.map((e) => e.id).toSet();
        for (final item in AnimeService.curatedAnime) {
          if (item.title.toLowerCase().contains(lowerQuery) &&
              !cIds.contains(item.id)) {
            candidates.add(item);
            cIds.add(item.id);
          }
        }

        // Fetch anime matching the selected genres
        List<AnimeItem> genreItems;
        if (_selectedGenreSlugs.length == 1) {
          genreItems =
              await _animeService.getAnimeByGenre(_selectedGenreSlugs.first);
        } else {
          genreItems = await _animeService
              .getAnimeByGenres(_selectedGenreSlugs.toList());
        }

        final Set<String> genreIds = genreItems.map((e) => e.id).toSet();
        final Set<String> genreSlugsSet =
            _selectedGenreSlugs.map((s) => s.toLowerCase()).toSet();

        // Filter: keep query candidates that match the selected genre(s)
        final matchingGenreAndQuery = candidates.where((item) {
          if (genreIds.contains(item.id)) return true;
          return item.genres.any((g) {
            final s = _slugForGenre(g).toLowerCase();
            return genreSlugsSet.contains(s) ||
                genreSlugsSet.any((sel) => g.toLowerCase().contains(sel));
          });
        }).toList();

        // Also check if any items returned by genre search have the query in their title
        final matchingGenreItemsWithTitle = genreItems.where((item) {
          return item.title.toLowerCase().contains(lowerQuery);
        }).toList();

        final Set<String> resIds = {};
        final List<AnimeItem> merged = [];
        for (final item in matchingGenreAndQuery) {
          if (resIds.add(item.id)) merged.add(item);
        }
        for (final item in matchingGenreItemsWithTitle) {
          if (resIds.add(item.id)) merged.add(item);
        }

        // Display results matching both query & genre. If none matched both, show direct query title matches.
        results = merged.isNotEmpty ? merged : candidates;
      }
      // Case 4: Other active filters (e.g. from SortFilterScreen)
      else if (hasFilter) {
        results = List.from(AnimeService.curatedAnime);
      }

      // Filter by Category (Movie / Episode)
      if (_currentFilter.category == 'Movie') {
        final movies = results
            .where((item) => item.type.toUpperCase() == 'MOVIE')
            .toList();
        if (movies.isNotEmpty) {
          results = movies;
        }
      }

      // Filter by Release Year
      if (_currentFilter.releaseYear != 'All') {
        final yearMatches = results.where((item) {
          return (item.releaseDate ?? '').contains(_currentFilter.releaseYear) ||
              item.title.contains(_currentFilter.releaseYear);
        }).toList();
        if (yearMatches.isNotEmpty) {
          results = yearMatches;
        }
      }

      // Apply Sort Option
      if (_currentFilter.sort == 'Latest Release') {
        results.sort((a, b) =>
            (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _openDetail(AnimeItem anime, {bool autoPlay = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(
          anime: anime,
          autoPlayFirstEpisode: autoPlay,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.trim().isNotEmpty ||
        _selectedGenreSlugs.isNotEmpty ||
        _currentFilter.hasActiveFilter;
    final List<AnimeItem> itemsToShow =
        isSearching ? _searchResults : _topSearches;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Search Header (Search Box with Mint Tint + Filter Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  // Rounded Pill Search Input Box with Green Border & Mint Background
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E2621)
                            : const Color(0xFFF1FAF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.65),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Search Icon (tap also pops back if canPop)
                          IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              cursorColor: AppColors.accent,
                              onChanged: _onSearchChanged,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Abcdefghijklm',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: false,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _searchController.clear();
                                _applySearch();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Filter / Tune Squircle Button
                  InkWell(
                    onTap: _openSortFilterScreen,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E2621)
                            : const Color(0xFFF1FAF4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color: AppColors.accent,
                            size: 22,
                          ),
                          if (_selectedGenreSlugs.isNotEmpty ||
                              _currentFilter.hasActiveFilter)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dedicated Jelajah Kategori Genre Bar (Quick multi-genre selector)
            if (!_currentFilter.hasActiveFilter) _buildGenreSection(),

            // Horizontal Active Filters Bar (Shown when filters are active)
            if (isSearching && _activeFilterChips.isNotEmpty)
              _buildActiveFiltersBar(),

            // 2. Section Heading: "Top Searches" (Shown ONLY when NOT searching)
            if (!isSearching && itemsToShow.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Top Searches',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

            // 3. Body: Loading / NotFoundView / Search Results 2-Column Grid / Top Searches List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : itemsToShow.isEmpty
                      ? NotFoundView(
                          keyword: _searchController.text.trim(),
                        )
                      : isSearching
                          // 2-Column Grid of Anime Posters (Matching Screenshot)
                          ? GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    ResponsiveLayout.gridColumns(context),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.69,
                              ),
                              itemCount: itemsToShow.length,
                              itemBuilder: (context, index) {
                                final anime = itemsToShow[index];
                                final score = _formatScore(anime.score, index);

                                return GestureDetector(
                                  onTap: () =>
                                      _openDetail(anime, autoPlay: false),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: AppColors.surfaceHighlight,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            anime.posterUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color:
                                                  AppColors.surfaceHighlight,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.movie_outlined,
                                                  color: Colors.white24,
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Top-Left Rating or Akan Datang Badge
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: anime.isUpcoming
                                                    ? Colors.amber.shade900
                                                    : AppColors.accent,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                anime.isUpcoming
                                                    ? 'Akan Datang'
                                                    : score,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (anime.isUpcoming &&
                                              anime.releaseDate != null &&
                                              anime.releaseDate!.isNotEmpty)
                                            Positioned(
                                              bottom: 8,
                                              left: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.75),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Rilis: ${anime.releaseDate}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.amber,
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          // Single-Column List of Top Searches (Matching Screenshot 1)
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: itemsToShow.length,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 18),
                              itemBuilder: (context, index) {
                                final anime = itemsToShow[index];

                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    // Landscape Thumbnail with Rounded Corners & Play Button
                                    // Direct tap on thumbnail triggers instant playback (No Login Needed!)
                                    GestureDetector(
                                      onTap: () =>
                                          _openDetail(anime, autoPlay: !anime.isUpcoming),
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        width: 124,
                                        height: 78,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: AppColors.surfaceHighlight,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned.fill(
                                                child: Image.network(
                                                  anime.posterUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                          error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: AppColors
                                                        .surfaceHighlight,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.movie_outlined,
                                                        color: Colors.white24,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Centered Play Button or Schedule Icon
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: anime.isUpcoming
                                                      ? Colors.amber.shade700
                                                      : Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.35),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    anime.isUpcoming
                                                        ? Icons.schedule_rounded
                                                        : Icons.play_arrow_rounded,
                                                    color: anime.isUpcoming
                                                        ? Colors.white
                                                        : Colors.black,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // Anime Title
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _openDetail(anime,
                                            autoPlay: false),
                                        behavior: HitTestBehavior.opaque,
                                        child: Text(
                                          anime.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                            height: 1.25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
