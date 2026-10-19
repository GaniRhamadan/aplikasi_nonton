import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/services/subtitle_service.dart';

void main() {
  group('SubtitleService Tests', () {
    final service = SubtitleService();

    test('getSubtitleCacheDir returns an existing directory', () {
      final dir = service.getSubtitleCacheDir();
      expect(dir.existsSync(), isTrue);
    });

    test('getCacheFile generates consistent and safe filename', () {
      const url = 'https://example.com/anime/subs/test.vtt';
      final file = service.getCacheFile(url, animeTitle: 'Solo Leveling', episodeNumber: 1);
      expect(file.path.endsWith('.id.vtt'), isTrue);
      expect(file.path.contains('solo_leveling_ep1'), isTrue);
    });

    test('Cached file hit returns path immediately', () async {
      const dummyUrl = 'https://example.com/cached_test.vtt';
      final cacheFile = service.getCacheFile(dummyUrl, animeTitle: 'Test Anime', episodeNumber: 1);
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsString('WEBVTT\n\n00:01.000 --> 00:03.000\nHalo dunia! Ini subtitle terjemahan yang panjang dan valid untuk tes cache hit.\n');

      final result = await service.getOrGenerateIndonesianSubtitle(
        englishVttUrl: dummyUrl,
        animeTitle: 'Test Anime',
        episodeNumber: 1,
      );

      expect(result, equals(cacheFile.path));
      expect(File(result!).existsSync(), isTrue);

      // Clean up
      if (cacheFile.existsSync()) {
        cacheFile.deleteSync();
      }
    });
  });
}
