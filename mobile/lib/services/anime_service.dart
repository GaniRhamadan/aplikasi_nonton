import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_models.dart';

class AnimeService {
  static const String baseApi = 'https://hianime.at';
  static const Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  /// Curated popular spotlight anime for instant discovery
  static const List<AnimeItem> curatedAnime = [
    AnimeItem(
      id: '235',
      slug: 'solo-leveling-235',
      title: 'Solo Leveling',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/151807-37yfQA3ym8PA.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      synopsis:
          'In a world where hunters must battle deadly monsters to protect humanity, Sung Jinwoo, notoriously known as the weakest hunter of all mankind, finds himself in a struggle for survival.',
    ),
    AnimeItem(
      id: '84',
      slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
      title: 'Solo Leveling Season 2: Arise from the Shadow',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/151807-37yfQA3ym8PA.jpg',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      synopsis:
          'The continuation of Sung Jinwoo journey as the Shadow Monarch, facing greater dungeons and uncovering the origin of the System.',
    ),
    AnimeItem(
      id: '100',
      slug: 'one-piece-100',
      title: 'One Piece',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/21-wf37VakJmZqs.jpg',
      subEpisodes: 1122,
      dubEpisodes: 1100,
      totalEpisodes: 1122,
      type: 'TV',
      synopsis:
          'Monkey D. Luffy embarks on a grand adventure with his pirate crew across the Grand Line in search of the legendary treasure known as One Piece.',
    ),
    AnimeItem(
      id: '502',
      slug: 'jujutsu-kaisen-2nd-season-502',
      title: 'Jujutsu Kaisen Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/113415-jQBSkxWAAk83.jpg',
      subEpisodes: 23,
      dubEpisodes: 23,
      totalEpisodes: 23,
      type: 'TV',
      synopsis:
          'Follows the past of Satoru Gojo and Suguru Geto during their days at Tokyo Jujutsu High, and the cataclysmic Shibuya Incident.',
    ),
    AnimeItem(
      id: '320',
      slug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
      title: 'Demon Slayer: Hashira Training Arc',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/101922-33MtJGsUSxga.jpg',
      subEpisodes: 8,
      dubEpisodes: 8,
      totalEpisodes: 8,
      type: 'TV',
      synopsis:
          'Tanjiro undergoes rigorous training under the highest-ranking swordsmen of the Demon Slayer Corps, the Hashira, preparing for the upcoming final battle.',
    ),
    AnimeItem(
      id: '710',
      slug: 'dandadan-710',
      title: 'DanDaDan',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/171018-60q1B6GK2Ghb.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      synopsis:
          'High schoolers Momo Ayase, who believes in ghosts, and Okarun, who believes in aliens, find themselves entangled in bizarre supernatural occurrences.',
    ),
  ];

