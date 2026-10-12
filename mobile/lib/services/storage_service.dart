import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_models.dart';
import '../theme/app_theme.dart';

class StorageService {
  static const String _keyHistory = 'ani_history';
  static const String _keyBookmarks = 'ani_bookmarks';
  static const String _keyDownloads = 'ani_downloads';
  static const String _keyPrefDub = 'ani_pref_dub';
  static const String _keyPrefPlayer = 'ani_pref_player';
  static const String _keyPrefQuality = 'ani_pref_quality';
  static const String _keySubLanguage = 'ani_pref_sub_lang';
  static const String _keyThemeMode = 'ani_theme_mode';
  static const String _keyOnboardingCompleted = 'ani_onboarding_completed';
  static const String _keyThemeWhiteEnforced = 'ani_theme_white_enforced_v1';
  static const String _keyAutoSkipIntro = 'ani_pref_auto_skip_intro';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    bookmarksNotifier.value = getBookmarks();
    // Default to clean white theme matching Figma reference designs.
    // Reset any legacy dark preference from old versions so user's phone opens in white light theme.
    final hasSetLight = _prefs?.getBool(_keyThemeWhiteEnforced) ?? false;
    if (!hasSetLight) {
      await _prefs?.setString(_keyThemeMode, 'light');
      await _prefs?.setBool(_keyThemeWhiteEnforced, true);
    }
  }

  // --- Watch History (Strictly per-anime) ---
  static List<WatchHistoryItem> getHistory() {
    final list = _prefs?.getStringList(_keyHistory) ?? [];
    return list.map((item) => WatchHistoryItem.fromJson(item)).toList();
  }

  static Future<void> saveHistory(
    WatchHistoryItem item, {
    int? totalEpisodes,
  }) async {
    final history = getHistory();

    // Check if anime already has a history record
    final existingIndex = history.indexWhere((h) =>
        (item.animeId.isNotEmpty && h.animeId == item.animeId) ||
        (item.animeSlug.isNotEmpty && h.animeSlug == item.animeSlug) ||
        (item.animeTitle.isNotEmpty &&
            h.animeTitle.toLowerCase() == item.animeTitle.toLowerCase()));

    List<int> mergedWatched = [];
    int effectiveTotal = totalEpisodes ?? item.totalEpisodes;
    String poster = item.animePoster;

    if (existingIndex >= 0) {
      final existing = history.removeAt(existingIndex);
      mergedWatched = List<int>.from(existing.watchedEpisodes);
      if (effectiveTotal <= 0 && existing.totalEpisodes > 0) {
        effectiveTotal = existing.totalEpisodes;
      }
      if (poster.isEmpty && existing.animePoster.isNotEmpty) {
        poster = existing.animePoster;
      }
    }

    // Merge watched episode numbers
    for (final ep in item.watchedEpisodes) {
      if (!mergedWatched.contains(ep)) {
        mergedWatched.add(ep);
      }
    }
    if (!mergedWatched.contains(item.episodeNumber)) {
      mergedWatched.add(item.episodeNumber);
    }
    mergedWatched.sort();

    // Construct unified single per-anime history item
    final unifiedItem = WatchHistoryItem(
      animeId: item.animeId,
      animeSlug: item.animeSlug,
      animeTitle: item.animeTitle,
      animePoster: poster,
      episodeNumber: item.episodeNumber,
      episodeTitle: item.episodeTitle,
      timestamp: item.timestamp > 0
          ? item.timestamp
          : DateTime.now().millisecondsSinceEpoch,
      totalEpisodes: effectiveTotal,
      watchedEpisodes: mergedWatched,
    );

    // Insert at front (most recently watched anime)
    history.insert(0, unifiedItem);

    // Keep max 50 anime entries
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    final rawList = history.map((h) => h.toJson()).toList();
    await _prefs?.setStringList(_keyHistory, rawList);
  }

  /// Get watch history item for a specific anime
  static WatchHistoryItem? getHistoryForAnime(String animeId, String animeSlug) {
    final history = getHistory();
    try {
      return history.firstWhere(
        (h) =>
            (animeId.isNotEmpty && h.animeId == animeId) ||
            (animeSlug.isNotEmpty && h.animeSlug == animeSlug),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get the last watched episode number for an anime (null if never watched)
  static int? getLastWatchedEpisode(String animeId, String animeSlug) {
    return getHistoryForAnime(animeId, animeSlug)?.episodeNumber;
  }

  /// Get all watched episode numbers for an anime
  static Set<int> getWatchedEpisodes(String animeId, String animeSlug) {
    final item = getHistoryForAnime(animeId, animeSlug);
    if (item == null) return {};
    return item.watchedEpisodes.toSet();
  }

  /// Check if a specific episode of an anime has been watched
  static bool isEpisodeWatched(
      String animeId, String animeSlug, int episodeNumber) {
    final item = getHistoryForAnime(animeId, animeSlug);
    if (item == null) return false;
    return item.watchedEpisodes.contains(episodeNumber);
  }

  /// Remove a single anime from watch history
  static Future<void> deleteHistoryItem(
      String animeId, String animeSlug) async {
    final history = getHistory();
    history.removeWhere(
      (h) =>
          (animeId.isNotEmpty && h.animeId == animeId) ||
          (animeSlug.isNotEmpty && h.animeSlug == animeSlug),
    );
    final rawList = history.map((h) => h.toJson()).toList();
    await _prefs?.setStringList(_keyHistory, rawList);
  }

  static Future<void> clearHistory() async {
    await _prefs?.remove(_keyHistory);
  }

  // --- Bookmarks ---
  static final ValueNotifier<List<AnimeItem>> bookmarksNotifier =
      ValueNotifier<List<AnimeItem>>([]);

  static List<AnimeItem> getBookmarks() {
    final list = _prefs?.getStringList(_keyBookmarks) ?? [];
    return list.map((item) => AnimeItem.fromJson(item)).toList();
  }

  static bool _matchesAnime(AnimeItem a, String id, String slug, {String title = ''}) {
    if (id.isNotEmpty && a.id.isNotEmpty && a.id == id) return true;
    if (slug.isNotEmpty && a.slug.isNotEmpty && a.slug == slug) return true;
    if (title.isNotEmpty && a.title.isNotEmpty && a.title.trim().toLowerCase() == title.trim().toLowerCase()) return true;
    return false;
  }

  static bool isBookmarked(String animeId, String slug, {String title = ''}) {
    final bookmarks = getBookmarks();
    return bookmarks.any((b) => _matchesAnime(b, animeId, slug, title: title));
  }

  static void refreshBookmarks() {
    bookmarksNotifier.value = getBookmarks();
  }

  static Future<bool> toggleBookmark(AnimeItem anime) async {
    final bookmarks = getBookmarks();
    final index = bookmarks.indexWhere(
      (b) => _matchesAnime(b, anime.id, anime.slug, title: anime.title),
    );

    bool nowBookmarked;
    if (index >= 0) {
      bookmarks.removeAt(index);
      nowBookmarked = false;
    } else {
      bookmarks.insert(0, anime);
      nowBookmarked = true;
    }

    final rawList = bookmarks.map((b) => b.toJson()).toList();
    await _prefs?.setStringList(_keyBookmarks, rawList);
    bookmarksNotifier.value = List.unmodifiable(bookmarks);
    return nowBookmarked;
  }

  // --- Downloads ---
  static List<DownloadItem> getDownloads() {
    final list = _prefs?.getStringList(_keyDownloads) ?? [];
    return list.map((item) => DownloadItem.fromJson(item)).toList();
  }

  static Future<void> saveDownload(DownloadItem item) async {
    final list = getDownloads();
    list.removeWhere((d) =>
        d.animeId == item.animeId && d.episodeNumber == item.episodeNumber);
    list.insert(0, item);
    final rawList = list.map((d) => d.toJson()).toList();
    await _prefs?.setStringList(_keyDownloads, rawList);
  }

  static Future<void> deleteDownload(String animeId, int episodeNumber) async {
    final list = getDownloads();
    list.removeWhere(
        (d) => d.animeId == animeId && d.episodeNumber == episodeNumber);
    final rawList = list.map((d) => d.toJson()).toList();
    await _prefs?.setStringList(_keyDownloads, rawList);
  }

  static Future<void> clearDownloads() async {
    await _prefs?.remove(_keyDownloads);
  }

  // --- Preferences ---
  static bool get isDub => _prefs?.getBool(_keyPrefDub) ?? false;
  static Future<void> setDub(bool value) async {
    await _prefs?.setBool(_keyPrefDub, value);
  }

  static String get preferredPlayer => _prefs?.getString(_keyPrefPlayer) ?? 'internal';
  static Future<void> setPreferredPlayer(String value) async {
    await _prefs?.setString(_keyPrefPlayer, value);
  }

  static String get quality => _prefs?.getString(_keyPrefQuality) ?? '720p';
  static Future<void> setQuality(String value) async {
    await _prefs?.setString(_keyPrefQuality, value);
  }

  static String get subLanguage => _prefs?.getString(_keySubLanguage) ?? 'id';
  static Future<void> setSubLanguage(String value) async {
    await _prefs?.setString(_keySubLanguage, value);
  }

  static bool get autoSkipIntro =>
      _prefs?.getBool(_keyAutoSkipIntro) ?? false;
  static Future<void> setAutoSkipIntro(bool value) async {
    await _prefs?.setBool(_keyAutoSkipIntro, value);
  }

  // --- Theme Mode ---
  static String get themeModeString =>
      _prefs?.getString(_keyThemeMode) ?? 'light';

  static ThemeMode get themeMode {
    final str = themeModeString;
    if (str == 'dark') return ThemeMode.dark;
    if (str == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    String str = 'dark';
    if (mode == ThemeMode.light) str = 'light';
    if (mode == ThemeMode.system) str = 'system';
    await _prefs?.setString(_keyThemeMode, str);
    AppTheme.updateThemeMode(mode);
  }

  // --- Onboarding ---
  static bool get isOnboardingCompleted =>
      _prefs?.getBool(_keyOnboardingCompleted) ?? false;

  static Future<void> setOnboardingCompleted(bool value) async {
    await _prefs?.setBool(_keyOnboardingCompleted, value);
  }
}
