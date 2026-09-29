import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final AnimeItem anime;
  final EpisodeItem initialEpisode;

  const PlayerScreen({
    super.key,
    required this.anime,
    required this.initialEpisode,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AnimeService _animeService = AnimeService();
  late EpisodeItem _currentEpisode;
  List<EpisodeItem> _allEpisodes = [];
  bool _isLoadingEpisodes = true;
  bool _isLoadingStream = true;
  String? _streamUrl;
  String? _errorMessage;
  late bool _isDub;
  bool _subIndoEnabled = true;
  WebViewController? _webViewController;
  bool _isFullscreen = false;

  // Multi-server state
  List<StreamServerItem> _availableServers = [];
  StreamServerItem? _selectedServer;
  String? _directM3u8Url;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.initialEpisode;
    _isDub = StorageService.isDub;
    _subIndoEnabled = StorageService.subLanguage == 'id';
    _loadEpisodes();
    _loadStreamForEpisode(_currentEpisode);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _isLoadingEpisodes = true);
    final eps =
        await _animeService.getEpisodes(widget.anime.id, widget.anime.slug);
    if (mounted) {
      setState(() {
        _allEpisodes = eps;
        _isLoadingEpisodes = false;
        if (_currentEpisode.id.isEmpty) {
          final found = eps.firstWhere(
            (e) => e.number == _currentEpisode.number,
            orElse: () => eps.isNotEmpty ? eps.first : _currentEpisode,
          );
          _currentEpisode = found;
          _loadStreamForEpisode(_currentEpisode);
        }
      });
    }
  }

  Future<void> _loadStreamForEpisode(EpisodeItem episode) async {
    setState(() {
      _isLoadingStream = true;
      _errorMessage = null;
      _streamUrl = null;
      _availableServers = [];
      _selectedServer = null;
      _directM3u8Url = null;
    });

    final totalEps = widget.anime.totalEpisodes > 0
        ? widget.anime.totalEpisodes
        : (widget.anime.subEpisodes > 0
            ? widget.anime.subEpisodes
            : _allEpisodes.length);

    await StorageService.saveHistory(
      WatchHistoryItem(
        animeId: widget.anime.id,
        animeSlug: widget.anime.slug,
        animeTitle: widget.anime.title,
        animePoster: widget.anime.posterUrl,
        episodeNumber: episode.number,
        episodeTitle: episode.title,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        totalEpisodes: totalEps,
        watchedEpisodes: [episode.number],
      ),
      totalEpisodes: totalEps,
    );

    String epId = episode.id;
    if (epId.isEmpty && _allEpisodes.isNotEmpty) {
      final match = _allEpisodes.firstWhere(
        (e) => e.number == episode.number,
        orElse: () => _allEpisodes.first,
      );
      epId = match.id;
    }

    final servers = await _animeService.getStreamServers(epId, isDub: _isDub);

    if (mounted) {
      if (servers.isNotEmpty) {
        // Automatically select the fastest CDN server (HD-1) by default
        final preferred = servers.first;
        _availableServers = servers;
        _selectedServer = preferred;
        _streamUrl = preferred.embedUrl;
        _initWebView(preferred.embedUrl);

        setState(() {
          _isLoadingStream = false;
        });

        // Resolve direct master.m3u8 in the background for instant native MPV/VLC playback
        _resolveDirectStreamForExternalPlayer(servers);
      } else {
        setState(() {
          _errorMessage =
              'Server video tidak merespons untuk Episode ${episode.number}. Anda dapat mencoba beralih ke ${_isDub ? "SUB" : "DUB"} atau membuka pemutar eksternal.';
          _isLoadingStream = false;
        });
      }
    }
  }

  Future<void> _resolveDirectStreamForExternalPlayer(
      List<StreamServerItem> servers) async {
    final zoko = servers.firstWhere(
      (s) =>
          s.name.toLowerCase().contains('zoko') ||
          s.embedUrl.contains('zokoanime'),
      orElse: () => servers.first,
    );
    if (zoko.embedUrl.contains('zokoanime')) {
      final m3u8 = await _animeService.getDirectM3u8Stream(zoko.embedUrl);
      if (mounted && m3u8 != null) {
        setState(() {
          _directM3u8Url = m3u8;
        });
      }
    }
  }

  void _switchServer(StreamServerItem server) {
    if (_selectedServer?.name == server.name &&
        _selectedServer?.type == server.type) {
      return;
    }
    setState(() {
      _selectedServer = server;
      _streamUrl = server.embedUrl;
      _isLoadingStream = true;
    });
    _initWebView(server.embedUrl);
    setState(() {
      _isLoadingStream = false;
    });
  }

  void _injectSubtitleTranslationScript() {
    final script = '''
      (function() {
        try {
          window.__subIndoEnabled = $_subIndoEnabled;

          // 1. Ensure CSS exists to hide default English cue text when Indo is active
          var hideStyle = document.getElementById('sub-hide-cues-style');
          if (!hideStyle) {
            hideStyle = document.createElement('style');
            hideStyle.id = 'sub-hide-cues-style';
            document.head.appendChild(hideStyle);
          }
          if (window.__subIndoEnabled) {
            hideStyle.innerHTML = 'video::cue { opacity: 0 !important; visibility: hidden !important; font-size: 0 !important; } .jw-text-track-cue { opacity: 0 !important; display: none !important; }';
          } else {
            hideStyle.innerHTML = '';
          }

          // 2. Setup Subtitle Overlay inside Player container
          var playerContainer = document.getElementById('megaplay-player') ||
                                document.querySelector('.mg3-player') ||
                                document.querySelector('.fix-area') ||
                                document.body;

          var overlay = document.getElementById('sub-id-overlay');
          if (!overlay) {
            overlay = document.createElement('div');
            overlay.id = 'sub-id-overlay';
            overlay.style.cssText = 'position:fixed;bottom:14%;left:50%;transform:translateX(-50%);background:rgba(0,0,0,0.85);color:#FFFFFF;padding:8px 18px;border-radius:8px;font-size:16px;font-weight:700;text-align:center;max-width:92%;z-index:2147483647;pointer-events:none;display:none;line-height:1.4;font-family:system-ui,-apple-system,sans-serif;text-shadow:0 2px 4px rgba(0,0,0,0.9);border:1.5px solid rgba(250,90,50,0.7);box-shadow:0 4px 14px rgba(0,0,0,0.6);';
            playerContainer.appendChild(overlay);
          } else if (overlay.parentElement !== playerContainer) {
            playerContainer.appendChild(overlay);
          }

          if (!window.__subIndoEnabled) {
            overlay.style.display = 'none';
          }

          // 3. Translation Cache & Fetcher
          var cache = window.__subCache || {};
          window.__subCache = cache;

          function translateText(text) {
            if (!text || text.trim() === '' || !window.__subIndoEnabled) {
              overlay.style.display = 'none';
              return;
            }
            text = text.replace(/<[^>]*>/g, '').trim();
            if (cache[text]) {
              overlay.innerText = cache[text];
              overlay.style.display = 'block';
              return;
            }
            fetch('https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=id&dt=t&q=' + encodeURIComponent(text))
              .then(function(r){ return r.json(); })
              .then(function(d){
                var trans = d[0].map(function(x){ return x[0]; }).join('');
                cache[text] = trans;
                if (window.__subIndoEnabled) {
                  overlay.innerText = trans;
                  overlay.style.display = 'block';
                }
              })
              .catch(function(){
                if (window.__subIndoEnabled) {
                  overlay.innerText = text;
                  overlay.style.display = 'block';
                }
              });
          }

          // 4. Attach Cues & Ensure English is Active
          function attachCueHandlers() {
            var video = document.querySelector('video');
            if (!video) return;

            if (video.textTracks && video.textTracks.length > 0) {
              for (var i = 0; i < video.textTracks.length; i++) {
                var track = video.textTracks[i];
                var lang = (track.language || track.label || '').toLowerCase();
                
                // If Indonesian is enabled, activate English track in hidden mode so cues stream
                if (window.__subIndoEnabled && (lang.indexOf('en') !== -1 || i === 0)) {
                  if (track.mode === 'disabled') {
                    track.mode = 'hidden';
                  }
                }

                if (!track.__hooked) {
                  track.__hooked = true;
                  track.oncuechange = function() {
                    if (!window.__subIndoEnabled) {
                      overlay.style.display = 'none';
                      return;
                    }
                    if (this.activeCues && this.activeCues.length > 0) {
                      translateText(this.activeCues[0].text);
                    } else {
                      overlay.style.display = 'none';
                    }
                  };
                }
              }
            }
          }

          // 5. Injects "Indonesian (Bahasa Indonesia)" directly into the player's CC popup menu
          function injectIndonesianOptionIntoPlayerCC() {
            try {
              var allElems = document.querySelectorAll('*');
              var sampleItem = null;

              for (var i = 0; i < allElems.length; i++) {
                var el = allElems[i];
                var t = (el.innerText || el.textContent || '').trim();
                if (t === 'German' || t === 'Italian' || t === 'English' || t === 'Russian' || t === 'Spanish') {
                  if (el.children.length <= 2 && el.offsetWidth > 0) {
                    sampleItem = el;
                    break;
                  }
                }
              }

              if (!sampleItem || !sampleItem.parentElement) return;
              var container = sampleItem.parentElement;

              if (container.querySelector('.sub-id-custom-cc')) {
                // Already injected, update active status
                var existing = container.querySelector('.sub-id-custom-cc');
                if (window.__subIndoEnabled) {
                  existing.style.color = '#FA5A32';
                  existing.style.fontWeight = 'bold';
                } else {
                  existing.style.color = '';
                  existing.style.fontWeight = 'normal';
                }
                return;
              }

              // Clone sampleItem to inherit player's exact font, padding, and layout
              var indoOption = sampleItem.cloneNode(true);
              indoOption.classList.add('sub-id-custom-cc');
              indoOption.id = 'sub-id-option';

              // Change text content to Indonesian
              var textNodeFound = false;
              function walkAndReplace(node) {
                if (node.nodeType === 3 && node.nodeValue.trim().length > 0 && !textNodeFound) {
                  node.nodeValue = 'Indonesian (Bahasa Indonesia) 🇮🇩';
                  textNodeFound = true;
                  return;
                }
                for (var c = 0; c < node.childNodes.length; c++) {
                  walkAndReplace(node.childNodes[c]);
                }
              }
              walkAndReplace(indoOption);
              if (!textNodeFound) {
                indoOption.innerText = 'Indonesian (Bahasa Indonesia) 🇮🇩';
              }

              if (window.__subIndoEnabled) {
                indoOption.style.color = '#FA5A32';
                indoOption.style.fontWeight = 'bold';
              }

              indoOption.onclick = function(ev) {
                ev.stopPropagation();
                window.__subIndoEnabled = true;

                // Mark selected in UI
                indoOption.style.color = '#FA5A32';
                indoOption.style.fontWeight = 'bold';
                var sibs = container.children;
                for (var s = 0; s < sibs.length; s++) {
                  if (sibs[s] !== indoOption) {
                    sibs[s].style.color = '';
                    sibs[s].style.fontWeight = 'normal';
                  }
                }

                // Enable English track mode in background
                attachCueHandlers();

                // Apply cue hiding
                if (hideStyle) {
                  hideStyle.innerHTML = 'video::cue { opacity: 0 !important; visibility: hidden !important; font-size: 0 !important; } .jw-text-track-cue { opacity: 0 !important; display: none !important; }';
                }

                // Toast notification inside player
                var toast = document.getElementById('sub-toast');
                if (!toast) {
                  toast = document.createElement('div');
                  toast.id = 'sub-toast';
                  toast.style.cssText = 'position:fixed;top:16%;left:50%;transform:translateX(-50%);background:rgba(250,90,50,0.92);color:#fff;padding:8px 18px;border-radius:20px;font-size:13px;font-weight:700;z-index:2147483647;pointer-events:none;transition:opacity 0.3s;box-shadow:0 4px 12px rgba(0,0,0,0.5);';
                  document.body.appendChild(toast);
                }
                toast.innerText = '✓ Subtitle Indonesia Aktif';
                toast.style.display = 'block';
                toast.style.opacity = '1';
                setTimeout(function() {
                  toast.style.opacity = '0';
                  setTimeout(function() { toast.style.display = 'none'; }, 300);
                }, 2200);
              };

              // Hook siblings so clicking another language disables the Indonesian overlay
              var siblings = container.children;
              for (var k = 0; k < siblings.length; k++) {
                (function(sib) {
                  if (!sib.__hookedClick) {
                    sib.__hookedClick = true;
                    var origClick = sib.onclick;
                    sib.addEventListener('click', function() {
                      window.__subIndoEnabled = false;
                      overlay.style.display = 'none';
                      if (hideStyle) hideStyle.innerHTML = '';
                      indoOption.style.color = '';
                      indoOption.style.fontWeight = 'normal';
                    });
                  }
                })(siblings[k]);
              }

              // Insert Indonesian right at the top of the list!
              container.insertBefore(indoOption, container.firstChild);
            } catch(e) {}
          }

          attachCueHandlers();
          injectIndonesianOptionIntoPlayerCC();

          if (!window.__subInterval) {
            window.__subInterval = setInterval(function() {
              attachCueHandlers();
              injectIndonesianOptionIntoPlayerCC();
            }, 800);
          }
        } catch(e) {}
      })();
    ''';
    _webViewController?.runJavaScript(script);
  }

  void _initWebView(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (finishedUrl) {
            _webViewController?.runJavaScript('''
              try {
                var el = document.getElementById('megaplay-player');
                if (el) {
                  el.style.width = '100vw';
                  el.style.height = '100vh';
                  el.style.position = 'fixed';
                  el.style.top = '0';
                  el.style.left = '0';
                  el.style.zIndex = '999999';
                }
              } catch(e) {}
            ''');
            _injectSubtitleTranslationScript();
          },
        ),
      )
      ..loadRequest(
        Uri.parse(url),
        headers: {
          'Referer': 'https://hianime.at/',
        },
      );
  }

  void _toggleSubtitleIndonesia() {
    setState(() {
      _subIndoEnabled = !_subIndoEnabled;
    });
    StorageService.setSubLanguage(_subIndoEnabled ? 'id' : 'en');
    _injectSubtitleTranslationScript();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _subIndoEnabled
              ? 'Subtitle Indonesia diaktifkan (Terjemahan Otomatis)'
              : 'Subtitle beralih ke teks bawaan (English CC)',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  Future<void> _openInExternalPlayer() async {
    final targetUrl = _directM3u8Url ?? _streamUrl;
    if (targetUrl == null || targetUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan video belum siap untuk diputar eksternal'),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(targetUrl);
      final isDirectM3u8 = targetUrl.contains('.m3u8');

      if (mounted && isDirectM3u8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membuka stream video langsung (M3U8) di MPV / VLC...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka pemutar eksternal'),
          ),
        );
      }
    }
  }

  void _showMpvGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.subtitles, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Subtitle Indonesia di MPV'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cara menampilkan Subtitle Indonesia di aplikasi MPV Android:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Saat video berputar di MPV, tekan tombol Subtitle (ikon kotak dialog/CC).\n'
              '2. Pilih "Cari Subtitle Online" atau "OpenSubtitles".\n'
              '3. Pilih bahasa "Indonesian (id)" untuk langsung mengunduh dan memasang subtitle Indonesia secara otomatis!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _goToPreviousEpisode() {
    if (_allEpisodes.isEmpty) return;
    final currentIndex =
        _allEpisodes.indexWhere((e) => e.number == _currentEpisode.number);
    if (currentIndex > 0) {
      final prev = _allEpisodes[currentIndex - 1];
      setState(() => _currentEpisode = prev);
      _loadStreamForEpisode(prev);
    }
  }

  void _goToNextEpisode() {
    if (_allEpisodes.isEmpty) return;
    final currentIndex =
        _allEpisodes.indexWhere((e) => e.number == _currentEpisode.number);
    if (currentIndex >= 0 && currentIndex < _allEpisodes.length - 1) {
      final next = _allEpisodes[currentIndex + 1];
      setState(() => _currentEpisode = next);
      _loadStreamForEpisode(next);
    }
  }

  void _showEpisodePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Episode (${_allEpisodes.length})',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _allEpisodes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ep = _allEpisodes[index];
                      final isCurrent = ep.number == _currentEpisode.number;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          if (!isCurrent) {
                            setState(() => _currentEpisode = ep);
                            _loadStreamForEpisode(ep);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.accentMuted
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.accent
                                  : AppColors.border,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.accent
                                      : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '${ep.number}',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ep.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isCurrent
                                        ? AppColors.accent
                                        : AppColors.textPrimary,
                                    fontWeight: isCurrent
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                const Icon(Icons.play_circle_filled,
                                    color: AppColors.accent, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildPlayerView(),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit,
                    color: Colors.white, size: 28),
                onPressed: _toggleFullscreen,
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex =
        _allEpisodes.indexWhere((e) => e.number == _currentEpisode.number);
    final hasPrev = currentIndex > 0;
    final hasNext =
        currentIndex >= 0 && currentIndex < _allEpisodes.length - 1;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.anime.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            Text(
              'Episode ${_currentEpisode.number}: ${_currentEpisode.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Layar Penuh',
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildPlayerView(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Title
                  Text(
                    'Episode ${_currentEpisode.number}: ${_currentEpisode.title}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Server Selector (HD-1 Cepat, HD-2, Vidstream, ZokoAnime)
                  if (_availableServers.length > 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded,
                                size: 16, color: AppColors.accent),
                            SizedBox(width: 4),
                            Text(
                              'Server Video:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Ganti jika buffering / lambat',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableServers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (ctx, idx) {
                          final server = _availableServers[idx];
                          final isSelected =
                              server.name == _selectedServer?.name &&
                                  server.type == _selectedServer?.type;
                          final isFast =
                              server.name.toLowerCase().contains('hd-1');
                          return InkWell(
                            onTap: () => _switchServer(server),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isFast) ...[
                                    Icon(
                                      Icons.speed_rounded,
                                      size: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.accent,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    server.name + (isFast ? ' (Cepat)' : ''),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Sub Indo & Audio Controls Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.subtitles_rounded,
                                    size: 18, color: AppColors.accent),
                                SizedBox(width: 6),
                                Text(
                                  'Subtitle Indonesia',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _toggleSubtitleIndonesia,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _subIndoEnabled
                                      ? AppColors.accent
                                      : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _subIndoEnabled ? 'AKTIF' : 'NONAKTIF',
                                  style: TextStyle(
                                    color: _subIndoEnabled
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _subIndoEnabled
                              ? 'Teks dialog otomatis diterjemahkan ke Bahasa Indonesia di layar video.'
                              : 'Menampilkan teks bahasa Inggris bawaan server (English CC).',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141724),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF222638)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 1.5),
                                child: Icon(Icons.info_outline_rounded,
                                    size: 14, color: Color(0xFF4EE2EC)),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Server sumber aslinya hanya menyediakan CC bahasa asing (English, German, dll). Opsi "Indonesian" kini otomatis disuntikkan ke menu [CC] player & teks diterjemahkan real-time di layar.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9EA3B5),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Audio SUB / DUB Toggle Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilihan Audio Suara:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            _buildAudioPill('SUB (Jepang)', !_isDub, () {
                              if (_isDub) {
                                setState(() => _isDub = false);
                                StorageService.setDub(false);
                                _loadStreamForEpisode(_currentEpisode);
                              }
                            }),
                            _buildAudioPill('DUB (Inggris)', _isDub, () {
                              if (!_isDub) {
                                setState(() => _isDub = true);
                                StorageService.setDub(true);
                                _loadStreamForEpisode(_currentEpisode);
                              }
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Episode Navigation (Prev / Next) (min 48px touch targets)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: hasPrev ? _goToPreviousEpisode : null,
                          icon: const Icon(Icons.skip_previous, size: 20),
                          label: const Text('Sebelumnya'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: hasNext ? _goToNextEpisode : null,
                          icon: const Icon(Icons.skip_next, size: 20),
                          label: const Text('Berikutnya'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Action Buttons: Select Episode
                  OutlinedButton.icon(
                    onPressed: _showEpisodePickerSheet,
                    icon: const Icon(Icons.list_rounded,
                        color: AppColors.textPrimary),
                    label: Text(
                      _isLoadingEpisodes
                          ? 'Memuat Daftar Episode...'
                          : 'Daftar Episode (${_allEpisodes.length})',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Open External MPV/VLC Button & Guide
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openInExternalPlayer,
                          icon: const Icon(Icons.open_in_new,
                              color: AppColors.textSecondary),
                          label: const Text('Buka di MPV / VLC'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showMpvGuideDialog,
                        icon: const Icon(Icons.help_outline,
                            color: AppColors.textSecondary),
                        tooltip: 'Panduan Sub Indo di MPV',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  if (widget.anime.synopsis.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sinopsis',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.anime.synopsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPill(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerView() {
    if (_isLoadingStream) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
              SizedBox(height: 12),
              Text(
                'Menyiapkan pemutar video...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: const Color(0xFF1E293B),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.accent, size: 36),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _loadStreamForEpisode(_currentEpisode),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(130, 40),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_webViewController != null) {
      return WebViewWidget(controller: _webViewController!);
    }

    return Container(color: Colors.black);
  }
}
