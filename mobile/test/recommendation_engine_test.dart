import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/models/anime_models.dart';
import 'package:ani_mobile/services/anime_service.dart';

void main() {
  group('Dynamic Recommendation Engine Tests', () {
    final animeService = AnimeService();

    test('Romance anime gets romance-aligned recommendations, NEVER action-only anime', () async {
      const romanceAnime = AnimeItem(
        id: '437',
        slug: 'kaguya-sama-love-is-war-1-437',
        title: 'Kaguya-sama: Love is War',
        posterUrl: 'https://cdn.anipixcdn.co/thumbnail/kaguya-sama.webp',
        genres: ['Romance', 'Comedy', 'School', 'Psychological'],
        synopsis: 'At the renowned Shuchiin Academy, Miyuki Shirogane and Kaguya Shinomiya engage in romantic mind games to make the other confess their love first.',
      );

      final result = await animeService.getRecommendationsForAnime(
        romanceAnime,
      );

      // Verify lists are populated
      expect(result.moreLikeThis.isNotEmpty, isTrue);
      expect(result.recommendations.isNotEmpty, isTrue);

      final allRecs = [...result.moreLikeThis, ...result.recommendations];

      // Verify the current anime itself is excluded
      for (final rec in allRecs) {
        expect(rec.id, isNot(romanceAnime.id));
        expect(rec.slug, isNot(romanceAnime.slug));
      }

      // Verify strict genre protection: no battle shounen / pure action without romance
      for (final rec in allRecs) {
        final recGenresLower = rec.genres.map((g) => g.toLowerCase()).toSet();
        final hasRomanceOrComedy =
            recGenresLower.contains('romance') ||
            recGenresLower.contains('comedy') ||
            recGenresLower.contains('school') ||
            recGenresLower.contains('slice of life') ||
            recGenresLower.contains('drama');

        expect(
          hasRomanceOrComedy,
          isTrue,
          reason:
              '${rec.title} with genres ${rec.genres} is not suitable for Romance recommendation',
        );

        // Solo Leveling or One Piece must NEVER appear as recommendations for Kaguya-sama!
        expect(rec.title.toLowerCase().contains('solo leveling'), isFalse);
        expect(rec.title.toLowerCase().contains('one piece'), isFalse);
        expect(rec.title.toLowerCase().contains('attack on titan'), isFalse);
      }
    });

    test(
      'Action anime gets action-aligned recommendations, NEVER pure romance',
      () async {
        const actionAnime = AnimeItem(
          id: '235',
          slug: 'solo-leveling-235',
          title: 'Solo Leveling',
          posterUrl: 'https://cdn.anipixcdn.co/thumbnail/solo-leveling.webp',
          genres: ['Action', 'Adventure', 'Fantasy'],
          synopsis: 'In a world where hunters battle dungeon monsters, Sung Jinwoo awakens as the Shadow Monarch.',
        );

        final result = await animeService.getRecommendationsForAnime(
          actionAnime,
        );

        expect(result.moreLikeThis.isNotEmpty, isTrue);
        expect(result.recommendations.isNotEmpty, isTrue);

        final allRecs = [...result.moreLikeThis, ...result.recommendations];

        for (final rec in allRecs) {
          expect(rec.id, isNot(actionAnime.id));
          expect(rec.slug, isNot(actionAnime.slug));

          // Pure romance titles should not appear in Solo Leveling recommendations
          expect(
            rec.title.toLowerCase().contains('rent-a-girlfriend'),
            isFalse,
          );
          expect(rec.title.toLowerCase().contains('kaguya-sama'), isFalse);
          expect(rec.title.toLowerCase().contains('angel next door'), isFalse);
        }
      },
    );

    test('Sports anime gets sports recommendations', () async {
      const sportsAnime = AnimeItem(
        id: '771',
        slug: 'haikyu-to-the-top-771',
        title: 'Haikyu!!',
        posterUrl: 'https://cdn.anipixcdn.co/thumbnail/haikyuu.webp',
        genres: ['Sports', 'School', 'Team Sports'],
        synopsis: 'Shoyo Hinata and Tobio Kageyama strive to lead the Karasuno volleyball team to national championships.',
      );

      final result = await animeService.getRecommendationsForAnime(sportsAnime);

      expect(result.moreLikeThis.isNotEmpty, isTrue);
      expect(result.recommendations.isNotEmpty, isTrue);

      final allRecs = [...result.moreLikeThis, ...result.recommendations];

      // At least some sports titles should be recommended (Blue Lock, Kuroko, Ao Ashi, etc.)
      final hasSports = allRecs.any(
        (r) =>
            r.genres.any((g) => g.toLowerCase().contains('sport')) ||
            r.title.contains('Blue Lock') ||
            r.title.contains('Kuroko') ||
            r.title.contains('Ao Ashi') ||
            r.title.contains('Ippo'),
      );
      expect(hasSports, isTrue);
    });

    test('Different anime produce different recommendations (no static single template)', () async {
      const romanceAnime = AnimeItem(
        id: '15733',
        slug: 'horimiya-15733',
        title: 'Horimiya',
        posterUrl: 'https://cdn.anipixcdn.co/thumbnail/horimiya.webp',
        genres: ['Romance', 'Comedy', 'School'],
        synopsis: 'Two students with secret personalities discover each other outside school.',
      );

      const actionAnime = AnimeItem(
        id: '320',
        slug: 'demon-slayer-320',
        title: 'Demon Slayer',
        posterUrl: 'https://cdn.anipixcdn.co/thumbnail/demon-slayer.webp',
        genres: ['Action', 'Fantasy', 'Supernatural'],
        synopsis: 'Tanjiro battles demons with his nichirin blade.',
      );

      final romanceRecs = await animeService.getRecommendationsForAnime(
        romanceAnime,
      );
      final actionRecs = await animeService.getRecommendationsForAnime(
        actionAnime,
      );

      final romanceTitles = romanceRecs.recommendations
          .map((a) => a.title)
          .toSet();
      final actionTitles = actionRecs.recommendations
          .map((a) => a.title)
          .toSet();

      // Recommendations between completely different genres must not be identical
      final overlap = romanceTitles.intersection(actionTitles);
      expect(overlap.length, lessThan(romanceTitles.length));
      expect(romanceTitles, isNot(equals(actionTitles)));
    });

    test('inferGenresFromText correctly detects genres from title and synopsis keywords', () {
      final romanceGenres = AnimeService.inferGenresFromText(
        'The Girl I Like Forgot Her Glasses',
        'Kaede falls in love with Mie and helps her when she forgets her glasses at school.',
      );
      expect(romanceGenres.contains('Romance'), isTrue);

      final sportsGenres = AnimeService.inferGenresFromText(
        'Blue Lock',
        'Strikers compete in an intense soccer training tournament.',
      );
      expect(sportsGenres.contains('Sports'), isTrue);

      final fantasyGenres = AnimeService.inferGenresFromText(
        'That Time I Got Reincarnated as a Slime',
        'A corporate worker dies and is reincarnated into a magical fantasy dungeon world as a slime.',
      );
      expect(fantasyGenres.contains('Fantasy'), isTrue);
    });
  });
}
