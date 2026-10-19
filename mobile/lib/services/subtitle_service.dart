import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SubtitleCueItem {
  final String? id;
  final String timestamp;
  final String originalText;
  String translatedText;

  SubtitleCueItem({
    this.id,
    required this.timestamp,
    required this.originalText,
    this.translatedText = '',
  });
}

class SubtitleService {
  static final SubtitleService _instance = SubtitleService._internal();
  factory SubtitleService() => _instance;
  SubtitleService._internal();

  /// Get cache directory for subtitles
  Directory getSubtitleCacheDir() {
    try {
      if (!kIsWeb && (Platform.isLinux || Platform.isMacOS)) {
        final home = Platform.environment['HOME'];
        if (home != null && home.isNotEmpty) {
          final dir = Directory('$home/.cache/anirama/subtitles');
          if (!dir.existsSync()) dir.createSync(recursive: true);
          return dir;
        }
      } else if (!kIsWeb && Platform.isWindows) {
        final appData = Platform.environment['LOCALAPPDATA'] ??
            Platform.environment['APPDATA'];
        if (appData != null && appData.isNotEmpty) {
          final dir = Directory('$appData\\Anirama\\subtitles');
          if (!dir.existsSync()) dir.createSync(recursive: true);
          return dir;
        }
      }
    } catch (_) {}

    final dir = Directory('${Directory.systemTemp.path}/anirama_subtitles');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Generates a persistent file cache path based on URL and episode info
  File getCacheFile(String englishVttUrl, {String? animeTitle, int? episodeNumber}) {
    final cacheDir = getSubtitleCacheDir();
    final hash = (englishVttUrl.hashCode.abs()).toRadixString(16);
    final cleanTitle = (animeTitle ?? 'anime')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final epSuffix = episodeNumber != null ? '_ep$episodeNumber' : '';
    final fileName = '$cleanTitle${epSuffix}_$hash.id.vtt';
    return File('${cacheDir.path}/$fileName');
  }

  /// Downloads English VTT, translates cues to Indonesian, and saves as a local .vtt file
  Future<String?> getOrGenerateIndonesianSubtitle({
    required String englishVttUrl,
    String? animeTitle,
    int? episodeNumber,
    void Function(String message)? onStatusUpdate,
  }) async {
    if (kIsWeb || englishVttUrl.isEmpty) return null;

    final cacheFile = getCacheFile(
      englishVttUrl,
      animeTitle: animeTitle,
      episodeNumber: episodeNumber,
    );

    // If already generated and valid, return cached file path immediately
    if (cacheFile.existsSync() && cacheFile.lengthSync() > 30) {
      debugPrint('Subtitle cache hit: ${cacheFile.path}');
      return cacheFile.path;
    }

    try {
      onStatusUpdate?.call('Mengunduh subtitle asli...');

      final response = await http.get(
        Uri.parse(englishVttUrl),
        headers: {
          'Referer': 'https://zokoanime.video/',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200 || response.body.isEmpty) {
        debugPrint('Failed to download English VTT: ${response.statusCode}');
        return null;
      }

      onStatusUpdate?.call('Menyiapkan terjemahan Bahasa Indonesia...');

      final cues = _parseVtt(response.body);
      if (cues.isEmpty) return null;

      // Translate cues
      final translatedCount =
          await _translateCues(cues, onStatusUpdate: onStatusUpdate);

      // Do not cache as Indonesian subtitle if translation failed or returned 0 translated cues
      if (translatedCount == 0 && cues.isNotEmpty) {
        debugPrint(
            'Subtitle translation failed: 0 cues translated. Not saving invalid cache.');
        return null;
      }

      // Write translated WebVTT file
      final sb = StringBuffer();
      sb.writeln('WEBVTT');
      sb.writeln('Kind: captions');
      sb.writeln('Language: id');
      sb.writeln();

      for (final cue in cues) {
        if (cue.id != null && cue.id!.isNotEmpty) {
          sb.writeln(cue.id);
        }
        sb.writeln(cue.timestamp);
        final text = cue.translatedText.isNotEmpty
            ? cue.translatedText
            : cue.originalText;
        sb.writeln(text);
        sb.writeln();
      }

      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsString(sb.toString(), encoding: utf8);
      debugPrint('Generated Indonesian Subtitle: ${cacheFile.path}');
      return cacheFile.path;
    } catch (e) {
      debugPrint('Error generating Indonesian subtitle: $e');
      return null;
    }
  }

  /// Parses raw WebVTT content into SubtitleCueItem list
  List<SubtitleCueItem> _parseVtt(String content) {
    final lines =
        content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final List<SubtitleCueItem> cues = [];
    String? currentId;
    String? currentTimestamp;
    List<String> curText = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (currentTimestamp != null && curText.isNotEmpty) {
          cues.add(SubtitleCueItem(
            id: currentId,
            timestamp: currentTimestamp,
            originalText: curText.join(' '),
          ));
        }
        currentId = null;
        currentTimestamp = null;
        curText = [];
      } else if (trimmed.contains('-->')) {
        currentTimestamp = trimmed;
      } else if (currentTimestamp != null) {
        curText.add(trimmed);
      } else if (trimmed != 'WEBVTT' &&
          !trimmed.startsWith('NOTE') &&
          !trimmed.startsWith('STYLE')) {
        currentId = trimmed;
      }
    }

    if (currentTimestamp != null && curText.isNotEmpty) {
      cues.add(SubtitleCueItem(
        id: currentId,
        timestamp: currentTimestamp,
        originalText: curText.join(' '),
      ));
    }

    return cues;
  }

