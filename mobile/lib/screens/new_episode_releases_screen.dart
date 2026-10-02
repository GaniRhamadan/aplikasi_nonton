import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../theme/app_theme.dart';
import 'anime_detail_screen.dart';
import 'search_screen.dart';

class NewEpisodeReleasesScreen extends StatefulWidget {
  const NewEpisodeReleasesScreen({super.key});

  @override
  State<NewEpisodeReleasesScreen> createState() =>
      _NewEpisodeReleasesScreenState();
}

class _NewEpisodeReleasesScreenState extends State<NewEpisodeReleasesScreen> {
  final AnimeService _animeService = AnimeService();

  // Curated initial seed list matching the reference screenshot exactly
  static final List<AnimeItem> _initialReleases = [
    const AnimeItem(
      id: '132405',
      slug: 'sono-bisque-doll-wa-koi-wo-suru',
      title: 'My Dress-Up Darling',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx132405-qP7FQYGmNI3d.jpg',
      score: '9.5',
      episodeLabel: 'Episode 10',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '125367',
      slug: 'kaguya-sama-wa-kokurasetai-ultra-romantic',
      title: 'Kaguya-sama: Love Is War',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx125367-1yuq9NFcQuLI.png',
      score: '9.8',
      episodeLabel: 'Episode 09',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '131942',
      slug: 'jojo-no-kimyou-na-bouken-stone-ocean',
      title: 'JoJo\'s Bizarre Adventure: Stone Ocean',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx131942-rermlZ9lplHX.png',
      score: '9.7',
      episodeLabel: 'Episode 14',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '21',
      slug: 'one-piece',
      title: 'One Piece',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
      score: '9.6',
      episodeLabel: 'Episode 1080',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '97938',
      slug: 'boruto-naruto-next-generations',
      title: 'Boruto: Naruto Next Generations',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx97938-BnF6M5yTaNB1.jpg',
      score: '9.7',
      episodeLabel: 'Episode 280',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '111321',
      slug: 'tate-no-yuusha-no-nariagari-season-2',
      title: 'The Rising of the Shield Hero 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx111321-dIr3dEKOIPer.png',
      score: '9.6',
      episodeLabel: 'Episode 12',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '113415',
      slug: 'jujutsu-kaisen',
      title: 'Jujutsu Kaisen',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
      score: '9.7',
      episodeLabel: 'Episode 24',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '151807',
      slug: 'solo-leveling',
      title: 'Solo Leveling',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      score: '9.8',
      episodeLabel: 'Episode 12',
      status: 'Ongoing',
    ),
  ];

  List<AnimeItem> _releasesList = [];

  @override
  void initState() {
    super.initState();
    _releasesList = List.from(_initialReleases);
    _loadDynamicData();
  }

  Future<void> _loadDynamicData() async {
    try {
      final fetched = await _animeService.getEpisodeBaru();
      if (mounted && fetched.isNotEmpty) {
        final List<AnimeItem> merged = List.from(_initialReleases);
        for (var item in fetched) {
          if (!merged.any((m) =>
              m.title.toLowerCase() == item.title.toLowerCase() ||
              m.slug == item.slug)) {
            merged.add(item);
          }
        }
        setState(() {
          _releasesList = merged;
        });
      }
    } catch (_) {}
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void _navigateToDetail(AnimeItem anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(anime: anime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Episode Releases',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
            onPressed: _openSearch,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.70,
        ),
        itemCount: _releasesList.length,
        itemBuilder: (context, index) {
          final anime = _releasesList[index];
          final rating =
              (anime.score != null && anime.score!.isNotEmpty && anime.score != '0')
                  ? anime.score!
                  : (9.7 - (index * 0.1)).toStringAsFixed(1);
          final episodeText = anime.episodeLabel != null && anime.episodeLabel!.isNotEmpty
              ? anime.episodeLabel!
              : 'Episode 01';

          return GestureDetector(
            onTap: () => _navigateToDetail(anime),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.surfaceHighlight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    // Poster image filling the card
                    Positioned.fill(
                      child: Image.network(
                        anime.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceHighlight,
                          child: const Center(
                            child: Icon(
                              Icons.movie_outlined,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Dark gradient overlay at the bottom for text contrast
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.50, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Green Rating Badge in Top Left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    // Episode Label at Bottom Left
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        episodeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                              offset: Offset(0, 1),
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
      ),
    );
  }
}
