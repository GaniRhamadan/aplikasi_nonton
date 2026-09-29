import 'dart:convert';

class AnimeItem {
  final String id;
  final String slug;
  final String title;
  final String posterUrl;
  final int subEpisodes;
  final int dubEpisodes;
  final int totalEpisodes;
  final String type;
  final String synopsis;
  final List<String> genres;
  final String? bannerUrl;
  final String? views;
  final String? favorites;
  final String? releaseDate;
  final String? episodeLabel;
  final String? genreLabel;
  final bool isNew;

  const AnimeItem({
    required this.id,
    required this.slug,
    required this.title,
    required this.posterUrl,
    this.subEpisodes = 0,
    this.dubEpisodes = 0,
    this.totalEpisodes = 0,
    this.type = 'TV',
    this.synopsis = '',
    this.genres = const [],
    this.bannerUrl,
    this.views,
    this.favorites,
    this.releaseDate,
    this.episodeLabel,
    this.genreLabel,
    this.isNew = false,
  });

  String get displayGenre {
    if (genreLabel != null && genreLabel!.isNotEmpty) return genreLabel!;
    if (genres.isNotEmpty) return genres.take(3).join(', ');
    return 'Action';
  }

  String get displayEpisode {
    if (episodeLabel != null && episodeLabel!.isNotEmpty) return episodeLabel!;
    if (subEpisodes > 0) return 'Episode $subEpisodes';
    if (totalEpisodes > 0) return 'Episode $totalEpisodes';
    return 'Episode 1';
  }

  String get formattedViews {
    if (views != null && views!.isNotEmpty) return views!;
    final hash = (slug.hashCode.abs() % 890 + 10) * 17482;
    return '${_formatNumber(hash)} views';
  }

  String get formattedFavorites {
    if (favorites != null && favorites!.isNotEmpty) return favorites!;
    final hash = (slug.hashCode.abs() % 400 + 15) * 128;
    return '${_formatNumber(hash)} favorites';
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  AnimeItem copyWith({
    String? id,
    String? slug,
    String? title,
    String? posterUrl,
    int? subEpisodes,
    int? dubEpisodes,
    int? totalEpisodes,
    String? type,
    String? synopsis,
    List<String>? genres,
    String? bannerUrl,
    String? views,
    String? favorites,
    String? releaseDate,
    String? episodeLabel,
    String? genreLabel,
    bool? isNew,
  }) {
    return AnimeItem(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      subEpisodes: subEpisodes ?? this.subEpisodes,
      dubEpisodes: dubEpisodes ?? this.dubEpisodes,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      type: type ?? this.type,
      synopsis: synopsis ?? this.synopsis,
      genres: genres ?? this.genres,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
      releaseDate: releaseDate ?? this.releaseDate,
      episodeLabel: episodeLabel ?? this.episodeLabel,
      genreLabel: genreLabel ?? this.genreLabel,
      isNew: isNew ?? this.isNew,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'posterUrl': posterUrl,
      'subEpisodes': subEpisodes,
      'dubEpisodes': dubEpisodes,
      'totalEpisodes': totalEpisodes,
      'type': type,
      'synopsis': synopsis,
      'genres': genres,
      'bannerUrl': bannerUrl,
      'views': views,
      'favorites': favorites,
      'releaseDate': releaseDate,
      'episodeLabel': episodeLabel,
      'genreLabel': genreLabel,
      'isNew': isNew,
    };
  }

  factory AnimeItem.fromMap(Map<String, dynamic> map) {
    return AnimeItem(
      id: map['id'] ?? '',
      slug: map['slug'] ?? '',
      title: map['title'] ?? '',
      posterUrl: map['posterUrl'] ?? '',
      subEpisodes: map['subEpisodes'] ?? 0,
      dubEpisodes: map['dubEpisodes'] ?? 0,
      totalEpisodes: map['totalEpisodes'] ?? 0,
      type: map['type'] ?? 'TV',
      synopsis: map['synopsis'] ?? '',
      genres: List<String>.from(map['genres'] ?? const []),
      bannerUrl: map['bannerUrl'],
      views: map['views'],
      favorites: map['favorites'],
      releaseDate: map['releaseDate'],
      episodeLabel: map['episodeLabel'],
      genreLabel: map['genreLabel'],
      isNew: map['isNew'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AnimeItem.fromJson(String source) =>
      AnimeItem.fromMap(json.decode(source));
}

class CuplixItem {
  final String id;
  final String title;
  final String imageUrl;
  final String? animeSlug;

  const CuplixItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.animeSlug,
  });
}

class EpisodeItem {
  final String id;
  final int number;
  final String title;
  final String slug;

  const EpisodeItem({
    required this.id,
    required this.number,
    required this.title,
    required this.slug,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'slug': slug,
    };
  }

  factory EpisodeItem.fromMap(Map<String, dynamic> map) {
    return EpisodeItem(
      id: map['id'] ?? '',
      number: map['number'] ?? 1,
      title: map['title'] ?? '',
      slug: map['slug'] ?? '',
    );
  }
}

class WatchHistoryItem {
  final String animeId;
  final String animeSlug;
  final String animeTitle;
  final String animePoster;
  final int episodeNumber;
  final String episodeTitle;
  final int timestamp;

  const WatchHistoryItem({
    required this.animeId,
    required this.animeSlug,
    required this.animeTitle,
    required this.animePoster,
    required this.episodeNumber,
    required this.episodeTitle,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'animeId': animeId,
      'animeSlug': animeSlug,
      'animeTitle': animeTitle,
      'animePoster': animePoster,
      'episodeNumber': episodeNumber,
      'episodeTitle': episodeTitle,
      'timestamp': timestamp,
    };
  }

  factory WatchHistoryItem.fromMap(Map<String, dynamic> map) {
    return WatchHistoryItem(
      animeId: map['animeId'] ?? '',
      animeSlug: map['animeSlug'] ?? '',
      animeTitle: map['animeTitle'] ?? '',
      animePoster: map['animePoster'] ?? '',
      episodeNumber: map['episodeNumber'] ?? 1,
      episodeTitle: map['episodeTitle'] ?? '',
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  String toJson() => json.encode(toMap());

  factory WatchHistoryItem.fromJson(String source) =>
      WatchHistoryItem.fromMap(json.decode(source));
}

class StreamServerItem {
  final String name;
  final String type; // 'sub' or 'dub'
  final String embedUrl;
  final String? directM3u8Url;

  const StreamServerItem({
    required this.name,
    required this.type,
    required this.embedUrl,
    this.directM3u8Url,
  });
}
