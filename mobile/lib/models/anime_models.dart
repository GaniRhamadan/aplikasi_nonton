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
  });

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
    );
  }

  String toJson() => json.encode(toMap());

  factory AnimeItem.fromJson(String source) =>
      AnimeItem.fromMap(json.decode(source));
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

