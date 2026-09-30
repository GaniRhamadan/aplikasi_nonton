import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'anime_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<AnimeItem> _bookmarks = [];
  List<AnimeItem> _filteredBookmarks = [];
  String _selectedGenre = 'Semua';
  bool _isSwitchOn = true;
  bool _isSortAscending = false;

  final List<String> _genres = [
    'Semua',
    'Action',
    'Adventure',
    'Comedy',
    'Demons',
    'Drama',
    'Fantasy',
    'Romance',
    'Sci-Fi',
    'Supernatural',
  ];

  static const List<AnimeItem> _seedFavorites = [
    AnimeItem(
      id: '21242',
      slug: 'hatsukoi-monster-21242',
      title: 'Hatsukoi Monster',
      genreLabel: 'Comedy',
      genres: ['Comedy', 'Romance'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21242-5lHHNLFBsVB3.jpg',
      views: '8.784 views',
      favorites: '2.016 favorites',
    ),
    AnimeItem(
      id: '151252',
      slug: 'koori-zokusei-danshi-to-cool-na-douryou-151252',
      title: 'Koori Zokusei Danshi to Cool na Douryou',
      genreLabel: 'Comedy',
      genres: ['Comedy', 'Romance', 'Fantasy'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151252-ywrMmJG1Loc3.jpg',
      views: '58.115 views',
      favorites: '8.571 favorites',
    ),
    AnimeItem(
      id: '6098',
      slug: 'sora-no-manimani-6098',
      title: 'Sora no Manimani (At The Mercy of the Sky)',
      genreLabel: 'Comedy',
      genres: ['Comedy', 'Romance'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx6098-GfPxtwnEsDAx.jpg',
      views: '7.124 views',
      favorites: '1.589 favorites',
    ),
    AnimeItem(
      id: '147103',
      slug: 'watashi-no-shiawase-na-kekkon-147103',
      title: 'Watashi no Shiawase na Kekkon',
      genreLabel: 'Drama',
      genres: ['Drama', 'Romance', 'Fantasy'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx147103-Om2LOXlhHNAe.png',
      views: '103.594 views',
      favorites: '8.129 favorites',
    ),
    AnimeItem(
      id: '101922',
      slug: 'violet-evergarden-the-movie-101922',
      title: 'Violet Evergarden: The Movie',
      genreLabel: 'Drama',
      genres: ['Drama', 'Fantasy'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21827-ubzq619ZA2E9.png',
      views: '18.488 views',
      favorites: '5.674 favorites',
    ),
    AnimeItem(
      id: '21827',
      slug: 'violet-evergarden-21827',
      title: 'Violet Evergarden',
      genreLabel: 'Drama',
      genres: ['Drama', 'Slice of Life'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21827-ubzq619ZA2E9.png',
      views: '108.485 views',
      favorites: '11.870 favorites',
    ),
    AnimeItem(
      id: '124080',
      slug: 'horimiya-124080',
      title: 'Horimiya',
      genreLabel: 'Comedy',
      genres: ['Comedy', 'Romance'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx124080-3i22mRVPBS0T.jpg',
      views: '95.234 views',
      favorites: '14.280 favorites',
    ),
    AnimeItem(
      id: '137281',
      slug: 'aharen-san-wa-hakarenai-137281',
      title: 'Aharen-san wa Hakarenai',
      genreLabel: 'Comedy',
      genres: ['Comedy', 'Slice of Life'],
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx137281-i4UHcGkUi7j6.jpg',
      views: '32.419 views',
      favorites: '4.112 favorites',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final list = StorageService.getBookmarks();
    setState(() {
      _bookmarks = list.isNotEmpty ? list : _seedFavorites;
      _applyFilter();
    });
  }

  void _applyFilter() {
    List<AnimeItem> results = List.from(_bookmarks);

    if (_selectedGenre != 'Semua') {
      results = results.where((anime) {
        final matchesGenreList = anime.genres
            .any((g) => g.toLowerCase() == _selectedGenre.toLowerCase());
        final matchesGenreLabel = anime.genreLabel
                ?.toLowerCase()
                .contains(_selectedGenre.toLowerCase()) ??
            false;
        return matchesGenreList || matchesGenreLabel;
      }).toList();
    }

    if (_isSortAscending) {
      results.sort((a, b) => a.title.compareTo(b.title));
    } else {
      results.sort((a, b) => b.title.compareTo(a.title));
    }

    setState(() {
      _filteredBookmarks = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Orange mini switch
            GestureDetector(
              onTap: () {
                setState(() => _isSwitchOn = !_isSwitchOn);
              },
              child: Container(
                width: 38,
                height: 20,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _isSwitchOn ? AppColors.accent : const Color(0xFF2E3242),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                      _isSwitchOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Title with orange underline indicator (matching screenshot 1)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Favorit',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 44,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Sort 1/9 icon
          IconButton(
            icon: Icon(
              Icons.swap_vert_rounded,
              color: _isSortAscending ? AppColors.accent : AppColors.textSecondary,
              size: 22,
            ),
            tooltip: 'Urutkan',
            onPressed: () {
              setState(() {
                _isSortAscending = !_isSortAscending;
                _applyFilter();
              });
            },
          ),
          // Grid icon
          IconButton(
            icon: Icon(
              Icons.grid_view_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          // 1. Horizontal Genre Filter Pills (matching screenshot 1)
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _genres.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenre == genre;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedGenre = genre;
                      _applyFilter();
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : const Color(0xFF381E18),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.accent
                            : const Color(0xFFE56A48),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // 2. Story Highlight Avatars row (matching screenshot 1)
          if (_bookmarks.isNotEmpty) ...[
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _bookmarks.take(12).length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final anime = _bookmarks[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimeDetailScreen(anime: anime),
                        ),
                      ).then((_) => _loadFavorites());
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.5),
                            width: 1.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: anime.posterUrl.isNotEmpty
                            ? Image.network(
                                anime.posterUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                  color: AppColors.surfaceMuted,
                                  child: Icon(Icons.movie,
                                      color: AppColors.textMuted, size: 20),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceMuted,
                                child: Icon(Icons.movie,
                                    color: AppColors.textMuted, size: 20),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3. 3-Column Anime Grid (matching screenshot 1)
          if (_filteredBookmarks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bookmark_outline_rounded,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      _selectedGenre == 'Semua'
                          ? 'Belum ada anime favorit'
                          : 'Tidak ada favorit genre $_selectedGenre',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.41,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 14,
                ),
                itemCount: _filteredBookmarks.length,
                itemBuilder: (context, index) {
                  final anime = _filteredBookmarks[index];
                  final history =
                      StorageService.getHistoryForAnime(anime.id, anime.slug);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimeDetailScreen(anime: anime),
                        ),
                      ).then((_) => _loadFavorites());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster with smooth rounded corners (matching screenshot 1)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 0.70,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                anime.posterUrl.isNotEmpty
                                    ? Image.network(
                                        anime.posterUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: AppColors.surfaceMuted,
                                          child: Icon(
                                              Icons.movie_filter_rounded,
                                              color: AppColors.textMuted),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.surfaceMuted,
                                        child: Icon(
                                            Icons.movie_filter_rounded,
                                            color: AppColors.textMuted),
                                      ),

                                // Watched badge overlay (Sampai Ep. X)
                                if (history != null)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Ep. ${history.episodeNumber}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Mini bottom progress bar
                                if (history != null)
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
                                                history.totalEpisodes > 0)
                                            ? (history.episodeNumber /
                                                    (anime.totalEpisodes > 0
                                                        ? anime.totalEpisodes
                                                        : history.totalEpisodes))
                                                .clamp(0.08, 1.0)
                                            : 0.5,
                                        child: Container(
                                            color: AppColors.accent),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Genre in Orange (matching screenshot 1)
                        Text(
                          history != null
                              ? 'Sampai Ep. ${history.episodeNumber}'
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

                        // Title
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

                        // Red Views
                        Row(
                          children: [
                            const Icon(Icons.play_circle_fill_rounded,
                                size: 11, color: AppColors.viewsRed),
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
                        const SizedBox(height: 2),

                        // Yellow Favorites
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: AppColors.favYellow),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                anime.formattedFavorites,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.favYellow,
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
                },
              ),
            ),
        ],
      ),
    );
  }
}
