import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_models.dart';

class StorageService {
  static const String _keyHistory = 'ani_history';
  static const String _keyBookmarks = 'ani_bookmarks';
  static const String _keyPrefDub = 'ani_pref_dub';
  static const String _keyPrefPlayer = 'ani_pref_player';
  static const String _keyPrefQuality = 'ani_pref_quality';
  static const String _keySubLanguage = 'ani_pref_sub_lang';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Watch History ---
  static List<WatchHistoryItem> getHistory() {
    final list = _prefs?.getStringList(_keyHistory) ?? [];
    return list.map((item) => WatchHistoryItem.fromJson(item)).toList();
  }

  static Future<void> saveHistory(WatchHistoryItem item) async {
    final history = getHistory();
    // Remove previous entry for this anime to avoid duplicates
    history.removeWhere((h) => h.animeId == item.animeId || h.animeSlug == item.animeSlug);
    // Insert at front (most recent)
    history.insert(0, item);

    // Keep max 50 items
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    final rawList = history.map((h) => h.toJson()).toList();
    await _prefs?.setStringList(_keyHistory, rawList);
  }

  static Future<void> clearHistory() async {
    await _prefs?.remove(_keyHistory);
  }

  // --- Bookmarks ---
  static List<AnimeItem> getBookmarks() {
    final list = _prefs?.getStringList(_keyBookmarks) ?? [];
    return list.map((item) => AnimeItem.fromJson(item)).toList();
  }

  static bool isBookmarked(String animeId, String slug) {
    final bookmarks = getBookmarks();
    return bookmarks.any((b) => b.id == animeId || b.slug == slug);
  }

  static Future<bool> toggleBookmark(AnimeItem anime) async {
    final bookmarks = getBookmarks();
    final index = bookmarks.indexWhere((b) => b.id == anime.id || b.slug == anime.slug);

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
    return nowBookmarked;
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
}