  static const List<Map<String, String>> allGenres = [
    {'name': 'Semua', 'slug': ''},
    {'name': 'Action', 'slug': 'action'},
    {'name': 'Action & Adventure', 'slug': 'action-adventure'},
    {'name': 'Action, Adventure, Supernatural', 'slug': 'action-adventure-supernatural'},
    {'name': 'Adult Cast', 'slug': 'adult-cast'},
    {'name': 'Adventure', 'slug': 'adventure'},
    {'name': 'Animation', 'slug': 'animation'},
    {'name': 'Anthropomorphic', 'slug': 'anthropomorphic'},
    {'name': 'Avant Garde', 'slug': 'avant-garde'},
    {'name': 'Award Winning', 'slug': 'award-winning'},
    {'name': 'Boys Love', 'slug': 'boys-love'},
    {'name': 'Cars', 'slug': 'cars'},
    {'name': 'CGDCT', 'slug': 'cgdct'},
    {'name': 'Childcare', 'slug': 'childcare'},
    {'name': 'Combat Sports', 'slug': 'combat-sports'},
    {'name': 'Comedy', 'slug': 'comedy'},
    {'name': 'Crossdressing', 'slug': 'crossdressing'},
    {'name': 'Delinquents', 'slug': 'delinquents'},
    {'name': 'Dementia', 'slug': 'dementia'},
    {'name': 'Demons', 'slug': 'demons'},
    {'name': 'Detective', 'slug': 'detective'},
    {'name': 'Drama', 'slug': 'drama'},
    {'name': 'Drama, Action & Adventure, Animation', 'slug': 'drama-action-adventure-animation'},
    {'name': 'Ecchi', 'slug': 'ecchi'},
    {'name': 'Educational', 'slug': 'educational'},
    {'name': 'Erotica', 'slug': 'erotica'},
    {'name': 'Fantasy', 'slug': 'fantasy'},
    {'name': 'Gag Humor', 'slug': 'gag-humor'},
    {'name': 'Game', 'slug': 'game'},
    {'name': 'Girls Love', 'slug': 'girls-love'},
    {'name': 'Gore', 'slug': 'gore'},
    {'name': 'Gourmet', 'slug': 'gourmet'},
    {'name': 'Harem', 'slug': 'harem'},
    {'name': 'Hentai', 'slug': 'hentai'},
    {'name': 'High Stakes Game', 'slug': 'high-stakes-game'},
    {'name': 'Historical', 'slug': 'historical'},
    {'name': 'Horror', 'slug': 'horror'},
    {'name': 'Idols (Female)', 'slug': 'idols-female'},
    {'name': 'Idols (Male)', 'slug': 'idols-male'},
    {'name': 'Isekai', 'slug': 'isekai'},
    {'name': 'Iyashikei', 'slug': 'iyashikei'},
    {'name': 'Josei', 'slug': 'josei'},
    {'name': 'Kids', 'slug': 'kids'},
    {'name': 'Love Polygon', 'slug': 'love-polygon'},
    {'name': 'Love Status Quo', 'slug': 'love-status-quo'},
    {'name': 'Magic', 'slug': 'magic'},
    {'name': 'Magical Sex Shift', 'slug': 'magical-sex-shift'},
    {'name': 'Mahou Shoujo', 'slug': 'mahou-shoujo'},
    {'name': 'Martial Arts', 'slug': 'martial-arts'},
    {'name': 'Mecha', 'slug': 'mecha'},
    {'name': 'Medical', 'slug': 'medical'},
    {'name': 'Military', 'slug': 'military'},
    {'name': 'Music', 'slug': 'music'},
    {'name': 'Mystery', 'slug': 'mystery'},
    {'name': 'Mythology', 'slug': 'mythology'},
    {'name': 'Organized Crime', 'slug': 'organized-crime'},
    {'name': 'Otaku Culture', 'slug': 'otaku-culture'},
    {'name': 'Parody', 'slug': 'parody'},
    {'name': 'Performing Arts', 'slug': 'performing-arts'},
    {'name': 'Pets', 'slug': 'pets'},
    {'name': 'Police', 'slug': 'police'},
    {'name': 'Psychological', 'slug': 'psychological'},
    {'name': 'Racing', 'slug': 'racing'},
    {'name': 'Reincarnation', 'slug': 'reincarnation'},
    {'name': 'Reverse Harem', 'slug': 'reverse-harem'},
    {'name': 'Romance', 'slug': 'romance'},
    {'name': 'Samurai', 'slug': 'samurai'},
    {'name': 'School', 'slug': 'school'},
    {'name': 'Sci-Fi', 'slug': 'sci-fi'},
    {'name': 'Sci-Fi & Fantasy', 'slug': 'sci-fi-fantasy'},
    {'name': 'Seinen', 'slug': 'seinen'},
    {'name': 'Shoujo', 'slug': 'shoujo'},
    {'name': 'Shoujo Ai', 'slug': 'shoujo-ai'},
    {'name': 'Shounen', 'slug': 'shounen'},
    {'name': 'Shounen Ai', 'slug': 'shounen-ai'},
    {'name': 'Showbiz', 'slug': 'showbiz'},
    {'name': 'Slice of Life', 'slug': 'slice-of-life'},
    {'name': 'Space', 'slug': 'space'},
    {'name': 'Sports', 'slug': 'sports'},
    {'name': 'Strategy Game', 'slug': 'strategy-game'},
    {'name': 'Supernatural', 'slug': 'supernatural'},
    {'name': 'Super Power', 'slug': 'super-power'},
    {'name': 'Survival', 'slug': 'survival'},
    {'name': 'Suspense', 'slug': 'suspense'},
    {'name': 'Team Sports', 'slug': 'team-sports'},
    {'name': 'Thriller', 'slug': 'thriller'},
    {'name': 'Time Travel', 'slug': 'time-travel'},
    {'name': 'Unknown', 'slug': 'unknown'},
    {'name': 'Urban Fantasy', 'slug': 'urban-fantasy'},
    {'name': 'Vampire', 'slug': 'vampire'},
    {'name': 'Video Game', 'slug': 'video-game'},
    {'name': 'Villainess', 'slug': 'villainess'},
    {'name': 'Visual Arts', 'slug': 'visual-arts'},
    {'name': 'Workplace', 'slug': 'workplace'},
  ];

  /// Search anime using HiAnime scraping endpoint
  Future<List<AnimeItem>> searchAnime(String query, {int page = 1}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return getPopularAnime();

    try {
      final url = Uri.parse(
          '$baseApi/search?keyword=${Uri.encodeQueryComponent(cleanQuery)}&page=$page');
      final response = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return _parseSearchHtml(response.body);
      }
    } catch (_) {}

