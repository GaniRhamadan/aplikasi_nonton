import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/anime_models.dart';

class AnimeService {
  static const String baseApi = 'https://hianime.at';
  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  /// Curated popular spotlight anime for instant discovery
  static const List<AnimeItem> curatedAnime = [
    AnimeItem(
      id: '235',
      slug: 'solo-leveling-235',
      title: 'Solo Leveling',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/151807-37yfQA3ym8PA.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Adventure', 'Fantasy'],
      releaseDate: '2024',
      score: '9.8',
      synopsis: 'In a world where hunters must battle deadly monsters to protect humanity, Sung Jinwoo, notoriously known as the weakest hunter of all mankind, finds himself in a struggle for survival.',
    ),
    AnimeItem(
      id: '84',
      slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
      title: 'Solo Leveling Season 2: Arise from the Shadow',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/151807-37yfQA3ym8PA.jpg',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      genres: ['Action', 'Adventure', 'Fantasy'],
      releaseDate: '2025',
      score: '9.8',
      synopsis: 'The continuation of Sung Jinwoo journey as the Shadow Monarch, facing greater dungeons and uncovering the origin of the System.',
    ),
    AnimeItem(
      id: '100',
      slug: 'one-piece-100',
      title: 'One Piece',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
      bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/21-wf37VakJmZqs.jpg',
      subEpisodes: 1122,
      dubEpisodes: 1100,
      totalEpisodes: 1122,
      type: 'TV',
      genres: ['Action', 'Adventure', 'Comedy', 'Fantasy'],
      releaseDate: '1999',
      score: '9.9',
      synopsis: 'Monkey D. Luffy embarks on a grand adventure with his pirate crew across the Grand Line in search of the legendary treasure known as One Piece.',
    ),
    AnimeItem(
      id: '502',
      slug: 'jujutsu-kaisen-2nd-season-502',
      title: 'Jujutsu Kaisen Season 2',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
      bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/113415-jQBSkxWAAk83.jpg',
      subEpisodes: 23,
      dubEpisodes: 23,
      totalEpisodes: 23,
      type: 'TV',
      genres: ['Action', 'Fantasy', 'Supernatural'],
      releaseDate: '2023',
      score: '9.8',
      synopsis: 'Follows the past of Satoru Gojo and Suguru Geto during their days at Tokyo Jujutsu High, and the cataclysmic Shibuya Incident.',
    ),
    AnimeItem(
      id: '320',
      slug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
      title: 'Demon Slayer: Hashira Training Arc',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
      bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/101922-33MtJGsUSxga.jpg',
      subEpisodes: 8,
      dubEpisodes: 8,
      totalEpisodes: 8,
      type: 'TV',
      genres: ['Action', 'Fantasy', 'Supernatural'],
      releaseDate: '2024',
      score: '9.7',
      synopsis: 'Tanjiro undergoes rigorous training under the highest-ranking swordsmen of the Demon Slayer Corps, the Hashira, preparing for the upcoming final battle.',
    ),
    AnimeItem(
      id: '710',
      slug: 'dandadan-710',
      title: 'DanDaDan',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
      bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/171018-60q1B6GK2Ghb.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Comedy', 'Supernatural', 'Sci-Fi'],
      releaseDate: '2024',
      score: '9.6',
      synopsis: 'High schoolers Momo Ayase, who believes in ghosts, and Okarun, who believes in aliens, find themselves entangled in bizarre supernatural occurrences.',
    ),
    AnimeItem(
      id: '124410',
      slug: 'kanojo-okarishimasu-2nd-season',
      title: 'Rent-a-Girlfriend Season 2',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx124410-iScdHzzEqdmk.png',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Comedy', 'Romance'],
      releaseDate: '2022',
      score: '9.7',
      synopsis: 'Kazuya Kinoshita continues his complicated relationship with rental girlfriend Chizuru Mizuhara.',
    ),
    AnimeItem(
      id: '125367',
      slug: 'kaguya-sama-wa-kokurasetai-ultra-romantic',
      title: 'Kaguya-sama: Love is War - Ultra Romantic',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx125367-blf609eA9b2R.png',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      genres: ['Comedy', 'Romance', 'Psychological', 'Slice of Life'],
      releaseDate: '2022',
      score: '9.8',
      synopsis: 'The battle of wits between Kaguya Shinomiya and Miyuki Shirogane reaches its romantic climax.',
    ),
    AnimeItem(
      id: '140960',
      slug: 'spy-x-family',
      title: 'Spy x Family',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx140960-YrkSD4mrwAqv.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Comedy', 'Slice of Life'],
      releaseDate: '2022',
      score: '9.8',
      synopsis: 'A spy known as Twilight creates an unconventional family to complete a top-secret mission.',
    ),
    AnimeItem(
      id: '125124',
      slug: 'rikei-ga-koi-ni-ochita-no-de-shoumei-shitemita-r-1-sin-theta',
      title: 'Science Fell in Love, So I Tried to Prove It Season 2',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx125124-FHz4ND4kJzqu.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Comedy', 'Romance'],
      releaseDate: '2022',
      score: '9.5',
      synopsis: 'Two STEM graduate students attempt to quantify and prove love with rigorous scientific methods.',
    ),
    AnimeItem(
      id: '138424',
      slug: 'karakai-jouzu-no-takagi-san-3',
      title: 'Teasing Master Takagi-san Season 3',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx138424-97Nz1P7M3O2d.png',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Comedy', 'Romance', 'Slice of Life'],
      releaseDate: '2022',
      score: '9.8',
      synopsis: 'Nishikata continues his daily attempts to outwit the charming and clever Takagi-san.',
    ),
    AnimeItem(
      id: '116867',
      slug: 'itai-no-wa-iya-nano-de-bougyoryoku-ni-kyokufuri-shitai-to-omoimasu-2',
      title: "BOFURI: I Don't Want to Get Hurt, so I'll Max Out My Defense. Season 2",
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx116867-bXUSi1BWrd9R.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Adventure', 'Comedy', 'Fantasy', 'Slice of Life'],
      releaseDate: '2022',
      score: '9.4',
      synopsis: 'Maple and her guild explore new levels and obtain increasingly overpowered defensive abilities in NewWorld Online.',
    ),
    AnimeItem(
      id: '112323',
      slug: 'arifureta-shokugyou-de-sekai-saikyou-2nd-season',
      title: "Arifureta: From Commonplace to World's Strongest Season 2",
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx112323-C6nlP84x8jH8.png',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Adventure', 'Fantasy', 'Psychological'],
      releaseDate: '2022',
      score: '9.6',
      synopsis: 'Hajime and his party continue their perilous quest through the great labyrinths to return to Earth.',
    ),
    AnimeItem(
      id: '146637',
      slug: 'orient-awajishima-gekitou-hen',
      title: 'ORIENT: Awajishima Gekitou-hen',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx146637-mzZXckqnA2EG.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Fantasy'],
      releaseDate: '2022',
      score: '9.7',
      synopsis: 'Musashi and Kojiro join the Uesugi Bushidan on Awaji Island to confront terrifying demon gods.',
    ),
    AnimeItem(
      id: '130592',
      slug: 'hataraku-maou-sama-2nd-season',
      title: 'The Devil is a Part-Timer! Season 2',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx130592-LAUlhx15mxQu.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Comedy', 'Fantasy', 'Romance', 'Slice of Life'],
      releaseDate: '2022',
      score: '9.8',
      synopsis: 'Sadao Maou returns to flipped burgers at MgRonald while suddenly becoming a father figure to a mysterious girl from Ente Isla.',
    ),
  ];

  static const List<Map<String, String>> allGenres = [
    {'name': 'Semua', 'slug': ''},
    {'name': 'Action', 'slug': 'action'},
    {'name': 'Action & Adventure', 'slug': 'action-adventure'},
    {
      'name': 'Action, Adventure, Supernatural',
      'slug': 'action-adventure-supernatural',
    },
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
    {
      'name': 'Drama, Action & Adventure, Animation',
      'slug': 'drama-action-adventure-animation',
    },
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

  /// Get the HiAnime slug for a genre name
  static String slugForGenreName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'all' ||
        trimmed.toLowerCase() == 'semua') {
      return '';
    }
    final lower = trimmed.toLowerCase();
    for (final g in allGenres) {
      if ((g['name'] ?? '').toLowerCase() == lower) {
        return g['slug'] ?? '';
      }
    }
    return trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
  }

  /// Search anime using HiAnime scraping endpoint
  Future<List<AnimeItem>> searchAnime(String query, {int page = 1}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return getPopularAnime();

    try {
      final url = Uri.parse(
        '$baseApi/search?keyword=${Uri.encodeQueryComponent(cleanQuery)}&page=$page',
      );
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

  /// In-memory cache for full anime details
  static final Map<String, AnimeItem> _animeDetailsCache = {};

  /// Fallback curated pools segregated strictly by genre to ensure zero mismatch
  static const List<AnimeItem> _genrePoolRomance = [
    AnimeItem(
      id: '437',
      slug: 'kaguya-sama-love-is-war-1-437',
      title: 'Kaguya-sama: Love is War',
      posterUrl:
          'https://cdn.anipixcdn.co/thumbnail/kaguya-sama-love-is-war.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'School', 'Psychological'],
      score: '8.4',
      synopsis: 'At the renowned Shuchiin Academy, Miyuki Shirogane and Kaguya Shinomiya are the student body\'s top representatives. The two are too proud to confess their love first, turning romance into an all-out battle of wits.',
    ),
    AnimeItem(
      id: '15733',
      slug: 'horimiya-15733',
      title: 'Horimiya',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/horimiya.webp',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'School', 'Slice of Life'],
      score: '8.2',
      synopsis: 'Two high schoolers who appear very different at school discover each other\'s hidden sides outside class and form an unexpected bond.',
    ),
    AnimeItem(
      id: '204',
      slug: 'toradora-204',
      title: 'Toradora!',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/toradora.webp',
      subEpisodes: 25,
      dubEpisodes: 25,
      totalEpisodes: 25,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'School', 'Drama'],
      score: '8.1',
      synopsis: 'Ryuuji Takasu and Taiga Aisaka team up to help each other get closer to their respective best friends, only to discover their own deepening feelings.',
    ),
    AnimeItem(
      id: '123',
      slug: 'shigatsu-wa-kimi-no-uso-123',
      title: 'Your Lie in April',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/your-lie-in-april.webp',
      subEpisodes: 22,
      dubEpisodes: 22,
      totalEpisodes: 22,
      type: 'TV',
      genres: ['Romance', 'Drama', 'Music', 'School'],
      score: '8.6',
      synopsis: 'A piano prodigy who lost his ability to play after a personal tragedy finds his life transformed when he meets a free-spirited violinist named Kaori.',
    ),
    AnimeItem(
      id: '372',
      slug: 'rascal-does-not-dream-of-bunny-girl-senpai-372',
      title: 'Rascal Does Not Dream of Bunny Girl Senpai',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/bunny-girl-senpai.webp',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      genres: ['Romance', 'Supernatural', 'School', 'Drama'],
      score: '8.3',
      synopsis: 'Sakuta Azusagawa investigates the strange phenomenon known as Puberty Syndrome after spotting upperclassman actress Mai Sakurajima dressed as a bunny girl in a library.',
    ),
    AnimeItem(
      id: '17934',
      slug: 'sono-bisque-doll-wa-koi-wo-suru-17934',
      title: 'My Dress-Up Darling',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/my-dress-up-darling.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'Slice of Life'],
      score: '8.2',
      synopsis: 'High school doll craftsman Wakana Gojo bonds with the outgoing and popular Marin Kitagawa when she asks him to create cosplay costumes for her.',
    ),
    AnimeItem(
      id: '18342',
      slug: 'boku-no-kokoro-no-yabai-yatsu-18342',
      title: 'The Dangers in My Heart',
      posterUrl:
          'https://cdn.anipixcdn.co/thumbnail/the-dangers-in-my-heart.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'School'],
      score: '8.3',
      synopsis: 'Quiet and brooding Kyotaro Ichikawa harbors dark fantasies, but his perspective slowly changes as he gets to know the cheerful class idol Anna Yamada.',
    ),
    AnimeItem(
      id: '317',
      slug: 'kanojo-okarishimasu-317',
      title: 'Rent-a-Girlfriend',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/rent-a-girlfriend.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Romance', 'Comedy'],
      score: '7.3',
      synopsis: 'After being dumped by his girlfriend, college student Kazuya Kinoshita hires a rental girlfriend, Chizuru Mizuhara, leading to complicated romantic entanglements.',
    ),
    AnimeItem(
      id: '18237',
      slug: 'otonari-no-tenshi-sama-ni-itsunomanika-dame-ningen-ni-sareteita-ken-18237',
      title: 'The Angel Next Door Spoils Me Rotten',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/angel-next-door.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Romance', 'School', 'Slice of Life'],
      score: '7.9',
      synopsis: 'A heartfelt relationship blossoms between a self-neglectful student and Mahiru Shiina, the angelic and caring girl who lives in the apartment next door.',
    ),
    AnimeItem(
      id: '368',
      slug: 'tonikaku-kawaii-368',
      title: 'Tonikaku Kawaii: Fly Me to the Moon',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/tonikaku-kawaii.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'Slice of Life'],
      score: '7.9',
      synopsis: 'Nasa Yuzaki falls in love at first sight with Tsukasa and agrees to marry her immediately, embarking on a wholesome and heartwarming newlywed life.',
    ),
    AnimeItem(
      id: '722',
      slug: '5-toubun-no-hanayome-722',
      title: 'The Quintessential Quintuplets',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/quintuplets.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'School', 'Harem'],
      score: '7.6',
      synopsis: 'High school student Futaro Uesugi is hired as a private tutor for five identical sisters who are on the verge of failing school.',
    ),
    AnimeItem(
      id: '1277',
      slug: 'wotaku-ni-koi-wa-muzukashii-1277',
      title: 'Wotakoi: Love is Hard for Otaku',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/wotakoi.webp',
      subEpisodes: 11,
      dubEpisodes: 11,
      totalEpisodes: 11,
      type: 'TV',
      genres: ['Romance', 'Comedy', 'Workplace'],
      score: '7.9',
      synopsis: 'Four adult office workers balance their careers with their secret otaku hobbies and romantic relationships.',
    ),
  ];

  static const List<AnimeItem> _genrePoolAction = [
    AnimeItem(
      id: '235',
      slug: 'solo-leveling-235',
      title: 'Solo Leveling',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Adventure', 'Fantasy'],
      score: '8.4',
      synopsis: 'In a world where hunters battle monsters from mysterious gates, the weakest hunter Sung Jinwoo receives a unique system power that allows him to level up indefinitely.',
    ),
    AnimeItem(
      id: '502',
      slug: 'jujutsu-kaisen-2nd-season-502',
      title: 'Jujutsu Kaisen Season 2',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
      subEpisodes: 23,
      dubEpisodes: 23,
      totalEpisodes: 23,
      type: 'TV',
      genres: ['Action', 'Fantasy', 'Supernatural'],
      score: '8.8',
      synopsis: 'Explores the youth of Satoru Gojo and Suguru Geto, leading into the disastrous Shibuya Incident orchestrated by powerful cursed spirits.',
    ),
    AnimeItem(
      id: '320',
      slug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
      title: 'Demon Slayer: Hashira Training Arc',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
      subEpisodes: 8,
      dubEpisodes: 8,
      totalEpisodes: 8,
      type: 'TV',
      genres: ['Action', 'Fantasy', 'Supernatural'],
      score: '8.5',
      synopsis: 'Tanjiro and the Demon Slayer Corps undertake rigorous training under the formidable Hashira to prepare for the inevitable battle against Muzan Kibutsuji.',
    ),
    AnimeItem(
      id: '100',
      slug: 'one-piece-100',
      title: 'One Piece',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
      subEpisodes: 1122,
      dubEpisodes: 1100,
      totalEpisodes: 1122,
      type: 'TV',
      genres: ['Action', 'Adventure', 'Fantasy'],
      score: '8.9',
      synopsis: 'Monkey D. Luffy and his Straw Hat crew sail across dangerous oceans in search of the ultimate treasure known as the One Piece.',
    ),
    AnimeItem(
      id: '112',
      slug: 'attack-on-titan-112',
      title: 'Attack on Titan',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/attack-on-titan.webp',
      subEpisodes: 25,
      dubEpisodes: 25,
      totalEpisodes: 25,
      type: 'TV',
      genres: ['Action', 'Dark Fantasy', 'Drama'],
      score: '8.5',
      synopsis: 'Humanity lives within enormous walled cities to protect themselves from gigantic man-eating humanoids known as Titans.',
    ),
    AnimeItem(
      id: '18150',
      slug: 'bleach-thousand-year-blood-war-18150',
      title: 'Bleach: Thousand-Year Blood War',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/bleach-tybw.webp',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      genres: ['Action', 'Supernatural', 'Fantasy'],
      score: '9.0',
      synopsis: 'The Soul Reapers face an unprecedented invasion by the Quincy empire led by Yhwach in an all-out war for existence.',
    ),
    AnimeItem(
      id: '17406',
      slug: 'chainsaw-man-17406',
      title: 'Chainsaw Man',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/chainsaw-man.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Action', 'Supernatural', 'Dark Fantasy'],
      score: '8.5',
      synopsis: 'Denji makes a pact with a dog-like devil named Pochita, gaining the ability to transform into the lethal Chainsaw Man as a public safety devil hunter.',
    ),
    AnimeItem(
      id: '19125',
      slug: 'wind-breaker-19125',
      title: 'Wind Breaker',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/wind-breaker.webp',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      genres: ['Action', 'School', 'Delinquents'],
      score: '8.1',
      synopsis: 'Haruka Sakura enters Furin High, a school known for street-brawling delinquents who use their fighting skills to protect their local town.',
    ),
  ];

  static const List<AnimeItem> _genrePoolFantasy = [
    AnimeItem(
      id: '18418',
      slug: 'sousou-no-frieren-18418',
      title: 'Frieren: Beyond Journey\'s End',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/frieren.webp',
      subEpisodes: 28,
      dubEpisodes: 28,
      totalEpisodes: 28,
      type: 'TV',
      genres: ['Fantasy', 'Adventure', 'Drama'],
      score: '9.3',
      synopsis: 'An elven mage reflects on human mortality, relationships, and time as she embarks on a nostalgic journey decades after defeating the Demon King.',
    ),
    AnimeItem(
      id: '1748',
      slug: 'mushoku-tensei-isekai-ittara-honki-dasu-1748',
      title: 'Mushoku Tensei: Jobless Reincarnation',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/mushoku-tensei.webp',
      subEpisodes: 23,
      dubEpisodes: 23,
      totalEpisodes: 23,
      type: 'TV',
      genres: ['Fantasy', 'Isekai', 'Adventure', 'Drama'],
      score: '8.4',
      synopsis: 'A hopeless recluse reincarnates into a fantastical world as a newborn named Rudeus Greyrat, resolved to live this second life with zero regrets.',
    ),
    AnimeItem(
      id: '1785',
      slug: 'tensei-shitara-slime-datta-ken-1785',
      title: 'That Time I Got Reincarnated as a Slime',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/tensura.webp',
      subEpisodes: 24,
      dubEpisodes: 24,
      totalEpisodes: 24,
      type: 'TV',
      genres: ['Fantasy', 'Isekai', 'Adventure', 'Comedy'],
      score: '8.1',
      synopsis: 'Reincarnated as a slime in a fantasy world with the ability to absorb skills, Rimuru Tempest builds an inclusive federation for monsters and humans alike.',
    ),
    AnimeItem(
      id: '18182',
      slug: 'kage-no-jitsuryokusha-ni-naritakute-18182',
      title: 'The Eminence in Shadow',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/eminence-in-shadow.webp',
      subEpisodes: 20,
      dubEpisodes: 20,
      totalEpisodes: 20,
      type: 'TV',
      genres: ['Fantasy', 'Isekai', 'Action', 'Comedy'],
      score: '8.2',
      synopsis: 'Cid Kagenou roleplays as a mastermind operating from the shadows, completely oblivious that his fabricated conspiracies are actually real.',
    ),
    AnimeItem(
      id: '19119',
      slug: 'kono-subarashii-sekai-ni-shukufuku-wo-3-19119',
      title: 'KonoSuba: God\'s Blessing on This Wonderful World!',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/konosuba.webp',
      subEpisodes: 10,
      dubEpisodes: 10,
      totalEpisodes: 10,
      type: 'TV',
      genres: ['Fantasy', 'Isekai', 'Comedy', 'Adventure'],
      score: '8.2',
      synopsis: 'Kazuma Sato forms the most dysfunctional adventuring party in history with a useless goddess, an explosion-obsessed mage, and an unhinged crusader.',
    ),
    AnimeItem(
      id: '18544',
      slug: 'shangri-la-frontier-kusoge-hunter-kamige-ni-idoman-to-su-18544',
      title: 'Shangri-La Frontier',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/shangri-la-frontier.webp',
      subEpisodes: 25,
      dubEpisodes: 25,
      totalEpisodes: 25,
      type: 'TV',
      genres: ['Fantasy', 'Action', 'Adventure', 'Game'],
      score: '8.1',
      synopsis: 'A dedicated trash-tier VR game hunter challenges a wildly popular mainstream VRMMO using unconventional and high-risk playstyles.',
    ),
  ];

  static const List<AnimeItem> _genrePoolSports = [
    AnimeItem(
      id: '771',
      slug: 'haikyu-to-the-top-771',
      title: 'Haikyu!!',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/haikyuu.webp',
      subEpisodes: 25,
      dubEpisodes: 25,
      totalEpisodes: 25,
      type: 'TV',
      genres: ['Sports', 'School', 'Team Sports', 'Drama'],
      score: '8.7',
      synopsis: 'Determined to become a top volleyball player despite his short stature, Shoyo Hinata teams up with rival genius setter Tobio Kageyama at Karasuno High.',
    ),
    AnimeItem(
      id: '18151',
      slug: 'blue-lock-18151',
      title: 'Blue Lock',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/blue-lock.webp',
      subEpisodes: 24,
      dubEpisodes: 24,
      totalEpisodes: 24,
      type: 'TV',
      genres: ['Sports', 'Team Sports', 'Psychological'],
      score: '8.2',
      synopsis: 'Three hundred elite high school soccer strikers compete in an intense prison-like training facility designed to produce Japan\'s ultimate egoist striker.',
    ),
    AnimeItem(
      id: '40',
      slug: 'kuroko-no-basket-40',
      title: 'Kuroko\'s Basketball',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/kuroko-basket.webp',
      subEpisodes: 25,
      dubEpisodes: 25,
      totalEpisodes: 25,
      type: 'TV',
      genres: ['Sports', 'School', 'Team Sports'],
      score: '8.1',
      synopsis: 'Tetsuya Kuroko, the phantom sixth man of the legendary Generation of Miracles, joins Seirin High to defeat his former teammates.',
    ),
    AnimeItem(
      id: '17992',
      slug: 'aoashi-17992',
      title: 'Ao Ashi',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/ao-ashi.webp',
      subEpisodes: 24,
      dubEpisodes: 24,
      totalEpisodes: 24,
      type: 'TV',
      genres: ['Sports', 'Team Sports', 'School'],
      score: '8.2',
      synopsis: 'Rough-around-the-edges soccer talent Ashito Aoi is scouted for an elite Tokyo youth academy, where he must reinvent his tactical understanding of the sport.',
    ),
    AnimeItem(
      id: '61',
      slug: 'hajime-no-ippo-the-fighting-61',
      title: 'Hajime no Ippo: The Fighting!',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/hajime-no-ippo.webp',
      subEpisodes: 75,
      dubEpisodes: 75,
      totalEpisodes: 75,
      type: 'TV',
      genres: ['Sports', 'Combat Sports', 'Comedy'],
      score: '8.7',
      synopsis: 'Timid student Ippo Makunouchi discovers his natural punching power and dedication through professional boxing after being rescued from bullies.',
    ),
  ];

  static const List<AnimeItem> _genrePoolMystery = [
    AnimeItem(
      id: '60',
      slug: 'death-note-60',
      title: 'Death Note',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/death-note.webp',
      subEpisodes: 37,
      dubEpisodes: 37,
      totalEpisodes: 37,
      type: 'TV',
      genres: ['Mystery', 'Psychological', 'Supernatural', 'Thriller'],
      score: '8.6',
      synopsis: 'Brilliant student Light Yagami finds a supernatural notebook that kills anyone whose name is written in it, sparking a cat-and-mouse duel with detective L.',
    ),
    AnimeItem(
      id: '3',
      slug: 'steinsgate-3',
      title: 'Steins;Gate',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/steins-gate.webp',
      subEpisodes: 24,
      dubEpisodes: 24,
      totalEpisodes: 24,
      type: 'TV',
      genres: ['Sci-Fi', 'Psychological', 'Thriller', 'Mystery'],
      score: '9.0',
      synopsis: 'Eccentric scientist Rintaro Okabe accidentally discovers time travel through microwave-sent text messages, triggering horrifying butterfly-effect consequences.',
    ),
    AnimeItem(
      id: '14',
      slug: 'boku-dake-ga-inai-machi-14',
      title: 'ERASED',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/erased.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Mystery', 'Psychological', 'Supernatural', 'Thriller'],
      score: '8.3',
      synopsis: 'Satoru Fujinuma possesses a temporal rewind ability that sends him 18 years into the past to prevent the kidnapping and murder of his elementary school classmates.',
    ),
    AnimeItem(
      id: '18045',
      slug: 'summer-time-render-18045',
      title: 'Summer Time Rendering',
      posterUrl:
          'https://cdn.anipixcdn.co/thumbnail/summer-time-rendering.webp',
      subEpisodes: 25,
      dubEpisodes: 25,
      totalEpisodes: 25,
      type: 'TV',
      genres: ['Mystery', 'Supernatural', 'Thriller'],
      score: '8.5',
      synopsis: 'Returning to his secluded island hometown for a childhood friend\'s funeral, Shinpei Ajiro uncovers a dark conspiracy involving shape-shifting shadow beings.',
    ),
    AnimeItem(
      id: '18770',
      slug: 'youkoso-jitsuryoku-shijou-shugi-no-kyoushitsu-e-season-3-18770',
      title: 'Classroom of the Elite',
      posterUrl:
          'https://cdn.anipixcdn.co/thumbnail/classroom-of-the-elite.webp',
      subEpisodes: 13,
      dubEpisodes: 13,
      totalEpisodes: 13,
      type: 'TV',
      genres: ['Psychological', 'Drama', 'School', 'Mystery'],
      score: '8.1',
      synopsis: 'At the prestigious Tokyo Metropolitan Advanced Nurturing High School where students face cutthroat social competition, Kiyotaka Ayanokoji conceals his true intellect.',
    ),
  ];

  static const List<AnimeItem> _genrePoolComedy = [
    AnimeItem(
      id: '18546',
      slug: 'spy-x-family-season-2-18546',
      title: 'Spy x Family',
      posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx140960-YrkSD4mrwAqv.jpg',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Comedy', 'Action', 'Slice of Life'],
      score: '8.5',
      synopsis: 'A master spy builds a fake family for an undercover operation, unaware that his new wife is a lethal assassin and his adopted daughter is a telepath.',
    ),
    AnimeItem(
      id: '18181',
      slug: 'bocchi-the-rock-18181',
      title: 'Bocchi the Rock!',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/bocchi-the-rock.webp',
      subEpisodes: 12,
      dubEpisodes: 12,
      totalEpisodes: 12,
      type: 'TV',
      genres: ['Comedy', 'Music', 'Slice of Life'],
      score: '8.8',
      synopsis: 'Extreme social anxiety sufferer Hitori Gotoh yearns to make friends and unexpectedly finds her chance when recruited into a high school rock band.',
    ),
    AnimeItem(
      id: '129',
      slug: 'saiki-kusuo-no-psi-nan-129',
      title: 'The Disastrous Life of Saiki K.',
      posterUrl: 'https://cdn.anipixcdn.co/thumbnail/saiki-k.webp',
      subEpisodes: 24,
      dubEpisodes: 24,
      totalEpisodes: 24,
      type: 'TV',
      genres: ['Comedy', 'Supernatural', 'School'],
      score: '8.4',
      synopsis: 'Kusuo Saiki possesses godlike psychic powers but desires nothing more than a quiet, ordinary life, constantly foiled by his absurd classmates.',
    ),
  ];

  /// Get verified full details (synopsis, genres, score, status, aired) for an anime
  Future<AnimeItem> getAnimeDetails(
    String animeId,
    String animeSlug, {
    AnimeItem? existing,
  }) async {
    final cacheKey = animeSlug.isNotEmpty ? animeSlug : animeId;
    if (_animeDetailsCache.containsKey(cacheKey)) {
      final cached = _animeDetailsCache[cacheKey]!;
      if (cached.genres.isNotEmpty && cached.synopsis.isNotEmpty) {
        return cached;
      }
    }

    final cleanId = animeId.contains('-')
        ? (RegExp(r'-(\d+)$').firstMatch(animeId)?.group(1) ?? animeId)
        : animeId;

    String fetchedSynopsis = existing?.synopsis ?? '';
    List<String> fetchedGenres = List.from(existing?.genres ?? const []);
    String? fetchedScore = existing?.score;
    String? fetchedAired = existing?.releaseDate;
    String? fetchedStatus = existing?.status;
    String? fetchedTitle = existing?.title;

    // 1. Try qtip API (very fast JSON)
    if (cleanId.isNotEmpty) {
      try {
        final url = Uri.parse('$baseApi/api/theme/anime/qtip?animeId=$cleanId');
        final response = await http
            .get(url, headers: defaultHeaders)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final html = data['html']?.toString() ?? '';

          // Synopsis
          final synMatch = RegExp(
            r'class="pre-qtip-description">([^<]+)<\/div>',
          ).firstMatch(html);
          if (synMatch != null && synMatch.group(1)!.trim().isNotEmpty) {
            fetchedSynopsis = _decodeHtmlEntities(synMatch.group(1)!.trim());
          }

          // Genres
          final genreMatches = RegExp(
            r'href="[^"]*\/genres\/[^"]*"[^>]*>([^<]+)<\/a>',
          ).allMatches(html);
          final parsedGenres = <String>[];
          for (final m in genreMatches) {
            final g = m.group(1)?.trim();
            if (g != null && g.isNotEmpty && !parsedGenres.contains(g)) {
              parsedGenres.add(g);
            }
          }
          if (parsedGenres.isNotEmpty) {
            fetchedGenres = parsedGenres;
          }

          // Score
          final scoreMatch = RegExp(r'fa-star[^>]*><\/i>([\d.]+)')
              .firstMatch(html);
          if (scoreMatch != null) {
            fetchedScore = scoreMatch.group(1)!.trim();
          }

          // Status
          final statusMatch = RegExp(
            r'Status:<\/span>\s*<span class="stick-text">([^<]+)<\/span>',
          ).firstMatch(html);
          if (statusMatch != null) {
            fetchedStatus = statusMatch.group(1)!.trim();
          }

          // Aired
          final airedMatch = RegExp(
            r'Aired:<\/span>\s*<span class="stick-text">([^<]+)<\/span>',
          ).firstMatch(html);
          if (airedMatch != null) {
            final rawAired = airedMatch.group(1)!.trim();
            final yr = RegExp(r'\b(19\d\d|20\d\d)\b')
                .firstMatch(rawAired)
                ?.group(1);
            fetchedAired = yr ?? rawAired;
          }
        }
      } catch (_) {}
    }

    // 2. If synopsis or genres still missing, try scraping detail page
    if ((fetchedSynopsis.isEmpty || fetchedGenres.isEmpty) &&
        animeSlug.isNotEmpty) {
      try {
        final url = Uri.parse('$baseApi/$animeSlug');
        final response = await http
            .get(url, headers: defaultHeaders)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final html = response.body;

          // Full synopsis from .film-description .text
          if (fetchedSynopsis.isEmpty) {
            final descMatch = RegExp(
              r'class="film-description[^\"]*">\s*<div class="text">([\s\S]*?)<\/div>',
            ).firstMatch(html);
            if (descMatch != null) {
              fetchedSynopsis = _decodeHtmlEntities(descMatch.group(1)!.trim());
            }
          }

          // Genres
          if (fetchedGenres.isEmpty) {
            final genresBlock = RegExp(
              r'<span class="item-head">Genres:<\/span>([\s\S]*?)<\/div>',
            ).firstMatch(html);
            if (genresBlock != null) {
              final gMatches = RegExp(r'<a [^>]*title="([^"]+)"')
                  .allMatches(genresBlock.group(1)!);
              for (final m in gMatches) {
                final g = m.group(1)?.trim();
                if (g != null && g.isNotEmpty && !fetchedGenres.contains(g)) {
                  fetchedGenres.add(g);
                }
              }
            }
          }

          // Status fallback from detail page
          if (fetchedStatus == null) {
            final stMatch = RegExp(
              r'<span class="item-head">Status:<\/span>\s*<span class="name">([^<]+)<\/span>',
            ).firstMatch(html);
            if (stMatch != null) {
              fetchedStatus = stMatch.group(1)!.trim();
            }
          }
        }
      } catch (_) {}
    }

    // 3. Fallback: if genres still empty, infer genres from title and synopsis
    if (fetchedGenres.isEmpty) {
      fetchedGenres = inferGenresFromText(
        existing?.title ?? fetchedTitle ?? '',
        fetchedSynopsis,
      ).toList();
    }

    final isUpcoming = (fetchedStatus ?? existing?.status ?? '')
        .toLowerCase()
        .contains('not yet');

    final updated =
        (existing ??
                AnimeItem(
                  id: animeId,
                  slug: animeSlug,
                  title: fetchedTitle ?? animeSlug,
                  posterUrl: '',
                ))
            .copyWith(
              synopsis: fetchedSynopsis.isNotEmpty
                  ? fetchedSynopsis
                  : existing?.synopsis,
              genres: fetchedGenres.isNotEmpty
                  ? fetchedGenres
                  : existing?.genres,
              score: fetchedScore ?? existing?.score,
              releaseDate: fetchedAired ?? existing?.releaseDate,
              status: fetchedStatus ?? existing?.status,
              statusBadge: isUpcoming ? 'Akan Datang' : existing?.statusBadge,
            );

    _animeDetailsCache[cacheKey] = updated;
    return updated;
  }

  /// Infer genres using title and synopsis keywords when online data is unavailable
  static Set<String> inferGenresFromText(String title, String synopsis) {
    final text = '${title.toLowerCase()} ${synopsis.toLowerCase()}';
    final Set<String> detected = {};

    if (RegExp(
      r'\b(romance|romantic|love|girlfriend|boyfriend|chizuru|kanojo|koi|bride|marriage|marry|kiss|confess|confession|crush|date|dating|harem|couple|shoujo|tsundere|waifu|sweetheart)\b',
    ).hasMatch(text)) {
      detected.addAll(['Romance', 'Comedy']);
    }

    if (RegExp(
      r'\b(action|battle|fight|sword|blade|warrior|hunter|combat|punch|hero|slayer|titan|assassin|martial|power|weapon|ninja|strike|shadow monarch|level up)\b',
    ).hasMatch(text)) {
      detected.addAll(['Action', 'Adventure']);
    }

    if (RegExp(
      r'\b(magic|fantasy|dungeon|guild|reincarnat|isekai|monster|demon|dragon|sorcerer|wizard|witch|spell|elf|overlord|another world)\b',
    ).hasMatch(text)) {
      detected.addAll(['Fantasy']);
    }

    if (RegExp(
      r'\b(sport|sports|soccer|football|basketball|volleyball|tennis|boxing|racing|baseball|swimming|athlete|tournament|championship|match|karasuno|seirin)\b',
    ).hasMatch(text)) {
      detected.addAll(['Sports']);
    }

    if (RegExp(
      r'\b(mystery|detective|murder|solve|crime|investigat|thriller|psychological|death|suspect|secret|clue|conspiracy)\b',
    ).hasMatch(text)) {
      detected.addAll(['Mystery', 'Psychological']);
    }

    if (RegExp(
      r'\b(sci-fi|scifi|mecha|robot|space|future|cyberpunk|android|spaceship|galaxy|alien)\b',
    ).hasMatch(text)) {
      detected.addAll(['Sci-Fi']);
    }

    if (RegExp(
      r'\b(school|academy|student|high school|club|daily life|slice of life|peaceful|friends|classmate)\b',
    ).hasMatch(text)) {
      detected.addAll(['School', 'Slice of Life']);
    }

    if (detected.isEmpty) {
      detected.add('Action');
    }

    return detected;
  }

  /// Detect primary broad category for an anime
  static String detectPrimaryCategory(
    List<String> genres,
    String title,
    String synopsis,
  ) {
    final gLower = genres.map((g) => g.toLowerCase()).toSet();
    if (gLower.contains('romance') ||
        gLower.contains('love') ||
        gLower.contains('shoujo') ||
        gLower.contains('love polygon')) {
      return 'romance';
    }
    if (gLower.contains('sports') ||
        gLower.contains('team sports') ||
        gLower.contains('combat sports')) {
      return 'sports';
    }
    if (gLower.contains('mystery') ||
        gLower.contains('psychological') ||
        gLower.contains('thriller') ||
        gLower.contains('detective') ||
        gLower.contains('horror')) {
      return 'mystery';
    }
    if (gLower.contains('fantasy') ||
        gLower.contains('isekai') ||
        gLower.contains('magic') ||
        gLower.contains('reincarnation')) {
      return 'fantasy';
    }
    if (gLower.contains('comedy') ||
        gLower.contains('slice of life') ||
        gLower.contains('gag humor') ||
        gLower.contains('iyashikei')) {
      return 'comedy';
    }
    if (gLower.contains('sci-fi') ||
        gLower.contains('mecha') ||
        gLower.contains('space')) {
      return 'scifi';
    }
    if (gLower.contains('action') ||
        gLower.contains('adventure') ||
        gLower.contains('martial arts') ||
        gLower.contains('shounen')) {
      return 'action';
    }

    final inferred = inferGenresFromText(
      title,
      synopsis,
    ).map((g) => g.toLowerCase()).toSet();
    if (inferred.contains('romance')) return 'romance';
    if (inferred.contains('sports')) return 'sports';
    if (inferred.contains('mystery') || inferred.contains('psychological')) {
      return 'mystery';
    }
    if (inferred.contains('fantasy')) return 'fantasy';
    if (inferred.contains('sci-fi')) return 'scifi';
    if (inferred.contains('comedy') || inferred.contains('slice of life')) {
      return 'comedy';
    }
    return 'action';
  }

  static Set<String> _extractKeywords(String text) {
    final stopWords = {
      'this',
      'that',
      'with',
      'from',
      'have',
      'were',
      'been',
      'which',
      'about',
      'their',
      'there',
      'what',
      'when',
      'where',
      'while',
      'into',
      'after',
      'before',
      'because',
      'other',
      'some',
      'than',
      'them',
      'then',
      'will',
      'would',
      'could',
      'should',
      'anime',
      'episode',
      'series',
      'season',
      'online',
      'world',
      'years',
      'first',
      'being',
      'having',
      'takes',
      'make',
      'finds',
    };
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'));
    return words.where((w) => w.length >= 4 && !stopWords.contains(w)).toSet();
  }

  static String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(
          RegExp(
            r'season\s*\d+|2nd|3rd|4th|part\s*\d+|movie|special|ova|tv',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();
  }

  static String _extractFranchiseRoot(String title) {
    final clean = title.split(RegExp(r'[:\-\–\—]')).first.trim();
    if (clean.length >= 4) return clean;
    return title.split(RegExp(r'\s+')).take(2).join(' ');
  }

  static List<AnimeItem> _getFallbackPoolForCategory(String category) {
    switch (category) {
      case 'romance':
        return _genrePoolRomance;
      case 'sports':
        return _genrePoolSports;
      case 'mystery':
        return _genrePoolMystery;
      case 'fantasy':
        return _genrePoolFantasy;
      case 'comedy':
        return _genrePoolComedy;
      case 'action':
      default:
        return _genrePoolAction;
    }
  }

  /// Dynamic recommendation engine strictly tailored to the anime being watched:
  /// matches genres, synopsis themes, franchise works, and eliminates mismatched genres.
  Future<AnimeRecommendations> getRecommendationsForAnime(
    AnimeItem targetAnime,
  ) async {
    AnimeItem fullAnime = targetAnime;
    if (fullAnime.genres.isEmpty || fullAnime.synopsis.isEmpty) {
      try {
        fullAnime = await getAnimeDetails(
          fullAnime.id,
          fullAnime.slug,
          existing: fullAnime,
        );
      } catch (_) {}
    }

    final targetGenres = fullAnime.genres.map((g) => g.toLowerCase()).toSet();
    final primaryCategory = detectPrimaryCategory(
      fullAnime.genres,
      fullAnime.title,
      fullAnime.synopsis,
    );

    // Determine top genre slugs
    final validSlugs = <String>[];
    for (final g in fullAnime.genres) {
      final s = slugForGenreName(g);
      if (s.isNotEmpty && !validSlugs.contains(s)) {
        validSlugs.add(s);
      }
    }
    if (validSlugs.isEmpty) {
      final defaultSlug = primaryCategory == 'romance'
          ? 'romance'
          : (primaryCategory == 'sports'
                ? 'sports'
                : (primaryCategory == 'mystery'
                      ? 'mystery'
                      : (primaryCategory == 'fantasy'
                            ? 'fantasy'
                            : (primaryCategory == 'comedy'
                                  ? 'comedy'
                                  : 'action'))));
      validSlugs.add(defaultSlug);
    }

    final targetKeywords = _extractKeywords(
      '${fullAnime.title} ${fullAnime.synopsis}',
    );
    final targetFranchiseRoot = _extractFranchiseRoot(fullAnime.title);

    // Fetch candidate anime concurrently from HiAnime genre feeds and franchise search
    final Map<String, AnimeItem> candidatePool = {};
    final List<Future<void>> fetchTasks = [];

    // Query top 2 matching genre feeds
    for (final slug in validSlugs.take(2)) {
      fetchTasks.add(() async {
        try {
          final items = await getAnimeByGenre(slug, page: 1);
          final gName = _genreNameMap[slug] ?? slug;
          for (final it in items) {
            final key = it.id.isNotEmpty ? it.id : it.slug;
            candidatePool[key] = it.genres.isEmpty
                ? it.copyWith(genres: [gName])
                : it;
          }
        } catch (_) {}
      }());
    }

    // If franchise root is distinct, search to get other seasons / movies
    if (targetFranchiseRoot.length >= 4) {
      fetchTasks.add(() async {
        try {
          final items = await searchAnime(targetFranchiseRoot, page: 1);
          for (final it in items) {
            final key = it.id.isNotEmpty ? it.id : it.slug;
            candidatePool[key] = it.genres.isEmpty
                ? it.copyWith(genres: fullAnime.genres)
                : it;
          }
        } catch (_) {}
      }());
    }

    await Future.wait(fetchTasks);

    final targetNormTitle = _normalizeTitle(fullAnime.title);
    final List<MapEntry<AnimeItem, double>> scored = [];

    for (var candidate in candidatePool.values) {
      if (candidate.id == fullAnime.id ||
          candidate.slug == fullAnime.slug ||
          _normalizeTitle(candidate.title) == targetNormTitle) {
        continue;
      }

      if (candidate.genres.isEmpty) {
        final inferred = inferGenresFromText(
          candidate.title,
          candidate.synopsis,
        ).toList();
        candidate = candidate.copyWith(
          genres: inferred.isNotEmpty ? inferred : fullAnime.genres,
        );
      }

      double score = 0.0;
      final candNormTitle = _normalizeTitle(candidate.title);

      // Franchise connection
      if (targetFranchiseRoot.isNotEmpty &&
          candNormTitle.contains(targetFranchiseRoot.toLowerCase())) {
        score += 80.0;
      }

      final candGenres = candidate.genres.map((g) => g.toLowerCase()).toSet();
      final candCategory = detectPrimaryCategory(
        candidate.genres,
        candidate.title,
        candidate.synopsis,
      );

      // Strict protection: do not allow cross-genre mismatch (e.g. romance getting action)
      if (primaryCategory == 'romance' && candCategory == 'action') {
        score -= 100.0;
      } else if (primaryCategory == 'sports' && candCategory != 'sports') {
        score -= 60.0;
      } else if (primaryCategory == 'action' && candCategory == 'romance') {
        score -= 60.0;
      }

      // Category alignment bonus
      if (candCategory == primaryCategory) {
        score += 30.0;
      }

      // Shared genre count
      for (final g in targetGenres) {
        if (candGenres.contains(g)) {
          score += 15.0;
        }
      }

      // Thematic synopsis keyword matching
      if (candidate.synopsis.isNotEmpty || candidate.title.isNotEmpty) {
        final candKeywords = _extractKeywords(
          '${candidate.title} ${candidate.synopsis}',
        );
        int commonWords = 0;
        for (final kw in targetKeywords) {
          if (candKeywords.contains(kw)) {
            commonWords++;
          }
        }
        score += (commonWords * 4.0).clamp(0.0, 24.0);
      }

      // Salt based on candidate hash for uniqueness
      final salt =
          ((candidate.id.hashCode ^ fullAnime.id.hashCode).abs() % 10) / 2.0;
      score += salt;

      if (score > 0) {
        scored.add(MapEntry(candidate, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    final List<AnimeItem> candidatesSorted = scored.map((e) => e.key).toList();

    List<AnimeItem> moreLikeThis = [];
    List<AnimeItem> recommendations = [];

    // Prioritize direct franchise matches in More Like This
    final franchiseMatches = candidatesSorted.where((c) {
      final t = _normalizeTitle(c.title);
      return targetFranchiseRoot.isNotEmpty &&
          t.contains(targetFranchiseRoot.toLowerCase());
    }).toList();

    moreLikeThis.addAll(franchiseMatches);

    for (final c in candidatesSorted) {
      if (!moreLikeThis.any((m) => m.id == c.id || m.slug == c.slug)) {
        if (moreLikeThis.length < 8) {
          moreLikeThis.add(c);
        } else if (recommendations.length < 8) {
          recommendations.add(c);
        }
      }
    }

    // Safety fallback: ensure minimum 6 items using strictly MATCHING category pool
    final fallbackPool = _getFallbackPoolForCategory(primaryCategory);
    final fallbackFiltered = fallbackPool.where((c) {
      return c.id != fullAnime.id &&
          c.slug != fullAnime.slug &&
          _normalizeTitle(c.title) != targetNormTitle;
    }).toList();

    if (moreLikeThis.length < 6) {
      for (final fb in fallbackFiltered) {
        if (!moreLikeThis.any((m) => m.id == fb.id || m.slug == fb.slug) &&
            !recommendations.any((r) => r.id == fb.id || r.slug == fb.slug)) {
          moreLikeThis.add(fb);
          if (moreLikeThis.length >= 8) break;
        }
      }
    }

    if (recommendations.length < 6) {
      for (final fb in fallbackFiltered.reversed) {
        if (!moreLikeThis.any((m) => m.id == fb.id || m.slug == fb.slug) &&
            !recommendations.any((r) => r.id == fb.id || r.slug == fb.slug)) {
          recommendations.add(fb);
          if (recommendations.length >= 8) break;
        }
      }
    }

    return AnimeRecommendations(
      moreLikeThis: moreLikeThis.take(8).toList(),
      recommendations: recommendations.take(8).toList(),
    );
  }

  /// Get all seasons for an anime franchise (e.g. Season 1, Season 2, etc.)
  Future<List<SeasonItem>> getSeasonsForAnime(AnimeItem targetAnime) async {
    final List<SeasonItem> seasons = [];
    final cleanId = targetAnime.id.contains('-')
        ? (RegExp(r'-(\d+)$').firstMatch(targetAnime.id)?.group(1) ?? targetAnime.id)
        : targetAnime.id;
    final slug = targetAnime.slug;

    // 1. Try scraping block_area-seasons from detail page
    if (slug.isNotEmpty) {
      try {
        final url = Uri.parse('$baseApi/$slug');
        final response = await http
            .get(url, headers: defaultHeaders)
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final html = response.body;
          final blockMatch = RegExp(
            r'class="[^"]*block_area-seasons[^"]*">([\s\S]*?)<\/section>',
          ).firstMatch(html);

          if (blockMatch != null) {
            final block = blockMatch.group(1) ?? '';
            final itemRegex = RegExp(
              r'<a\s+[^>]*href="[^"]*hianime\.at/([^"]+)"\s+class="os-item([^>]*)"\s+title="([^"]+)">[\s\S]*?<div class="title">([^<]+)<\/div>[\s\S]*?background-image:\s*url\(([^)]+)\)',
            );
            final matches = itemRegex.allMatches(block);
            for (final m in matches) {
              final sSlug = m.group(1)?.trim() ?? '';
              final activeClass = m.group(2) ?? '';
              final sTitle = _decodeHtmlEntities(m.group(3)?.trim() ?? '');
              final sName = _decodeHtmlEntities(m.group(4)?.trim() ?? '');
              final sPoster = m.group(5)?.trim() ?? '';
              final sIdMatch = RegExp(r'-(\d+)$').firstMatch(sSlug);
              final sId = sIdMatch?.group(1) ?? sSlug;
              final isCur = activeClass.contains('active') ||
                  sId == cleanId ||
                  sSlug == slug;

              seasons.add(
                SeasonItem(
                  id: sId,
                  slug: sSlug,
                  title: sTitle,
                  seasonName: sName,
                  posterUrl: sPoster.isNotEmpty ? sPoster : targetAnime.posterUrl,
                  isCurrent: isCur,
                ),
              );
            }
          }
        }
      } catch (_) {}
    }

    // 2. Fallback: If no block_area-seasons found, search franchise root to find other seasons
    if (seasons.isEmpty) {
      final franchiseRoot = _extractFranchiseRoot(targetAnime.title);
      if (franchiseRoot.length >= 4) {
        try {
          final candidates = await searchAnime(franchiseRoot, page: 1);
          final normTarget = _normalizeTitle(targetAnime.title);

          // Find items matching the franchise
          final franchiseItems = candidates.where((c) {
            final t = _normalizeTitle(c.title);
            return t.contains(franchiseRoot.toLowerCase()) ||
                normTarget.contains(_normalizeTitle(c.title));
          }).toList();

          if (franchiseItems.length > 1) {
            for (var i = 0; i < franchiseItems.length; i++) {
              final c = franchiseItems[i];
              final cCleanId = c.id.contains('-')
                  ? (RegExp(r'-(\d+)$').firstMatch(c.id)?.group(1) ?? c.id)
                  : c.id;
              final isCur = cCleanId == cleanId || c.slug == slug;

              // Detect season name if possible
              String detectedName = 'Season ${i + 1}';
              final sMatch = RegExp(
                r'(season\s*\d+|2nd\s*season|3rd\s*season|4th\s*season|final\s*season|the\s*final|part\s*\d+|movie|special)',
                caseSensitive: false,
              ).firstMatch(c.title);
              if (sMatch != null) {
                detectedName = sMatch.group(0)!;
                detectedName = detectedName.split(' ').map((w) {
                  return w.isEmpty
                      ? w
                      : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
                }).join(' ');
              }

              seasons.add(
                SeasonItem(
                  id: cCleanId,
                  slug: c.slug,
                  title: c.title,
                  seasonName: detectedName,
                  posterUrl: c.posterUrl.isNotEmpty ? c.posterUrl : targetAnime.posterUrl,
                  isCurrent: isCur,
                ),
              );
            }
          }
        } catch (_) {}
      }
    }

    // Ensure at least the current anime is in the list
    if (seasons.isEmpty) {
      seasons.add(
        SeasonItem(
          id: cleanId,
          slug: slug,
          title: targetAnime.title,
          seasonName: 'Season 1',
          posterUrl: targetAnime.posterUrl,
          isCurrent: true,
        ),
      );
    }

    return seasons;
  }

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
          final genreMatches = RegExp(r'href="[^"]*\/genres\/([^"]+)"')
              .allMatches(html);

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

  /// Fetch candidates for a specific genre slug with filter fallback
  Future<List<AnimeItem>> _fetchCandidatesForSlug(String slug, int page) async {
    final list =
        await _fetchCandidatesFromUrl('$baseApi/genres/$slug?page=$page');
    if (list.isNotEmpty) return list;
    return _fetchCandidatesFromUrl(
      '$baseApi/filter?genre%5B%5D=${Uri.encodeQueryComponent(slug)}&page=$page',
    );
  }

  static final Map<String, String> _genreNameMap = {
    for (final g in allGenres) (g['slug'] ?? ''): (g['name'] ?? ''),
  };

  /// Get anime matching selected genres.
  /// Fetches candidates across all selected genres concurrently,
  /// placing exact multi-genre matches at the top, followed by all anime matching any searched genre.
  Future<List<AnimeItem>> getAnimeByGenres(
    List<String> genreSlugs, {
    int page = 1,
  }) async {
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
        fetchTasks.add(_fetchCandidatesForSlug(slug, page));
        if (page == 1) {
          fetchTasks.add(_fetchCandidatesForSlug(slug, 2));
        }
      }

      final fetchResults = await Future.wait(fetchTasks);

      // 2. Track anime and matched genres
      final Map<String, AnimeItem> animeMap = {};
      final Map<String, Set<String>> animeGenreHits = {};

      for (int i = 0; i < fetchResults.length; i++) {
        final slugIndex = (page == 1) ? (i ~/ 2) : i;
        if (slugIndex >= validSlugs.length) continue;
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
          final genreFutures = candidatesToCheck.map(
            (a) => getAnimeGenres(a.id),
          );
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
        final readableMatched = matched
            .map((s) => _genreNameMap[s] ?? s)
            .toList();
        final label = readableMatched.isNotEmpty
            ? readableMatched.join(', ')
            : item.genreLabel;
        return item.copyWith(genreLabel: label, genres: matched.toList());
      }).toList();

      if (enrichedItems.isNotEmpty) {
        return enrichedItems;
      }
    } catch (_) {}

    return getPopularAnime();
  }

  /// Get anime by single genre slug from HiAnime (loads up to 2 pages for page 1)
  Future<List<AnimeItem>> getAnimeByGenre(
    String genreSlug, {
    int page = 1,
  }) async {
    final slug = genreSlug.trim().toLowerCase();
    if (slug.isEmpty || slug == 'semua') {
      return getPopularAnime();
    }

    try {
      final List<Future<http.Response>> requests = [
        http
            .get(
              Uri.parse('$baseApi/genres/$slug?page=$page'),
              headers: defaultHeaders,
            )
            .timeout(const Duration(seconds: 10)),
      ];
      if (page == 1) {
        requests.add(
          http
              .get(
                Uri.parse('$baseApi/genres/$slug?page=2'),
                headers: defaultHeaders,
              )
              .timeout(const Duration(seconds: 10)),
        );
      }

      final responses = await Future.wait(requests);
      final List<AnimeItem> results = [];
      final Set<String> seen = {};
      final genreName =
          _genreNameMap[slug] ??
          (slug.isNotEmpty
              ? (slug[0].toUpperCase() + slug.substring(1))
              : slug);

      for (final resp in responses) {
        if (resp.statusCode == 200) {
          final items = _parseSearchHtml(resp.body);
          for (var item in items) {
            final key = item.id.isNotEmpty ? item.id : item.slug;
            if (item.genres.isEmpty && genreName.isNotEmpty) {
              item = item.copyWith(genres: [genreName]);
            }
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
        '$baseApi/filter?genre%5B%5D=${Uri.encodeQueryComponent(slug)}&page=$page',
      );
      final response = await http
          .get(filterUrl, headers: defaultHeaders)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final genreName =
            _genreNameMap[slug] ??
            (slug.isNotEmpty
                ? (slug[0].toUpperCase() + slug.substring(1))
                : slug);
        final results = _parseSearchHtml(response.body).map((item) {
          if (item.genres.isEmpty && genreName.isNotEmpty) {
            return item.copyWith(genres: [genreName]);
          }
          return item;
        }).toList();
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
    // If the HTML has a sidebar (top 10 widgets, recommendations), restrict parsing to main content
    final sidebarIndex = html.indexOf('id="main-sidebar"');
    final contentHtml =
        sidebarIndex != -1 ? html.substring(0, sidebarIndex) : html;

    final List<AnimeItem> items = [];
    final itemRegex = RegExp(
      r'<div class="flw-item[^"]*">([\s\S]*?)<div class="clearfix"><\/div>',
      multiLine: true,
    );

    final matches = itemRegex.allMatches(contentHtml);
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
      final posterMatch = RegExp(
        r'<img[^>]+src="([^"]+)"[^>]+class="film-poster-img"',
      ).firstMatch(block);
      final posterUrl = posterMatch?.group(1) ?? '';

      // Sub / Dub / Eps count
      final subMatch = RegExp(r'class="[^"]*tick-sub[^"]*">.*?(\d+)<\/div>')
          .firstMatch(block);
      final dubMatch = RegExp(r'class="[^"]*tick-dub[^"]*">.*?(\d+)<\/div>')
          .firstMatch(block);
      final epsMatch = RegExp(r'class="[^"]*tick-eps[^"]*">.*?(\d+)<\/div>')
          .firstMatch(block);

      final subCount = int.tryParse(subMatch?.group(1) ?? '0') ?? 0;
      final dubCount = int.tryParse(dubMatch?.group(1) ?? '0') ?? 0;
      final epsCount = epsMatch != null
          ? (int.tryParse(epsMatch.group(1) ?? '0') ?? 0)
          : 0;

      // Extract synopsis if present (e.g. on genre/filter pages)
      final descMatch = RegExp(
        r'<div class="description">\s*([\s\S]*?)\s*<\/div>',
      ).firstMatch(block);
      final synopsis = descMatch != null
          ? _decodeHtmlEntities(descMatch.group(1)!.trim())
          : '';

      // Extract media type (TV, Movie, OVA, etc.)
      final typeMatch = RegExp(r'<span class="fdi-item">([^<]+)<\/span>')
          .firstMatch(block);
      final rawType = typeMatch?.group(1)?.trim() ?? 'TV';

      // Extract duration or release date (e.g. "Sep 7, 2026" or "24m")
      final durationMatch = RegExp(
        r'class="[^"]*fdi-duration[^"]*">([^<]+)<\/span>',
      ).firstMatch(block);
      final durationText = durationMatch?.group(1)?.trim();

      // Check if anime is upcoming / not yet aired:
      // - "(? eps)" in block or type
      // - subCount == 0 && dubCount == 0 && epsCount == 0 with date info or no ticks
      final hasNoEpisodeTicks =
          subMatch == null && dubMatch == null && epsMatch == null;
      final isUpcoming = block.contains('(? eps)') ||
          rawType.contains('(? eps)') ||
          (hasNoEpisodeTicks &&
              durationText != null &&
              durationText.isNotEmpty);

      final status = isUpcoming ? 'Not yet aired' : null;
      final statusBadge = isUpcoming ? 'Akan Datang' : null;

      items.add(
        AnimeItem(
          id: id,
          slug: slug,
          title: title,
          posterUrl: posterUrl,
          subEpisodes: subCount,
          dubEpisodes: dubCount,
          totalEpisodes: epsCount,
          synopsis: synopsis,
          type: rawType,
          status: status,
          statusBadge: statusBadge,
          releaseDate: durationText,
        ),
      );
    }

    return items;
  }

  /// Get episode list for an anime ID
  Future<List<EpisodeItem>> getEpisodes(
    String animeId,
    String animeSlug,
  ) async {
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

          episodes.add(
            EpisodeItem(
              id: epId,
              number: epNo,
              title: epTitle.isEmpty ? 'Episode $epNo' : epTitle,
              slug: animeSlug,
            ),
          );
        }

        if (episodes.isNotEmpty) {
          // Sort by episode number
          episodes.sort((a, b) => a.number.compareTo(b.number));
          return episodes;
        } else {
          // Server explicitly returned 0 episodes (anime is upcoming / not yet aired)
          return [];
        }
      }
    } catch (_) {}

    // On network failure or unreleased anime, return empty list (never fabricate dummy episodes)
    return [];
  }

  /// Get all available stream servers for an episode, prioritized by speed (HD-1 fast CDN first)
  Future<List<StreamServerItem>> getStreamServers(
    String episodeId, {
    bool isDub = false,
  }) async {
    try {
      final url = Uri.parse(
        '$baseApi/api/theme/episode/servers?episodeId=$episodeId',
      );
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
              servers.add(
                StreamServerItem(name: name, type: type, embedUrl: embedUrl),
              );
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
              servers.add(
                StreamServerItem(name: name, type: type, embedUrl: embedUrl),
              );
            } catch (_) {}
          }
        }

        // Sort servers: HD-1 fast CDN first, then HD-2, Vidstream, and ZokoAnime
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

  /// Extract direct HLS master.m3u8 stream and subtitles from ZokoAnime embed page
  Future<Map<String, String>?> getDirectStreamInfo(String zokoEmbedUrl) async {
    try {
      final response = await http
          .get(
            Uri.parse(zokoEmbedUrl),
            headers: {...defaultHeaders, 'Referer': 'https://hianime.at/'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final blobMatch = RegExp(r'window\.__P="([^"]+)"')
            .firstMatch(response.body);
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
            String subUrl = '';
            final subs = data['subtitles'];
            if (subs is List && subs.isNotEmpty) {
              final defaultSub = subs.firstWhere(
                (s) => s['default'] == true,
                orElse: () => subs.first,
              );
              subUrl = defaultSub['src']?.toString() ?? '';
            }
            return {
              'src': src,
              'sub': subUrl,
              'referrer': 'https://zokoanime.video/',
            };
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Extract direct HLS master.m3u8 stream from ZokoAnime embed page for external native player
  Future<String?> getDirectM3u8Stream(String zokoEmbedUrl) async {
    final info = await getDirectStreamInfo(zokoEmbedUrl);
    return info?['src'];
  }

  /// Get stream servers and embed player URL (HD-1 fast CDN by default)
  Future<String?> getStreamEmbedUrl(
    String episodeId, {
    bool isDub = false,
  }) async {
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
      final res = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final live = _parseSearchHtml(res.body);
        if (live.isNotEmpty) {
          return live.take(24).map((item) {
            return item.copyWith(
              episodeLabel:
                  'Episode ${item.subEpisodes > 0 ? item.subEpisodes : 1}',
            );
          }).toList();
        }
      }
    } catch (_) {}

    return const [];
  }

  static HomePageSections? _cachedHomePageSections;

  /// Fetch live sections matching HiAnime homepage (Latest Episode, New On HiAnime, Top Upcoming, Top 10)
  Future<HomePageSections> getHomePageSections({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedHomePageSections != null) {
      return _cachedHomePageSections!;
    }

    try {
      final url = Uri.parse('$baseApi/home');
      final res = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final html = res.body;

        List<AnimeItem> parseSection(String secName, {bool isUpcoming = false}) {
          final escaped = RegExp.escape(secName);
          final pattern = RegExp(
            '<h2 class="cat-heading">\\s*$escaped\\s*</h2>([\\s\\S]*?)(?=<section class="block_area|<footer|\$)',
            caseSensitive: false,
          );
          final match = pattern.firstMatch(html);
          if (match == null) return [];
          final block = match.group(1) ?? '';
          final items = _parseSearchHtml(block);
          if (isUpcoming) {
            return items.map((i) => i.copyWith(
              status: 'Not yet aired',
              statusBadge: 'Akan Datang',
            )).toList();
          }
          return items;
        }

        final latest = parseSection('Latest Episode');
        final newOn = parseSection('New On HiAnime');
        final upcoming = parseSection('Top Upcoming', isUpcoming: true);
        final top10 = await getPalingPopuler();

        if (latest.isNotEmpty || newOn.isNotEmpty || upcoming.isNotEmpty) {
          final data = HomePageSections(
            latestEpisodes: latest,
            newOnHiAnime: newOn,
            topUpcoming: upcoming,
            top10: top10,
          );
          _cachedHomePageSections = data;
          return data;
        }
      }
    } catch (_) {}

    final fallbackLatest = await getEpisodeBaru();
    final fallbackTop = await getPalingPopuler();
    return HomePageSections(
      latestEpisodes: fallbackLatest,
      newOnHiAnime: fallbackLatest,
      topUpcoming: const [],
      top10: fallbackTop,
    );
  }

  /// 5. Jadwal Hari ini (matching Screenshot 2 with new !! badge)
  Future<List<AnimeItem>> getJadwalHariIni() async {
    try {
      final url = Uri.parse('$baseApi/top-airing');
      final res = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 4));
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
      final res = await http
          .get(url, headers: defaultHeaders)
          .timeout(const Duration(seconds: 4));
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

  /// 10. Airing Schedule for specific date (from official anime server/API)
  Future<List<AnimeItem>> getAiringSchedule(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final greaterTimestamp = startOfDay.millisecondsSinceEpoch ~/ 1000;
    final lesserTimestamp = endOfDay.millisecondsSinceEpoch ~/ 1000;

    const query = '''
query (\$greater: Int, \$lesser: Int) {
  Page(page: 1, perPage: 50) {
    airingSchedules(airingAt_greater: \$greater, airingAt_lesser: \$lesser, sort: TIME) {
      id
      airingAt
      episode
      media {
        id
        title {
          english
          romaji
        }
        coverImage {
          large
          medium
        }
        genres
        averageScore
        type
        description
      }
    }
  }
}
''';

    try {
      final response = await http
          .post(
            Uri.parse('https://graphql.anilist.co'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'Mozilla/5.0',
            },
            body: jsonEncode({
              'query': query,
              'variables': {
                'greater': greaterTimestamp,
                'lesser': lesserTimestamp,
              },
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final schedules =
            data['data']?['Page']?['airingSchedules'] as List? ?? [];
        final List<AnimeItem> items = [];

        for (var s in schedules) {
          final media = s['media'];
          if (media == null) continue;
          final title =
              media['title']?['english'] ??
              media['title']?['romaji'] ??
              'Unknown Anime';
          final poster =
              media['coverImage']?['large'] ??
              media['coverImage']?['medium'] ??
              '';
          final ep = s['episode'] ?? 1;
          final scoreVal = media['averageScore'];
          final scoreStr = scoreVal != null
              ? (scoreVal / 10.0).toStringAsFixed(1)
              : null;
          final genres =
              (media['genres'] as List?)?.map((e) => e.toString()).toList() ??
              [];
          final airingTimestamp = s['airingAt'] as int?;
          String? timeLabel;
          if (airingTimestamp != null) {
            final airingLocal = DateTime.fromMillisecondsSinceEpoch(
              airingTimestamp * 1000,
            );
            final hour = airingLocal.hour.toString().padLeft(2, '0');
            final min = airingLocal.minute.toString().padLeft(2, '0');
            timeLabel = '$hour:$min';
          }

          items.add(
            AnimeItem(
              id: media['id']?.toString() ?? s['id'].toString(),
              slug: media['id']?.toString() ?? s['id'].toString(),
              title: title,
              posterUrl: poster,
              totalEpisodes: ep,
              subEpisodes: ep,
              episodeLabel: 'Episode $ep',
              statusBadge: timeLabel != null ? 'Pukul $timeLabel' : null,
              score: scoreStr,
              genres: genres,
              type: media['type']?.toString() ?? 'TV',
              synopsis: media['description']?.toString() ?? '',
            ),
          );
        }
        return items;
      }
    } catch (_) {}

    return [];
  }
}