  /// Translates cues in batches using Google Translate API POST
  Future<int> _translateCues(
    List<SubtitleCueItem> cues, {
    void Function(String message)? onStatusUpdate,
  }) async {
    if (cues.isEmpty) return 0;

    // Use smaller batch size (50 cues) to prevent timeouts, payload rejection and rate limits
    const int batchSize = 50;
    int successCount = 0;

    for (int i = 0; i < cues.length; i += batchSize) {
      final end = (i + batchSize < cues.length) ? i + batchSize : cues.length;
      final chunk = cues.sublist(i, end);

      if (cues.length > batchSize) {
        final chunkIndex = (i ~/ batchSize) + 1;
        final totalChunks = (cues.length / batchSize).ceil();
        onStatusUpdate?.call('Menerjemahkan dialog ($chunkIndex/$totalChunks)...');
      }

      final joinedText = chunk
          .map((c) => c.originalText.replaceAll('\n', ' ').trim())
          .join('\n');

      bool chunkSuccess = false;

      // Retry up to 2 times for each chunk
      for (int attempt = 0; attempt < 2 && !chunkSuccess; attempt++) {
        try {
          if (attempt > 0) {
            await Future.delayed(const Duration(milliseconds: 600));
          }

          final uri = Uri.parse('https://translate.googleapis.com/translate_a/single');
          final postRes = await http.post(
            uri,
            body: {
              'client': 'gtx',
              'sl': 'en',
              'tl': 'id',
              'dt': 't',
              'q': joinedText,
            },
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
            },
          ).timeout(const Duration(seconds: 15));

          if (postRes.statusCode == 200) {
            final decoded = json.decode(postRes.body);
            if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
              final sb = StringBuffer();
              for (final part in decoded[0]) {
                if (part is List && part.isNotEmpty) {
                  sb.write(part[0]);
                }
              }
              final transLines = sb.toString().split('\n');
              for (int j = 0; j < chunk.length; j++) {
                if (j < transLines.length && transLines[j].trim().isNotEmpty) {
                  chunk[j].translatedText = transLines[j].trim();
                  if (chunk[j].translatedText != chunk[j].originalText) {
                    successCount++;
                  }
                } else {
                  chunk[j].translatedText = chunk[j].originalText;
                }
              }
              chunkSuccess = true;
            }
          }
        } catch (e) {
          debugPrint(
              'Subtitle chunk translation attempt ${attempt + 1} warning: $e');
        }
      }

      if (!chunkSuccess) {
        // Fallback to original text for this chunk if both attempts failed
        for (final c in chunk) {
          c.translatedText = c.originalText;
        }
      }

      // Small pause between multiple chunks to respect rate limits
      if (end < cues.length) {
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    return successCount;
  }
}