    return curatedAnime
        .where((a) => a.title.toLowerCase().contains(cleanQuery.toLowerCase()))
        .toList();
  }

  /// In-memory cache for anime genres to make repeated lookups instant
  static final Map<String, Set<String>> _animeGenreCache = {};


  /// Check whether an anime's genre set satisfies a required genre slug
  static bool _matchesGenre(Set<String> animeGenres, String requiredSlug) {
    final req = requiredSlug.toLowerCase().trim();
    final reqClean = req.replaceAll('-', '').replaceAll(' ', '');

    for (final g in animeGenres) {
      final gNorm = g.toLowerCase().trim();
      final gClean = gNorm.replaceAll('-', '').replaceAll(' ', '');

      if (gNorm == req || gClean == reqClean) return true;

      // Handle common aliases or compound sub-genres
      if (req == 'harem' && (gNorm == 'harem' || gNorm == 'reverse-harem')) {
        return true;
      }
      if (req == 'video-game' && (gNorm == 'video-game' || gNorm == 'game')) {
        return true;
      }
      if (req == 'game' && (gNorm == 'video-game' || gNorm == 'game')) {
        return true;
      }
      if (req == 'martial-arts' &&
          (gNorm == 'martial-arts' || gNorm == 'combat-sports')) {
        return true;
      }
    }
    return false;
  }

  /// Get verified genres for an anime ID using HiAnime qtip API
  Future<Set<String>> getAnimeGenres(String animeId) async {
    final cleanId = animeId.contains('-')
        ? (RegExp(r'-(\d+)$').firstMatch(animeId)?.group(1) ?? animeId)
        : animeId;

    if (_animeGenreCache.containsKey(cleanId)) {
      return _animeGenreCache[cleanId]!;
    }

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final url = Uri.parse('$baseApi/api/theme/anime/qtip?animeId=$cleanId');
        final response = await http
            .get(url, headers: defaultHeaders)
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final html = data['html']?.toString() ?? '';
          final genreMatches =
              RegExp(r'href="[^"]*\/genres\/([^"]+)"').allMatches(html);

          final Set<String> genres = {};
          for (final m in genreMatches) {
            final slug = m.group(1)?.toLowerCase().trim();
            if (slug != null && slug.isNotEmpty) {
              genres.add(slug);
            }
          }

          if (genres.isNotEmpty) {
            _animeGenreCache[cleanId] = genres;
            return genres;
          }
        }
      } catch (_) {}
    }

    return const {};
  }

  /// Fetch candidate anime list from a specific endpoint
  Future<List<AnimeItem>> _fetchCandidatesFromUrl(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: defaultHeaders)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return _parseSearchHtml(response.body);
      }
    } catch (_) {}
    return const [];
  }

  static final Map<String, String> _genreNameMap = {
    for (final g in allGenres) (g['slug'] ?? ''): (g['name'] ?? ''),
  };

  /// Get anime matching selected genres.
  /// Fetches candidates across all selected genres concurrently,
  /// placing exact multi-genre matches at the top, followed by all anime matching any searched genre.
  Future<List<AnimeItem>> getAnimeByGenres(List<String> genreSlugs,
      {int page = 1}) async {
    final validSlugs = genreSlugs
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty && s != 'semua')
        .toList();

    if (validSlugs.isEmpty) {
      return getPopularAnime();
    }

    if (validSlugs.length == 1) {
      return getAnimeByGenre(validSlugs.first, page: page);
    }

    try {
      // 1. Fetch pages concurrently for all selected genres (page 1 + page 2 for depth)
      final List<Future<List<AnimeItem>>> fetchTasks = [];
      for (final slug in validSlugs) {
        fetchTasks.add(_fetchCandidatesFromUrl('$baseApi/genres/$slug?page=$page'));
        if (page == 1) {
          fetchTasks.add(_fetchCandidatesFromUrl('$baseApi/genres/$slug?page=2'));
        }
      }

      final fetchResults = await Future.wait(fetchTasks);

      // 2. Track anime and matched genres
      final Map<String, AnimeItem> animeMap = {};
      final Map<String, Set<String>> animeGenreHits = {};

      for (int i = 0; i < fetchResults.length; i++) {
        final slugIndex = (page == 1) ? (i ~/ 2) : i;
        final slug = validSlugs[slugIndex];
        final list = fetchResults[i];

        for (final item in list) {
          final key = item.id.isNotEmpty ? item.id : item.slug;
          animeMap[key] = item;
          animeGenreHits.putIfAbsent(key, () => <String>{}).add(slug);
        }
      }

      // 3. For candidates that only appeared in 1 genre feed, verify with qtip API
      // to see if their full genre list also contains other searched genres
      final candidatesToCheck = animeMap.values
          .where((item) {
            final key = item.id.isNotEmpty ? item.id : item.slug;
            return (animeGenreHits[key]?.length ?? 0) < validSlugs.length;
          })
          .take(30)
          .toList();

      if (candidatesToCheck.isNotEmpty) {
        try {
          final genreFutures = candidatesToCheck.map((a) => getAnimeGenres(a.id));
          final fetchedGenres = await Future.wait(genreFutures)
              .timeout(const Duration(seconds: 4));

          for (int i = 0; i < fetchedGenres.length; i++) {
            final fullGenres = fetchedGenres[i];
            final item = candidatesToCheck[i];
            final key = item.id.isNotEmpty ? item.id : item.slug;

            for (final s in validSlugs) {
              if (_matchesGenre(fullGenres, s)) {
                animeGenreHits[key]?.add(s);
              }
            }
          }
        } catch (_) {}
      }

      // 4. Sort anime by hit count descending (exact multi-matches first),
      // preserving popularity order within same hit count
      final allItems = animeMap.values.toList();
      allItems.sort((a, b) {
        final keyA = a.id.isNotEmpty ? a.id : a.slug;
        final keyB = b.id.isNotEmpty ? b.id : b.slug;
        final hitsA = animeGenreHits[keyA]?.length ?? 0;
        final hitsB = animeGenreHits[keyB]?.length ?? 0;
        return hitsB.compareTo(hitsA);
      });

      // 5. Update items with clear genre labels
      final List<AnimeItem> enrichedItems = allItems.map((item) {
        final key = item.id.isNotEmpty ? item.id : item.slug;
        final matched = animeGenreHits[key] ?? {};
        final readableMatched = matched.map((s) => _genreNameMap[s] ?? s).toList();
        final label = readableMatched.isNotEmpty
            ? readableMatched.join(', ')
            : item.genreLabel;
        return item.copyWith(
          genreLabel: label,
          genres: matched.toList(),
        );
      }).toList();

      if (enrichedItems.isNotEmpty) {
        return enrichedItems;
      }
    } catch (_) {}

    return getPopularAnime();
  }

  /// Get anime by single genre slug from HiAnime (loads up to 2 pages for page 1)
  Future<List<AnimeItem>> getAnimeByGenre(String genreSlug, {int page = 1}) async {
    final slug = genreSlug.trim().toLowerCase();
    if (slug.isEmpty || slug == 'semua') {
      return getPopularAnime();
    }

    try {
      final List<Future<http.Response>> requests = [
        http
            .get(Uri.parse('$baseApi/genres/$slug?page=$page'),
                headers: defaultHeaders)
            .timeout(const Duration(seconds: 10)),
      ];
      if (page == 1) {
        requests.add(
          http
              .get(Uri.parse('$baseApi/genres/$slug?page=2'),
                  headers: defaultHeaders)
              .timeout(const Duration(seconds: 10)),
        );
      }

      final responses = await Future.wait(requests);
      final List<AnimeItem> results = [];
      final Set<String> seen = {};

      for (final resp in responses) {
        if (resp.statusCode == 200) {
          final items = _parseSearchHtml(resp.body);
          for (final item in items) {
            final key = item.id.isNotEmpty ? item.id : item.slug;
            if (seen.add(key)) {
              results.add(item);
            }
          }
        }
      }

      if (results.isNotEmpty) return results;
    } catch (_) {}

    // Fallback to /filter?genre[]=$slug
    try {
      final filterUrl = Uri.parse(
          '$baseApi/filter?genre%5B%5D=${Uri.encodeQueryComponent(slug)}&page=$page');
      final response = await http
          .get(filterUrl, headers: defaultHeaders)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final results = _parseSearchHtml(response.body);
        if (results.isNotEmpty) return results;
      }
    } catch (_) {}

    return getPopularAnime();
  }

  /// Get live recently updated and popular anime list
  Future<List<AnimeItem>> getPopularAnime() async {
    try {
      final url = Uri.parse('$baseApi/recently-updated');
      final response = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final parsed = _parseSearchHtml(response.body);
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (_) {}

    try {
      final url = Uri.parse('$baseApi/top-airing');
      final response = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final parsed = _parseSearchHtml(response.body);
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (_) {}

    return curatedAnime;
  }

  /// Parse search HTML page
  static List<AnimeItem> _parseSearchHtml(String html) {
    final List<AnimeItem> items = [];
    final itemRegex = RegExp(
      r'<div class="flw-item[^"]*">([\s\S]*?)<div class="clearfix"><\/div>',
      multiLine: true,
    );

    final matches = itemRegex.allMatches(html);
    for (final match in matches) {
      final block = match.group(1) ?? '';

      // Title & Slug
      final titleMatch = RegExp(
        r'<h3 class="film-name">\s*<a href="[^"]*\/([^"\/]+)"\s*title="([^"]+)"',
      ).firstMatch(block);

      if (titleMatch == null) continue;
      final slug = titleMatch.group(1) ?? '';
      var title = titleMatch.group(2) ?? '';
      title = _decodeHtmlEntities(title);

      // Extract ID from slug (e.g., "solo-leveling-235" -> "235")
      final idMatch = RegExp(r'-(\d+)$').firstMatch(slug);
      final id = idMatch?.group(1) ?? slug;

      // Poster
      final posterMatch =
          RegExp(r'<img[^>]+src="([^"]+)"[^>]+class="film-poster-img"').firstMatch(block);
      final posterUrl = posterMatch?.group(1) ?? '';

      // Sub / Dub / Eps count
      final subMatch =
          RegExp(r'class="[^"]*tick-sub[^"]*">.*?(\d+)<\/div>').firstMatch(block);
      final dubMatch =
          RegExp(r'class="[^"]*tick-dub[^"]*">.*?(\d+)<\/div>').firstMatch(block);
      final epsMatch =
          RegExp(r'class="[^"]*tick-eps[^"]*">.*?(\d+)<\/div>').firstMatch(block);

      final subCount = int.tryParse(subMatch?.group(1) ?? '0') ?? 0;
      final dubCount = int.tryParse(dubMatch?.group(1) ?? '0') ?? 0;
      final epsCount = int.tryParse(epsMatch?.group(1) ?? '0') ?? subCount;

      items.add(AnimeItem(
        id: id,
        slug: slug,
        title: title,
        posterUrl: posterUrl,
        subEpisodes: subCount,
        dubEpisodes: dubCount,
        totalEpisodes: epsCount,
      ));
    }

    return items;
  }

  /// Get episode list for an anime ID
  Future<List<EpisodeItem>> getEpisodes(String animeId, String animeSlug) async {
    // If animeId has slug prefix, extract numeric ID
    final numericId = animeId.contains('-')
        ? (RegExp(r'-(\d+)$').firstMatch(animeId)?.group(1) ?? animeId)
        : animeId;

    try {
      final url = Uri.parse('$baseApi/api/theme/episode/list/$numericId');
      final response = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final html = decoded['html'] ?? response.body;

        final List<EpisodeItem> episodes = [];
        final epRegex = RegExp(
          r'class="[^"]*ep-item[^"]*"\s+data-number="([^"]+)"\s+data-id="([^"]+)"[\s\S]*?<div class="ep-name[^"]*"\s+[^>]*title="([^"]*)"',
        );

        final matches = epRegex.allMatches(html);
        for (final m in matches) {
          final epNo = int.tryParse(m.group(1) ?? '1') ?? 1;
          final epId = m.group(2) ?? '';
          var epTitle = m.group(3) ?? 'Episode $epNo';
          epTitle = _decodeHtmlEntities(epTitle);

          episodes.add(EpisodeItem(
            id: epId,
            number: epNo,
            title: epTitle.isEmpty ? 'Episode $epNo' : epTitle,
            slug: animeSlug,
          ));
        }

        if (episodes.isNotEmpty) {
          // Sort by episode number
          episodes.sort((a, b) => a.number.compareTo(b.number));
          return episodes;
        }
      }
    } catch (_) {}

    // Fallback: Generate sequential episode entries if network issue
    return List.generate(
      12,
      (index) => EpisodeItem(
        id: 'ep_${index + 1}',
        number: index + 1,
        title: 'Episode ${index + 1}',
        slug: animeSlug,
      ),
    );
  }

  /// Get all available stream servers for an episode, prioritized by speed (HD-1 fast CDN first)
  Future<List<StreamServerItem>> getStreamServers(String episodeId,
      {bool isDub = false}) async {
    try {
      final url =
          Uri.parse('$baseApi/api/theme/episode/servers?episodeId=$episodeId');
      final response = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final html = decoded['html'] ?? '';

        final targetType = isDub ? 'dub' : 'sub';
        final serverRegex = RegExp(
          r'data-type="([^"]+)"[^>]*data-server-name="([^"]+)"[^>]*data-hash="([^"]+)"',
        );

        final List<StreamServerItem> servers = [];
        final matches = serverRegex.allMatches(html);

        for (final m in matches) {
          final type = m.group(1) ?? 'sub';
          final name = m.group(2) ?? 'Server';
          final hash = m.group(3) ?? '';

          if (type == targetType) {
            try {
              final embedUrl = utf8.decode(base64.decode(hash));
              servers.add(StreamServerItem(
                name: name,
                type: type,
                embedUrl: embedUrl,
              ));
            } catch (_) {}
          }
        }

        // If preferred audio type has no servers, fallback to all available
        if (servers.isEmpty) {
          for (final m in matches) {
            final type = m.group(1) ?? 'sub';
            final name = m.group(2) ?? 'Server';
            final hash = m.group(3) ?? '';
            try {
              final embedUrl = utf8.decode(base64.decode(hash));
              servers.add(StreamServerItem(
                name: name,
                type: type,
                embedUrl: embedUrl,
              ));
            } catch (_) {}
          }
        }

        // Sort so the fastest CDN servers (HD-1, HD-2, Vidstream) are primary
        servers.sort((a, b) {
          int priority(String n) {
            final lower = n.toLowerCase();
            if (lower.contains('hd-1')) return 1;
            if (lower.contains('hd-2')) return 2;
            if (lower.contains('vidstream')) return 3;
            if (lower.contains('zoko')) return 4;
            return 5;
          }

          return priority(a.name).compareTo(priority(b.name));
        });

        return servers;
      }
    } catch (_) {}
    return const [];
  }

  /// Extract direct HLS master.m3u8 stream from ZokoAnime embed page for external native player
  Future<String?> getDirectM3u8Stream(String zokoEmbedUrl) async {
    try {
      final response = await http.get(
        Uri.parse(zokoEmbedUrl),
        headers: {
          ...defaultHeaders,
          'Referer': 'https://hianime.at/',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final blobMatch =
            RegExp(r'window\.__P="([^"]+)"').firstMatch(response.body);
        if (blobMatch != null) {
          final blob = blobMatch.group(1) ?? '';
          final rawBytes = base64.decode(blob);
          const key = 'otaku-embed-v1';
          final keyBytes = key.codeUnits;
          final deobf = List<int>.filled(rawBytes.length, 0);
          for (int i = 0; i < rawBytes.length; i++) {
            deobf[i] = rawBytes[i] ^ keyBytes[i % keyBytes.length];
          }
          final jsonString = utf8.decode(deobf);
          final data = json.decode(jsonString);
          final src = data['src']?.toString();
          if (src != null && src.isNotEmpty) {
            return src;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Get stream servers and embed player URL (HD-1 fast CDN by default)
  Future<String?> getStreamEmbedUrl(String episodeId,
      {bool isDub = false}) async {
    final servers = await getStreamServers(episodeId, isDub: isDub);
    if (servers.isNotEmpty) {
      return servers.first.embedUrl;
    }
    return null;
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&#039;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  /// 1. Sedang Hangat (Trending Spotlight Banners)
  Future<List<AnimeItem>> getSedangHangat() async {
    return const [
      AnimeItem(
        id: '1',
        slug: 'one-piece-1',
        title: 'One Piece',
        genreLabel: 'Action, Adventure, Comedy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
        bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/21-wf37VakJmZqs.jpg',
        views: '15.747.141 views',
        favorites: '38.427 favorites',
        subEpisodes: 1122,
        totalEpisodes: 1122,
      ),
      AnimeItem(
        id: '84',
        slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
        title: 'Solo Leveling Season 2',
        genreLabel: 'Action, Fantasy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
        bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/151807-37yfQA3ym8PA.jpg',
        views: '12.894.210 views',
        favorites: '34.120 favorites',
        subEpisodes: 13,
        totalEpisodes: 13,
      ),
      AnimeItem(
        id: '5',
        slug: 'bleach-thousand-year-blood-war-the-calamity-5',
        title: 'Bleach: Thousand-Year Blood War',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
        bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/269-08ar2HJOUAuL.jpg',
        views: '9.450.219 views',
        favorites: '29.810 favorites',
        subEpisodes: 26,
        totalEpisodes: 26,
      ),
      AnimeItem(
        id: '415',
        slug: 'jujutsu-kaisen-season-2-415',
        title: 'Jujutsu Kaisen 2nd Season',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
        bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/113415-jQBSkxWAAk83.jpg',
        views: '14.215.890 views',
        favorites: '36.520 favorites',
        subEpisodes: 23,
        totalEpisodes: 23,
      ),
    ];
  }

  /// 2. Lanjut Nonton (Continue Watching list)
  Future<List<AnimeItem>> getLanjutNonton() async {
    return const [
      AnimeItem(
        id: '4990',
        slug: 'the-ice-guy-and-his-cool-female-colleague-4990',
        title: 'Koori Zokusei Danshi to Cool na Douryou',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151252-ywrMmJG1Loc3.jpg',
        bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/151252-8bTZKJBAzgMR.jpg',
        episodeLabel: 'Episode 4',
        views: '58.115 views',
        favorites: '8.571 favorites',
        subEpisodes: 12,
      ),
      AnimeItem(
        id: '6512',
        slug: 'sora-no-manimani-6512',
        title: 'Sora no Manimani (At the Mercy of the Sky)',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx6098-GfPxtwnEsDAx.jpg',
        episodeLabel: 'Episode 12',
        views: '7.123 views',
        favorites: '1.589 favorites',
        subEpisodes: 12,
      ),
      AnimeItem(
        id: '49520',
        slug: 'aharen-san-wa-hakarenai-49520',
        title: 'Aharen-san wa Hakarenai',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx137281-i4UHcGkUi7j6.jpg',
        episodeLabel: 'Episode 1',
        views: '245 views',
        favorites: '163 favorites',
        subEpisodes: 12,
      ),
    ];
  }

  /// 3. Cuplix Story Avatars (matching Screenshot 1)
  List<CuplixItem> getCuplixItems() {
    return const [
      CuplixItem(
        id: 'c1',
        title: 'Koori Zokusei',
        imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151252-ywrMmJG1Loc3.jpg',
        animeSlug: 'the-ice-guy-and-his-cool-female-colleague-4990',
      ),
      CuplixItem(
        id: 'c2',
        title: 'Sora no Mani',
        imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx6098-GfPxtwnEsDAx.jpg',
        animeSlug: 'sora-no-manimani-6512',
      ),
      CuplixItem(
        id: 'c3',
        title: 'Aharen-san',
        imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx137281-i4UHcGkUi7j6.jpg',
        animeSlug: 'aharen-san-wa-hakarenai-49520',
      ),
      CuplixItem(
        id: 'c4',
        title: 'One Piece',
        imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
        animeSlug: 'one-piece-1',
      ),
      CuplixItem(
        id: 'c5',
        title: 'Solo Leveling',
        imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
        animeSlug: 'solo-leveling-season-2-arise-from-the-shadow-84',
      ),
      CuplixItem(
        id: 'c6',
        title: 'Violet',
        imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21827-ubzq619ZA2E9.png',
        animeSlug: 'violet-evergarden',
      ),
    ];
  }

  /// 4. Episode Baru (New Episodes matching Screenshot 1 & 2)
  Future<List<AnimeItem>> getEpisodeBaru() async {
    try {
      final url = Uri.parse('$baseApi/recently-updated');
      final res = await http.get(url, headers: defaultHeaders).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final live = _parseSearchHtml(res.body);
        if (live.isNotEmpty) {
          return live.take(12).map((item) {
            return item.copyWith(
              episodeLabel: 'Episode ${item.subEpisodes > 0 ? item.subEpisodes : 1}',
            );
          }).toList();
        }
      }
    } catch (_) {}

    return const [
      AnimeItem(
        id: '20381',
        slug: 'lian-qi-shi-wan-nian-20381',
        title: 'Lian Qi Shi Wan Nian',
        genreLabel: 'Action',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
        episodeLabel: 'Episode 381',
        views: '142.113 views',
        favorites: '1.729 favorites',
      ),
      AnimeItem(
        id: '18487',
        slug: 'wan-jie-du-zun-18487',
        title: 'Wan Jie Du Zun',
        genreLabel: 'Action',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
        episodeLabel: 'Episode 487',
        views: '51.763 views',
        favorites: '1.040 favorites',
      ),
      AnimeItem(
        id: '16695',
        slug: 'wushen-zhuzai-16695',
        title: 'Wushen Zhuzai (God of War)',
        genreLabel: 'Action',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
        episodeLabel: 'Episode 695',
        views: '76.489 views',
        favorites: '1.392 favorites',
      ),
      AnimeItem(
        id: '1',
        slug: 'one-piece-1',
        title: 'One Piece',
        genreLabel: 'Action',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
        episodeLabel: 'Episode 1122',
        views: '15.747.141 views',
        favorites: '38.427 favorites',
      ),
    ];
  }

  /// 5. Jadwal Hari ini (matching Screenshot 2 with new !! badge)
  Future<List<AnimeItem>> getJadwalHariIni() async {
    try {
      final url = Uri.parse('$baseApi/top-airing');
      final res = await http.get(url, headers: defaultHeaders).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final live = _parseSearchHtml(res.body);
        if (live.isNotEmpty) {
          return live.take(10).map((i) => i.copyWith(isNew: true)).toList();
        }
      }
    } catch (_) {}

    return const [
      AnimeItem(
        id: '20381',
        slug: 'lian-qi-shi-wan-nian-20381',
        title: 'Lian Qi Shi Wan Nian',
        genreLabel: 'Action',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
        views: '142.113 views',
        favorites: '1.729 favorites',
        isNew: true,
      ),
      AnimeItem(
        id: '18487',
        slug: 'wan-jie-du-zun-18487',
        title: 'Wan Jie Du Zun',
        genreLabel: 'Action',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
        views: '51.763 views',
        favorites: '1.040 favorites',
        isNew: true,
      ),
      AnimeItem(
        id: '16695',
        slug: 'wushen-zhuzai-16695',
        title: 'Wushen Zhuzai',
        genreLabel: 'Action',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
        views: '76.489 views',
        favorites: '1.392 favorites',
        isNew: true,
      ),
    ];
  }

  /// 6. Jas Por Yu (Featured Just For You banner + card matching Screenshot 2)
  Future<AnimeItem> getJasPorYu() async {
    return const AnimeItem(
      id: '154587',
      slug: 'sousou-no-frieren-154587',
      title: 'Sousou no Frieren',
      genreLabel: 'Adventure, Drama, Fantasy',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
      bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/154587-ivXNJ23SM1xB.jpg',
      views: '18.420.500 views',
      favorites: '54.210 favorites',
      subEpisodes: 28,
      totalEpisodes: 28,
    );
  }

  /// 7. Judul Baru (New Titles matching Screenshot 4 with Release Date)
  Future<List<AnimeItem>> getJudulBaru() async {
    return const [
      AnimeItem(
        id: '171018',
        slug: 'dandadan-171018',
        title: 'DanDaDan',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
        releaseDate: '2026-10-05',
        favorites: '40.210 favorites',
      ),
      AnimeItem(
        id: '147103',
        slug: 'watashi-no-shiawase-na-kekkon-147103',
        title: 'Watashi no Shiawase na Kekkon',
        genreLabel: 'Drama, Romance',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx147103-Om2LOXlhHNAe.png',
        releaseDate: '2026-10-14',
        favorites: '15.400 favorites',
      ),
      AnimeItem(
        id: '21827',
        slug: 'violet-evergarden-21827',
        title: 'Violet Evergarden',
        genreLabel: 'Drama, Slice of Life',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21827-ubzq619ZA2E9.png',
        releaseDate: '2026-10-03',
        favorites: '10.890 favorites',
      ),
    ];
  }

  /// 8. Paling Dinanti / Anime Yang Akan Datang (Upcoming Anime)
  Future<List<AnimeItem>> getPalingDinanti() async {
    return getAkanDatang();
  }

  Future<List<AnimeItem>> getAkanDatang() async {
    return const [
      AnimeItem(
        id: '151807',
        slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
        title: 'Solo Leveling: Arise from the Shadow',
        genreLabel: 'Action, Fantasy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
        releaseDate: 'Fall 2026',
        favorites: '48.210 favorites',
        statusBadge: 'Segera',
        isNew: true,
      ),
      AnimeItem(
        id: '171018',
        slug: 'dandadan-710',
        title: 'DanDaDan Season 2',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
        releaseDate: 'Winter 2027',
        favorites: '38.900 favorites',
        statusBadge: '2027',
        isNew: true,
      ),
      AnimeItem(
        id: '124080',
        slug: 'chainsaw-man-124080',
        title: 'Chainsaw Man: Reze Arc Movie',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx124080-3i22mRVPBS0T.jpg',
        releaseDate: 'Film 2026',
        favorites: '52.410 favorites',
        statusBadge: 'Movie',
        isNew: true,
      ),
      AnimeItem(
        id: '269',
        slug: 'bleach-thousand-year-blood-war-the-calamity-5',
        title: 'Bleach: Thousand-Year Blood War Pt. 3',
        genreLabel: 'Action, Shounen',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
        releaseDate: 'Musim Depan',
        favorites: '31.420 favorites',
        statusBadge: 'Segera',
        isNew: true,
      ),
      AnimeItem(
        id: '113415',
        slug: 'jujutsu-kaisen-2nd-season-502',
        title: 'Jujutsu Kaisen: Culling Game',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
        releaseDate: 'TBA 2027',
        favorites: '64.120 favorites',
        statusBadge: 'TBA',
        isNew: true,
      ),
      AnimeItem(
        id: '101922',
        slug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
        title: 'Demon Slayer: Infinity Castle Arc',
        genreLabel: 'Action, Fantasy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
        releaseDate: 'Trilogi Film',
        favorites: '58.910 favorites',
        statusBadge: 'Movie',
        isNew: true,
      ),
      AnimeItem(
        id: '154587',
        slug: 'sousou-no-frieren-154587',
        title: 'Sousou no Frieren Season 2',
        genreLabel: 'Adventure, Fantasy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
        releaseDate: 'Musim Baru',
        favorites: '49.120 favorites',
        statusBadge: 'Segera',
        isNew: true,
      ),
      AnimeItem(
        id: '21',
        slug: 'one-piece-100',
        title: 'One Piece: Arc Elbaf',
        genreLabel: 'Action, Adventure',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
        releaseDate: '2026',
        favorites: '72.300 favorites',
        statusBadge: 'New Arc',
        isNew: true,
      ),
    ];
  }

  /// 9. Paling Populer (All Time / Season Most Popular matching Screenshot 3)
  Future<List<AnimeItem>> getPalingPopuler() async {
    try {
      final url = Uri.parse('$baseApi/most-popular');
      final res = await http.get(url, headers: defaultHeaders).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final live = _parseSearchHtml(res.body);
        if (live.isNotEmpty) return live;
      }
    } catch (_) {}

    return const [
      AnimeItem(
        id: '1',
        slug: 'one-piece-1',
        title: 'One Piece',
        genreLabel: 'Action, Adventure, Comedy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
        views: '15.747.141 views',
        favorites: '38.427 favorites',
      ),
      AnimeItem(
        id: '113415',
        slug: 'jujutsu-kaisen-113415',
        title: 'Jujutsu Kaisen',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
        views: '14.215.890 views',
        favorites: '36.520 favorites',
      ),
      AnimeItem(
        id: '151807',
        slug: 'solo-leveling-151807',
        title: 'Solo Leveling',
        genreLabel: 'Action, Fantasy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
        views: '12.894.210 views',
        favorites: '34.120 favorites',
      ),
      AnimeItem(
        id: '154587',
        slug: 'sousou-no-frieren-154587',
        title: 'Sousou no Frieren',
        genreLabel: 'Adventure, Drama, Fantasy',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
        views: '10.354.120 views',
        favorites: '28.910 favorites',
      ),
      AnimeItem(
        id: '101922',
        slug: 'demon-slayer-101922',
        title: 'Demon Slayer: Kimetsu no Yaiba',
        genreLabel: 'Action, Supernatural',
        posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
        views: '11.890.340 views',
        favorites: '31.450 favorites',
      ),
    ];
  }
}
