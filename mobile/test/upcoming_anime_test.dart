import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/models/anime_models.dart';
import 'package:ani_mobile/screens/anime_detail_screen.dart';
import 'package:ani_mobile/widgets/anime_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Upcoming Anime Tests', () {
    test('AnimeItem.isUpcoming flags upcoming anime correctly', () {
      const blackCloverS2 = AnimeItem(
        id: '7222',
        slug: 'black-clover-season-2-7222',
        title: 'Black Clover Season 2',
        posterUrl: '',
        type: 'TV (? eps)',
        status: 'Not yet aired',
        statusBadge: 'Akan Datang',
        releaseDate: 'Sep 07, 2026',
      );

      expect(blackCloverS2.isUpcoming, isTrue);
      expect(blackCloverS2.displayEpisode, equals('Akan Datang'));

      const airedAnime = AnimeItem(
        id: '123',
        slug: 'naruto-123',
        title: 'Naruto',
        posterUrl: '',
        subEpisodes: 220,
        totalEpisodes: 220,
        status: 'Finished Airing',
      );

      expect(airedAnime.isUpcoming, isFalse);
      expect(airedAnime.displayEpisode, equals('Episode 220'));
    });

    testWidgets('AnimeCard renders Akan Datang badge for upcoming anime', (tester) async {
      const upcoming = AnimeItem(
        id: '7222',
        slug: 'black-clover-season-2-7222',
        title: 'Black Clover Season 2',
        posterUrl: '',
        status: 'Not yet aired',
        releaseDate: 'Sep 7, 2026',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              height: 240,
              child: AnimeCard(anime: upcoming),
            ),
          ),
        ),
      );

      // Verify that Akan Datang or release date is displayed
      expect(find.text('Sep 7, 2026'), findsOneWidget);
      expect(find.text('Rilis Sep 7, 2026'), findsOneWidget);
    });

    testWidgets('AnimeDetailScreen renders Akan Datang badge, info button and upcoming card', (tester) async {
      const upcoming = AnimeItem(
        id: '7222',
        slug: 'black-clover-season-2-7222',
        title: 'Black Clover Season 2',
        posterUrl: '',
        status: 'Not yet aired',
        statusBadge: 'Akan Datang',
        releaseDate: 'Sep 07, 2026',
        synopsis: 'The second season of Black Clover.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AnimeDetailScreen(anime: upcoming),
        ),
      );

      await tester.pumpAndSettle();

      // Check Akan Datang badge
      expect(find.text('Akan Datang'), findsWidgets);

      // Check Action Buttons: should have "Simpan ke My List" instead of "Play"
      expect(find.text('Simpan ke My List'), findsOneWidget);
      expect(find.text('Play'), findsNothing);

      // Check Episodes section has upcoming notice card
      expect(find.text('Episodes (Akan Datang)'), findsOneWidget);
      expect(find.text('Akan Datang (Belum Rilis)'), findsOneWidget);
    });
  });
}
