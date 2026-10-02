import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Curated poster URLs matching the modern anime streaming aesthetic
  static const List<String> _posterCol1 = [
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx131681-odsg4msU11d8.jpg', // Attack on Titan
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png', // Solo Leveling
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg', // Jujutsu Kaisen
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',     // Bleach
  ];

  static const List<String> _posterCol2 = [
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx140960-vN3RJZXxDdKy.jpg', // Spy x Family
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx130003-O0Jgq0oPzIqH.jpg', // Belle
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg', // Demon Slayer
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx127230-FloCoGoZOAOH.png', // Chainsaw Man
  ];

  static const List<String> _posterCol3 = [
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg', // Frieren
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',     // One Piece
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx150672-6Lp3zFf3sJq2.png', // Oshi no Ko
    'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg', // Kaiju No. 8
  ];

  final List<Map<String, String>> _onboardingPages = [
    {
      'title': 'Welcome to Animax',
      'subtitle':
          'The best streaming anime app of the century to entertain you every day',
    },
    {
      'title': 'Stream Anime Sub Indo',
      'subtitle':
          'Watch all your favorite anime series and movies with smooth high quality playback',
    },
    {
      'title': 'Always Up to Date',
      'subtitle':
          'Never miss the latest ongoing release episodes and seasonal anime updates',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0F1015),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await StorageService.setOnboardingCompleted(true);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      body: Stack(
        children: [
          // 1. Tilted Mosaic Anime Poster Grid in Background
          Positioned(
            top: -size.height * 0.12,
            left: -size.width * 0.22,
            right: -size.width * 0.22,
            height: size.height * 0.85,
            child: Transform.rotate(
              angle: -11 * (math.pi / 180),
              child: OverflowBox(
                maxWidth: size.width * 1.5,
                maxHeight: size.height * 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPosterColumn(_posterCol1, offsetY: -30),
                    const SizedBox(width: 14),
                    _buildPosterColumn(_posterCol2, offsetY: 25),
                    const SizedBox(width: 14),
                    _buildPosterColumn(_posterCol3, offsetY: -15),
                  ],
                ),
              ),
            ),
          ),

          // 2. Deep Gradient Vignette Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.60, 0.78, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    const Color(0xFF0F1015).withValues(alpha: 0.75),
                    const Color(0xFF0F1015).withValues(alpha: 0.96),
                    const Color(0xFF0F1015),
                  ],
                ),
              ),
            ),
          ),

          // 3. Foreground Content: Text Slider, Indicators & Action Button
          SafeArea(
            child: Column(
              children: [
                // Top skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Lewati'),
                    ),
                  ),
                ),
                const Spacer(),

                // Multi-page text carousel
                SizedBox(
                  height: 120,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingPages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _onboardingPages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              page['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              page['subtitle']!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Pagination Indicator matching screenshot
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingPages.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),

                const SizedBox(height: 28),

                // Action Button: "Get Started" in Vibrant Green
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingPages.length - 1
                            ? 'Get Started'
                            : 'Get Started',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterColumn(List<String> urls, {required double offsetY}) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: SizedBox(
        width: 135,
        child: Column(
          children: urls.map((url) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              height: 185,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFF1E212B),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF232734),
                      child: const Center(
                        child: Icon(
                          Icons.movie_outlined,
                          color: Colors.white24,
                          size: 36,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFF1C1F2A),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3.5),
      width: isActive ? 24 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
