import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/download_progress_dialog.dart';
import '../widgets/player_episode_drawer.dart';
import '../widgets/video_player_overlay.dart';

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
  String _currentSubtitleText = '';

  // Multi-server state
  List<StreamServerItem> _availableServers = [];
  StreamServerItem? _selectedServer;
  String? _directM3u8Url;

  // Custom Video Player Controls State
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 24, seconds: 20);
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _isLocked = false;
  double _playbackSpeed = 1.0;
  Timer? _sleepTimer;
  bool _isEpisodeDrawerOpen = false;
  bool _isControlsVisible = true;

  // Skip Intro / Outro State
  bool _isIntroActive = false;
  double? _introStart;
  double? _introEnd;
  bool _isOutroActive = false;
  double? _outroStart;
  double? _outroEnd;
  late bool _autoSkipIntro;

  // Buffering & Network Lag Watchdog State
  bool _isBuffering = false;
  bool _isNetworkStalled = false;
  int _stallSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.initialEpisode;
    _isDub = StorageService.isDub;
    _subIndoEnabled = StorageService.subLanguage == 'id';
    _autoSkipIntro = StorageService.autoSkipIntro;
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
    _sleepTimer?.cancel();
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
      _currentSubtitleText = '';
      _isIntroActive = false;
      _introStart = null;
      _introEnd = null;
      _isOutroActive = false;
      _outroStart = null;
      _outroEnd = null;
      _isBuffering = false;
      _isNetworkStalled = false;
      _stallSeconds = 0;
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
        final isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows);
        if (!isDesktop) {
          _initWebView(preferred.embedUrl);
        }

        setState(() {
          _isLoadingStream = false;
        });

        // Resolve direct master.m3u8 in the background for instant native MPV/VLC playback
        _resolveDirectStreamForExternalPlayer(servers);
      } else {
        final isUpcoming = widget.anime.isUpcoming ||
            _allEpisodes.isEmpty ||
            (widget.anime.status?.toLowerCase().contains('not yet') == true);
        setState(() {
          if (isUpcoming) {
            final rel = widget.anime.releaseDate != null
                ? ' Dijadwalkan rilis: ${widget.anime.releaseDate}'
                : '';
            _errorMessage =
                'Anime "${widget.anime.title}" belum resmi rilis di server streaming (Akan Datang).$rel';
          } else {
            _errorMessage =
                'Server video tidak merespons untuk Episode ${episode.number}. Anda dapat mencoba beralih ke ${_isDub ? "SUB" : "DUB"} atau membuka pemutar eksternal.';
          }
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
      _currentSubtitleText = '';
    });
    final isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows);
    if (!isDesktop) {
      _initWebView(server.embedUrl);
    }
    setState(() {
      _isLoadingStream = false;
    });
  }

  final Map<String, String> _translationCache = {};

  Future<void> _handleSubChannelMessage(String raw) async {
    try {
      final data = json.decode(raw);
      if (data is! Map) return;

      final action = data['action']?.toString() ?? '';

      if (action == 'enable') {
        if (!_subIndoEnabled) {
          setState(() {
            _subIndoEnabled = true;
          });
          StorageService.setSubLanguage('id');
        }
      } else if (action == 'disable') {
        if (_subIndoEnabled) {
          setState(() {
            _subIndoEnabled = false;
            _currentSubtitleText = '';
          });
          StorageService.setSubLanguage('en');
        }
      } else if (action == 'cue' || action == 'translate') {
        final text = data['text']?.toString() ?? '';
        final clean = text.trim();
        if (clean.isEmpty) {
          if (mounted && _currentSubtitleText.isNotEmpty) {
            setState(() {
              _currentSubtitleText = '';
            });
          }
          return;
        }

        if (!_subIndoEnabled) return;

        // Strictly reject HLS stream metadata / ID3 / discontinuity cues
        if (!_isValidSubtitleCue(clean)) {
          if (mounted &&
              _currentSubtitleText.isNotEmpty &&
              !_isValidSubtitleCue(_currentSubtitleText)) {
            setState(() {
              _currentSubtitleText = '';
            });
          }
          return;
        }

        // If translation is already cached, show it instantly
        if (_translationCache.containsKey(clean)) {
          if (mounted) {
            setState(() {
              _currentSubtitleText = _translationCache[clean]!;
            });
          }
          return;
        }

        final translated = await _translateText(clean);
        if (mounted && _subIndoEnabled && _isValidSubtitleCue(translated)) {
          setState(() {
            _currentSubtitleText = translated;
          });
        }
      } else if (action == 'clear') {
        if (mounted && _currentSubtitleText.isNotEmpty) {
          setState(() {
            _currentSubtitleText = '';
          });
        }
      }
    } catch (_) {}
  }

  bool _isValidSubtitleCue(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return false;
    if (clean.startsWith('{') ||
        clean.startsWith('[') ||
        clean.endsWith('}') ||
        clean.endsWith(']')) {
      return false;
    }
    final lower = clean.toLowerCase();
    if (lower.contains('metadatatype') ||
        lower.contains('discontinuity') ||
        lower.contains('diskontinuitas') ||
        lower.contains('pts') ||
        lower.contains('#ext') ||
        lower.contains('segment') ||
        lower.contains('sequence')) {
      return false;
    }
    return true;
  }

  bool get _showSkipIntroButton {
    if (_introStart != null && _introEnd != null && _introEnd! > _introStart!) {
      final cur = _currentPosition.inSeconds.toDouble();
      if (cur >= _introStart! && cur < _introEnd!) {
        return true;
      }
    }
    return _isIntroActive;
  }

  bool get _showSkipOutroButton {
    if (_outroStart != null && _outroEnd != null && _outroEnd! > _outroStart!) {
      final cur = _currentPosition.inSeconds.toDouble();
      if (cur >= _outroStart! && cur < _outroEnd!) {
        return true;
      }
    }
    return _isOutroActive;
  }

  void _skipIntro() {
    final target = _introEnd ?? (_currentPosition.inSeconds + 85).toDouble();
    setState(() {
      _isIntroActive = false;
      _introStart = null;
      _currentPosition = Duration(seconds: target.toInt());
    });
    _webViewController?.runJavaScript(
      'window.__skipIntro && window.__skipIntro($target);',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.fast_forward_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 10),
              Text(
                'Intro berhasil dilewati',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _retryPlayback() {
    setState(() {
      _isBuffering = true;
      _isNetworkStalled = false;
    });
    final pos = _currentPosition.inSeconds;
    _webViewController?.runJavaScript(
      '''(function() {
        try {
          var v = document.querySelector('video');
          if (v) {
            v.currentTime = $pos;
            v.play();
          }
          if (typeof window.jwplayer === 'function') {
            var jw = window.jwplayer('megaplay-player') || window.jwplayer();
            jw.seek($pos);
            jw.play(true);
          }
        } catch(e) {}
      })();''',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh, color: AppColors.accent, size: 20),
              SizedBox(width: 10),
              Text('Menyambung kembali pemutaran video...'),
            ],
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _switchServerQuickly() {
    if (_availableServers.length <= 1) {
      _loadStreamForEpisode(_currentEpisode);
      return;
    }
    final currentIdx = _availableServers.indexWhere(
      (s) => s.embedUrl == _selectedServer?.embedUrl,
    );
    final nextIdx = (currentIdx + 1) % _availableServers.length;
    final nextServer = _availableServers[nextIdx];
    _switchServer(nextServer);
  }

  void _skipOutro() {
    final target = _outroEnd;
    setState(() {
      _isOutroActive = false;
      _outroStart = null;
    });
    _webViewController?.runJavaScript(
      'window.__skipOutro && window.__skipOutro($target);',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.skip_next_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 10),
              Text(
                'Ending berhasil dilewati',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePlayerChannelMessage(String raw) {
    try {
      final data = json.decode(raw);
      if (data is Map && data['action'] == 'state') {
        final currentSecs = (data['currentTime'] as num?)?.toDouble() ?? 0.0;
        final durSecs = (data['duration'] as num?)?.toDouble() ?? 1460.0;
        final paused = data['paused'] as bool? ?? false;
        final muted = data['muted'] as bool? ?? false;
        final rate = (data['playbackRate'] as num?)?.toDouble() ?? 1.0;
        final isIntro = data['isIntro'] as bool? ?? false;
        final introStart = (data['introStart'] as num?)?.toDouble();
        final introEnd = (data['introEnd'] as num?)?.toDouble();
        final isOutro = data['isOutro'] as bool? ?? false;
        final outroStart = (data['outroStart'] as num?)?.toDouble();
        final outroEnd = (data['outroEnd'] as num?)?.toDouble();
        final isBuffering = data['isBuffering'] as bool? ?? false;
        final isNetworkStalled = data['isNetworkStalled'] as bool? ?? false;
        final stallSecs = (data['stallSeconds'] as num?)?.toInt() ?? 0;

        if (mounted) {
          setState(() {
            _currentPosition = Duration(seconds: currentSecs.toInt());
            if (durSecs > 10) {
              _totalDuration = Duration(seconds: durSecs.toInt());
            }
            _isPlaying = !paused;
            _isMuted = muted;
            _playbackSpeed = rate;
            if (introStart != null && introStart > 0) _introStart = introStart;
            if (introEnd != null && introEnd > 0) _introEnd = introEnd;
            if (outroStart != null && outroStart > 0) _outroStart = outroStart;
            if (outroEnd != null && outroEnd > 0) _outroEnd = outroEnd;
            _isIntroActive = isIntro;
            _isOutroActive = isOutro;
            _isBuffering = isBuffering;
            _isNetworkStalled = isNetworkStalled;
            _stallSeconds = stallSecs;
          });

          if (_autoSkipIntro &&
              isIntro &&
              introEnd != null &&
              introEnd > currentSecs) {
            _skipIntro();
          }
        }
      }
    } catch (_) {}
  }

  void _injectPlayerControlScript() {
    const script = '''
      (function() {
        if (!window.__xhrHooked) {
          window.__xhrHooked = true;
          var origOpen = XMLHttpRequest.prototype.open;
          var origSend = XMLHttpRequest.prototype.send;
          XMLHttpRequest.prototype.open = function(method, url) {
            this.__reqUrl = String(url || '');
            return origOpen.apply(this, arguments);
          };
          XMLHttpRequest.prototype.send = function() {
            var self = this;
            if (this.__reqUrl && /getSources|sources/i.test(this.__reqUrl)) {
              this.addEventListener('load', function() {
                try {
                  var data = JSON.parse(self.responseText);
                  if (data) {
                    if (data.intro) {
                      var s = Number(data.intro[0] != null ? data.intro[0] : data.intro.start);
                      var e = Number(data.intro[1] != null ? data.intro[1] : data.intro.end);
                      if (!isNaN(s) && !isNaN(e) && e > s) {
                        window.__introData = [s, e];
                      }
                    }
                    if (data.outro) {
                      var os = Number(data.outro[0] != null ? data.outro[0] : data.outro.start);
                      var oe = Number(data.outro[1] != null ? data.outro[1] : data.outro.end);
                      if (!isNaN(os) && !isNaN(oe) && oe > os) {
                        window.__outroData = [os, oe];
                      }
                    }
                  }
                } catch(e) {}
              });
            }
            return origSend.apply(this, arguments);
          };
        }

        function checkIntroStatus(curTime) {
          try {
            var intro = null;
            if (window.__handleBridgeState && window.__handleBridgeState.intro) {
              intro = window.__handleBridgeState.intro;
            } else if (window.__introData) {
              intro = window.__introData;
            }
            var domBtn = document.getElementById('skip-intro-handle') ||
                         document.querySelector('.skip-intro, .skip-op, #skip-op, .jw-skip');
            var isDomActive = (domBtn && domBtn.offsetParent !== null && domBtn.style.display !== 'none');

            var isIntro = false;
            var introStart = 0;
            var introEnd = 0;
            if (intro && intro.length >= 2) {
              introStart = Number(intro[0]);
              introEnd = Number(intro[1]);
              if (curTime >= introStart && curTime < introEnd) {
                isIntro = true;
              }
            } else if (isDomActive) {
              isIntro = true;
              introEnd = curTime + 85;
            }

            var outro = null;
            if (window.__handleBridgeState && window.__handleBridgeState.outro) {
              outro = window.__handleBridgeState.outro;
            } else if (window.__outroData) {
              outro = window.__outroData;
            }
            var isOutro = false;
            var outroStart = 0;
            var outroEnd = 0;
            if (outro && outro.length >= 2) {
              outroStart = Number(outro[0]);
              outroEnd = Number(outro[1]);
              if (curTime >= outroStart && curTime < outroEnd) {
                isOutro = true;
              }
            }

            return {
              isIntro: isIntro,
              introStart: introStart,
              introEnd: introEnd,
              isOutro: isOutro,
              outroStart: outroStart,
              outroEnd: outroEnd
            };
          } catch(e) {
            return { isIntro: false, introStart: 0, introEnd: 0, isOutro: false, outroStart: 0, outroEnd: 0 };
          }
        }

        var isWaiting = false;
        var lastReportedTime = -1;
        var stallTicks = 0;
        var recoveryAttempts = 0;

        function hookVideo() {
          var v = document.querySelector('video');
          if (!v) return;
          if (v.__hookedByFlutter) return;
          v.__hookedByFlutter = true;

          function onWaiting() {
            isWaiting = true;
            postState();
          }

          function onPlaying() {
            isWaiting = false;
            stallTicks = 0;
            recoveryAttempts = 0;
            postState();
          }

          function onCanPlay() {
            isWaiting = false;
            postState();
          }

          function onStalled() {
            isWaiting = true;
            postState();
          }

          v.addEventListener('waiting', onWaiting);
          v.addEventListener('stalled', onStalled);
          v.addEventListener('playing', onPlaying);
          v.addEventListener('canplay', onCanPlay);

          function postState() {
            try {
              if (window.FlutterPlayerChannel) {
                var cur = v.currentTime || 0;
                var introInfo = checkIntroStatus(cur);
                var isBuffering = false;
                var isNetworkStalled = false;

                if (!v.paused) {
                  if (v.readyState < 3 || isWaiting) {
                    isBuffering = true;
                  }
                  if (cur === lastReportedTime && cur > 0) {
                    stallTicks++;
                    if (stallTicks >= 2) {
                      isBuffering = true;
                    }
                    if (stallTicks >= 6) {
                      try { v.play(); } catch(e) {}
                      if (typeof window.jwplayer === 'function') {
                        try { window.jwplayer().play(true); } catch(e) {}
                      }
                    }
                    if (stallTicks >= 10) {
                      isNetworkStalled = true;
                      if (recoveryAttempts < 2) {
                        recoveryAttempts++;
                        try {
                          v.currentTime = cur + 0.1;
                          v.play();
                        } catch(e) {}
                      }
                    }
                  } else {
                    lastReportedTime = cur;
                    stallTicks = 0;
                    recoveryAttempts = 0;
                  }
                } else {
                  stallTicks = 0;
                }

                window.FlutterPlayerChannel.postMessage(JSON.stringify({
                  action: 'state',
                  currentTime: cur,
                  duration: v.duration && !isNaN(v.duration) ? v.duration : 1460,
                  paused: v.paused,
                  muted: v.muted,
                  playbackRate: v.playbackRate || 1.0,
                  isBuffering: isBuffering,
                  isNetworkStalled: isNetworkStalled,
                  stallSeconds: Math.floor(stallTicks * 0.5),
                  isIntro: introInfo.isIntro,
                  introStart: introInfo.introStart,
                  introEnd: introInfo.introEnd,
                  isOutro: introInfo.isOutro,
                  outroStart: introInfo.outroStart,
                  outroEnd: introInfo.outroEnd
                }));
              }
            } catch(e) {}
          }

          v.addEventListener('timeupdate', postState);
          v.addEventListener('play', postState);
          v.addEventListener('pause', postState);
          v.addEventListener('volumechange', postState);
          v.addEventListener('ratechange', postState);
          v.addEventListener('loadedmetadata', postState);
          postState();
        }

        window.__togglePlay = function() {
          if (typeof window.jwplayer === 'function') {
            try {
              var jw = window.jwplayer('megaplay-player') || window.jwplayer('player') || window.jwplayer();
              if (jw && typeof jw.getState === 'function') {
                var s = jw.getState();
                if (s === 'playing') {
                  jw.pause();
                } else {
                  jw.play();
                }
                return;
              }
            } catch(e) {}
          }
          var v = document.querySelector('video');
          if (v) {
            if (v.paused) {
              var p = v.play();
              if (p && p.catch) {
                p.catch(function() {
                  v.muted = true;
                  v.play();
                });
              }
            } else {
              v.pause();
            }
          }
        };

        window.__seekVideo = function(seconds) {
          if (typeof window.jwplayer === 'function') {
            try {
              var jw = window.jwplayer('megaplay-player') || window.jwplayer('player') || window.jwplayer();
              if (jw && typeof jw.seek === 'function') {
                jw.seek(seconds);
              }
            } catch(e) {}
          }
          var v = document.querySelector('video');
          if (v) {
            try { v.currentTime = seconds; } catch(e) {}
          }
        };

        window.__seekRelative = function(delta) {
          if (typeof window.jwplayer === 'function') {
            try {
              var jw = window.jwplayer('megaplay-player') || window.jwplayer('player') || window.jwplayer();
              if (jw && typeof jw.getPosition === 'function' && typeof jw.seek === 'function') {
                var curPos = jw.getPosition() || 0;
                jw.seek(Math.max(0, curPos + delta));
                return;
              }
            } catch(e) {}
          }
          var v = document.querySelector('video');
          if (v) {
            var target = Math.max(0, (v.currentTime || 0) + delta);
            v.currentTime = target;
          }
        };

        window.__skipIntro = function(targetEnd) {
          try {
            var end = targetEnd;
            if (!end || isNaN(end) || end <= 0) {
              if (window.__handleBridgeState && window.__handleBridgeState.intro) {
                end = Number(window.__handleBridgeState.intro[1]);
              } else if (window.__introData) {
                end = Number(window.__introData[1]);
              }
            }
            var domBtn = document.getElementById('skip-intro-handle') ||
                         document.querySelector('.skip-intro, .skip-op, #skip-op, .jw-skip');
            if (domBtn) {
              try { domBtn.click(); } catch(e) {}
            }
            var v = document.querySelector('video');
            if (end && end > 0) {
              if (v) v.currentTime = end;
              if (typeof window.jwplayer === 'function') {
                try {
                  var jw = window.jwplayer('megaplay-player') || window.jwplayer();
                  if (jw && typeof jw.seek === 'function') jw.seek(end);
                } catch(e) {}
              }
            } else if (v) {
              v.currentTime = (v.currentTime || 0) + 85;
            }
          } catch(e) {}
        };

        window.__skipOutro = function(targetEnd) {
          try {
            var end = targetEnd;
            if (!end || isNaN(end) || end <= 0) {
              if (window.__handleBridgeState && window.__handleBridgeState.outro) {
                end = Number(window.__handleBridgeState.outro[1]);
              } else if (window.__outroData) {
                end = Number(window.__outroData[1]);
              }
            }
            var domBtn = document.getElementById('skip-outro-handle') ||
                         document.querySelector('.skip-outro, .skip-ed, #skip-ed');
            if (domBtn) {
              try { domBtn.click(); } catch(e) {}
            }
            var v = document.querySelector('video');
            if (end && end > 0) {
              if (v) v.currentTime = end;
              if (typeof window.jwplayer === 'function') {
                try {
                  var jw = window.jwplayer('megaplay-player') || window.jwplayer();
                  if (jw && typeof jw.seek === 'function') jw.seek(end);
                } catch(e) {}
              }
            } else if (v) {
              v.currentTime = (v.duration || (v.currentTime + 90));
            }
          } catch(e) {}
        };

        window.__setSpeed = function(rate) {
          var v = document.querySelector('video');
          if (v) v.playbackRate = rate;
        };

        window.__toggleMute = function() {
          var v = document.querySelector('video');
          if (v) v.muted = !v.muted;
        };

        function disableWebControls() {
          try {
            if (typeof window.jwplayer === 'function') {
              var jw = window.jwplayer('megaplay-player') || window.jwplayer('player') || window.jwplayer();
              if (jw && typeof jw.setControls === 'function') {
                jw.setControls(false);
              }
            }
          } catch(e) {}
          try {
            var vids = document.querySelectorAll('video');
            for (var i = 0; i < vids.length; i++) {
              vids[i].controls = false;
            }
          } catch(e) {}
          var hideCss = '.jw-controls, .jw-controls-backdrop, .jw-controlbar, .jw-display, .jw-display-controls, .jw-display-icon-container, .jw-display-icon-display, .jw-display-icon-rewind, .jw-display-icon-next, .jw-dock, .jw-dock-btn, .jw-title, .jw-title-primary, .jw-title-secondary, .jw-top, .jw-overlays, .jw-preview, .jwplayer .jw-controls, .jwplayer .jw-display, .jwplayer .jw-display-controls, .jwplayer .jw-display-icon-container, .jwplayer .jw-display-icon-display, .jwplayer .jw-display-icon-rewind, .jwplayer .osp-display-forward, .jwplayer[class*="centre-controls"] .jw-display, .jwplayer[class*="centre-controls"] .jw-display-icon-rewind, .jwplayer[class*="centre-controls"] .osp-display-forward, .jwplayer.osp-centre-controls .jw-display, .jwplayer.osp-centre-controls .jw-display-icon-rewind, .jwplayer.osp-centre-controls .osp-display-forward, .osp-centre-controls, .osp-display-forward, .osp-brand, .osp-skip, .osp-unmute, .osp-dl, .osp-qmenu, .float-pill, .card-top, .vjs-control-bar, .vjs-big-play-button, .vjs-modal-dialog, .vjs-dock-text, .vjs-dock-title, .art-controls, .art-bottom, .art-top, .art-state, .art-mask, .art-video-player .art-state, .art-video-player .art-controls, .art-video-player .art-top, .art-video-player .art-bottom, .plyr__controls, .plyr__control--overlaid, media-controls, media-video-layout, #overlay-control-handle, #skip-intro-handle, #skip-outro-handle, .skip-intro, .skip-op, .botright { display: none !important; opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; width: 0 !important; height: 0 !important; max-width: 0 !important; max-height: 0 !important; line-height: 0 !important; font-size: 0 !important; overflow: hidden !important; } video::-webkit-media-controls, video::-webkit-media-controls-enclosure, video::-webkit-media-controls-panel, video::-webkit-media-controls-play-button, video::-webkit-media-controls-timeline { display: none !important; }';
          try {
            var hideStyle = document.getElementById('web-player-hide-controls-style');
            if (!hideStyle) {
              hideStyle = document.createElement('style');
              hideStyle.id = 'web-player-hide-controls-style';
              document.head.appendChild(hideStyle);
            }
            hideStyle.innerHTML = hideCss;
          } catch(e) {}
          try {
            var controlEls = document.querySelectorAll('.jw-controls, .jw-controlbar, .jw-display, .jw-display-controls, .jw-display-icon-container, .jw-display-icon-display, .jw-display-icon-rewind, .osp-display-forward, .osp-centre-controls, .jw-dock, .jw-title, .osp-brand, .osp-unmute, .float-pill, .art-state, .art-controls, .art-top, .art-bottom, .vjs-big-play-button, .vjs-control-bar');
            for (var c = 0; c < controlEls.length; c++) {
              controlEls[c].style.setProperty('display', 'none', 'important');
              controlEls[c].style.setProperty('opacity', '0', 'important');
              controlEls[c].style.setProperty('visibility', 'hidden', 'important');
              controlEls[c].style.setProperty('pointer-events', 'none', 'important');
            }
          } catch(e) {}
          try {
            var iframes = document.querySelectorAll('iframe');
            for (var f = 0; f < iframes.length; f++) {
              try {
                var idoc = iframes[f].contentDocument || iframes[f].contentWindow.document;
                if (idoc) {
                  var istyle = idoc.getElementById('iframe-hide-controls-style');
                  if (!istyle) {
                    istyle = idoc.createElement('style');
                    istyle.id = 'iframe-hide-controls-style';
                    idoc.head.appendChild(istyle);
                  }
                  istyle.innerHTML = hideCss;
                  var icontrolEls = idoc.querySelectorAll('.jw-controls, .jw-controlbar, .jw-display, .jw-display-controls, .jw-display-icon-container, .jw-display-icon-display, .jw-display-icon-rewind, .osp-display-forward, .osp-centre-controls, .jw-dock, .jw-title, .osp-brand, .osp-unmute, .float-pill, .art-state, .art-controls, .art-top, .art-bottom, .vjs-big-play-button, .vjs-control-bar');
                  for (var ic = 0; ic < icontrolEls.length; ic++) {
                    icontrolEls[ic].style.setProperty('display', 'none', 'important');
                    icontrolEls[ic].style.setProperty('opacity', '0', 'important');
                    icontrolEls[ic].style.setProperty('visibility', 'hidden', 'important');
                    icontrolEls[ic].style.setProperty('pointer-events', 'none', 'important');
                  }
                }
              } catch(e) {}
            }
          } catch(e) {}
        }

        hookVideo();
        disableWebControls();
        if (!window.__videoHookInterval) {
          window.__videoHookInterval = setInterval(function() {
            hookVideo();
            disableWebControls();
          }, 1000);
        }
      })();
    ''';
    _webViewController?.runJavaScript(script);
  }

  Future<String> _translateText(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return clean;
    if (_translationCache.containsKey(clean)) {
      return _translationCache[clean]!;
    }

    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=id&dt=t&q=${Uri.encodeQueryComponent(clean)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final sb = StringBuffer();
          for (final part in decoded[0]) {
            if (part is List && part.isNotEmpty) {
              sb.write(part[0]);
            }
          }
          final translated = sb.toString();
          if (translated.isNotEmpty) {
            _translationCache[clean] = translated;
            return translated;
          }
        }
      }
    } catch (_) {}

    return clean;
  }

  void _injectSubtitleTranslationScript() {
    final script = '''
      (function() {
        try {
          window.__subIndoEnabled = $_subIndoEnabled;
          window.__subCache = window.__subCache || {};

          // 1. Hide all native and web player English cues completely
          var hideStyle = document.getElementById('sub-hide-cues-style');
          if (!hideStyle) {
            hideStyle = document.createElement('style');
            hideStyle.id = 'sub-hide-cues-style';
            document.head.appendChild(hideStyle);
          }
          if (window.__subIndoEnabled) {
            hideStyle.innerHTML = [
              'video::cue, ::cue, ::cue-region { color: transparent !important; background: transparent !important; background-color: transparent !important; text-shadow: none !important; font-size: 0.01px !important; line-height: 0.01px !important; height: 0 !important; width: 0 !important; opacity: 0 !important; visibility: hidden !important; }',
              '.jw-text-track-cue, .jw-captions-text, .jw-text-track-display, .art-subtitle, .art-subtitle-item, .art-subtitles, .vjs-text-track-cue, .vjs-text-track-display, div[class*="text-track-cue"], div[class*="caption-window"], #sub-id-overlay { display: none !important; opacity: 0 !important; visibility: hidden !important; color: transparent !important; background: transparent !important; font-size: 0px !important; pointer-events: none !important; }',
              '.jw-controlbar, .jw-dock, .jw-title, .vjs-control-bar, .art-bottom, .plyr__controls { display: none !important; opacity: 0 !important; pointer-events: none !important; }',
              'video::-webkit-media-controls, video::-webkit-media-controls-enclosure, video::-webkit-media-controls-panel { display: none !important; }'
            ].join(' ');
          } else {
            hideStyle.innerHTML = '';
          }

          // 2. Remove legacy DOM overlay if present (Flutter is the sole renderer)
          var oldOverlay = document.getElementById('sub-id-overlay');
          if (oldOverlay) {
            oldOverlay.remove();
          }

          function isValidSubtitleCue(t) {
            if (!t || typeof t !== 'string') return false;
            var s = t.trim();
            if (s.length === 0) return false;
            if (s.charAt(0) === '{' || s.charAt(0) === '[' || s.charAt(s.length - 1) === '}' || s.charAt(s.length - 1) === ']') return false;
            var lower = s.toLowerCase();
            if (lower.indexOf('metadatatype') !== -1 ||
                lower.indexOf('discontinuity') !== -1 ||
                lower.indexOf('diskontinuitas') !== -1 ||
                lower.indexOf('pts') !== -1 ||
                lower.indexOf('#ext') !== -1 ||
                lower.indexOf('segment') !== -1 ||
                lower.indexOf('sequence') !== -1) {
              return false;
            }
            return true;
          }

          function handleEngCue(text) {
            if (!text || text.trim() === '') {
              try {
                if (window.FlutterSubChannel) {
                  window.FlutterSubChannel.postMessage(JSON.stringify({action: 'clear'}));
                }
              } catch(e) {}
              return;
            }
            text = text.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').replace(/\\s+/g, ' ').trim();
            if (text === '' || !isValidSubtitleCue(text)) {
              try {
                if (window.FlutterSubChannel) {
                  window.FlutterSubChannel.postMessage(JSON.stringify({action: 'clear'}));
                }
              } catch(e) {}
              return;
            }

            window.__currentCue = text;

            // Transmit cue to Flutter Native Overlay
            try {
              if (window.FlutterSubChannel) {
                window.FlutterSubChannel.postMessage(JSON.stringify({
                  action: 'cue',
                  text: text
                }));
              }
            } catch(e) {}
          }

          // 3. Auto-activate captions in JWPlayer and HTML5 <video>
          function activateCaptions() {
            if (!window.__subIndoEnabled) return;

            // A. JWPlayer auto-activation
            try {
              var jw = null;
              if (typeof window.jwplayer === 'function') {
                jw = window.jwplayer('megaplay-player') || window.jwplayer();
              }
              if (jw && typeof jw.getCaptionsList === 'function') {
                var list = jw.getCaptionsList();
                if (list && list.length > 1) {
                  var current = jw.getCurrentCaptions();
                  var enIdx = -1;
                  var firstValidIdx = -1;
                  for (var i = 0; i < list.length; i++) {
                    var item = list[i] || {};
                    var label = (item.label || '').toLowerCase();
                    var id = (item.id || '').toLowerCase();
                    if (label !== 'off' && id !== 'off') {
                      if (firstValidIdx === -1) firstValidIdx = i;
                      if (label.indexOf('english') !== -1 || label.indexOf('eng') !== -1 || id === 'en' || id === 'eng') {
                        enIdx = i;
                        break;
                      }
                    }
                  }
                  var targetIdx = enIdx !== -1 ? enIdx : firstValidIdx;
                  if (targetIdx !== -1 && current !== targetIdx) {
                    jw.setCurrentCaptions(targetIdx);
                  }
                }

                if (!window.__jwEventsAttached && typeof jw.on === 'function') {
                  window.__jwEventsAttached = true;
                  jw.on('captionsList', function() { activateCaptions(); });
                  jw.on('ready', function() { activateCaptions(); });
                  jw.on('time', function() { scanCues(); });
                }
              }
            } catch(e) {}

            // B. HTML5 <video> textTracks auto-activation
            try {
              var vids = document.querySelectorAll('video');
              for (var v = 0; v < vids.length; v++) {
                var vid = vids[v];
                if (!vid.__eventsHooked) {
                  vid.__eventsHooked = true;
                  vid.addEventListener('timeupdate', function() { scanCues(); });
                  vid.addEventListener('play', function() { activateCaptions(); scanCues(); });
                }
                if (vid.textTracks && vid.textTracks.length > 0) {
                  for (var t = 0; t < vid.textTracks.length; t++) {
                    var tr = vid.textTracks[t];
                    if (tr.kind === 'metadata' || tr.kind === 'chapters') continue;
                    var trLang = ((tr.label || '') + ' ' + (tr.language || '')).toLowerCase();
                    if (tr.kind === 'captions' || tr.kind === 'subtitles' || trLang.indexOf('en') !== -1) {
                      if (tr.mode === 'disabled') {
                        tr.mode = 'hidden';
                      }
                      if (!tr.__cueHooked) {
                        tr.__cueHooked = true;
                        tr.oncuechange = function() { scanCues(); };
                      }
                    }
                  }
                }
              }
            } catch(e) {}
          }

          // 4. Fallback VTT fetch & timestamp parser
          function parseVtt(content) {
            var cues = [];
            var lines = content.split(/\\r?\\n/);
            var timeRegex = /(\\d{2}:)?(\\d{2}):(\\d{2})[.,](\\d{3})\\s*-->\\s*(\\d{2}:)?(\\d{2}):(\\d{2})[.,](\\d{3})/;
            var curr = null;
            function toSec(h, m, s, ms) {
              return (parseInt(h || '0', 10) * 3600) + (parseInt(m, 10) * 60) + parseInt(s, 10) + (parseInt(ms, 10) / 1000);
            }
            for (var i = 0; i < lines.length; i++) {
              var l = lines[i].trim();
              var m = l.match(timeRegex);
              if (m) {
                var start = toSec(m[1], m[2], m[3], m[4]);
                var end = toSec(m[5], m[6], m[7], m[8]);
                curr = { start: start, end: end, text: '' };
                cues.push(curr);
              } else if (curr && l && l !== 'WEBVTT' && !l.startsWith('NOTE') && isNaN(l)) {
                curr.text = (curr.text ? curr.text + ' ' : '') + l;
              }
            }
            return cues;
          }

          function tryLoadVttDirectly() {
            if (window.__vttLoaded || window.__vttLoading) return;
            var playerEl = document.getElementById('megaplay-player');
            var realId = playerEl ? playerEl.getAttribute('data-realid') : null;
            if (!realId) return;

            window.__vttLoading = true;
            fetch('/stream/getSources?id=' + realId, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
              .then(function(r) { return r.json(); })
              .then(function(data) {
                if (data && data.tracks && data.tracks.length > 0) {
                  var vttUrl = null;
                  for (var i = 0; i < data.tracks.length; i++) {
                    var tr = data.tracks[i];
                    var lbl = (tr.label || '').toLowerCase();
                    if (lbl.indexOf('en') !== -1 || tr.default) {
                      vttUrl = tr.file;
                      break;
                    }
                  }
                  if (!vttUrl && data.tracks[0].file) vttUrl = data.tracks[0].file;
                  if (vttUrl) {
                    fetch(vttUrl)
                      .then(function(vr) { return vr.text(); })
                      .then(function(vttText) {
                        window.__parsedVttCues = parseVtt(vttText);
                        window.__vttLoaded = true;
                        window.__vttLoading = false;
                      })
                      .catch(function() { window.__vttLoading = false; });
                  }
                }
              })
              .catch(function() { window.__vttLoading = false; });
          }

          // 5. Scan & Observe Cues from all sources (DOM, textTracks, VTT fallback)
          function scanCues() {
            if (!window.__subIndoEnabled) return;

            // Source 1: DOM cues (JWPlayer, MegaCloud, VideoJS)
            var cueEls = document.querySelectorAll('.jw-text-track-cue, .jw-captions-text, .jw-cue, .vjs-text-track-cue, div[class*="text-track-cue"], div[class*="caption-window"], div[class*="subtitle-cue"], .art-subtitle-item');
            var domCue = '';
            if (cueEls.length > 0) {
              for (var c = 0; c < cueEls.length; c++) {
                var t = (cueEls[c].innerText || cueEls[c].textContent || '').trim();
                if (isValidSubtitleCue(t)) domCue += t + ' ';
              }
              domCue = domCue.trim();
            }

            // Source 2: HTML5 textTracks active cues (Strictly ignore metadata)
            var videoCue = '';
            var video = document.querySelector('video');
            if (video && video.textTracks) {
              for (var i = 0; i < video.textTracks.length; i++) {
                var tr = video.textTracks[i];
                if (tr.kind === 'metadata' || tr.kind === 'chapters') continue;
                if (tr.kind !== 'captions' && tr.kind !== 'subtitles') continue;
                if (tr.activeCues && tr.activeCues.length > 0) {
                  for (var j = 0; j < tr.activeCues.length; j++) {
                    var ct = (tr.activeCues[j].text || '').trim();
                    if (isValidSubtitleCue(ct)) videoCue += ct + ' ';
                  }
                }
              }
              videoCue = videoCue.trim();
            }

            // Source 3: Direct VTT timestamp cues
            var vttCue = '';
            if (video && window.__parsedVttCues && window.__parsedVttCues.length > 0) {
              var curTime = video.currentTime;
              for (var k = 0; k < window.__parsedVttCues.length; k++) {
                var vc = window.__parsedVttCues[k];
                if (curTime >= vc.start && curTime <= vc.end) {
                  var vt = (vc.text || '').trim();
                  if (isValidSubtitleCue(vt)) {
                    vttCue = vt;
                    break;
                  }
                }
              }
            }

            var chosen = domCue || videoCue || vttCue;
            if (chosen && chosen.length > 0 && isValidSubtitleCue(chosen)) {
              if (chosen !== window.__lastObservedCue) {
                window.__lastObservedCue = chosen;
                handleEngCue(chosen);
              }
              return;
            }

            // If no cues found anywhere (silence / dialogue gap)
            if (window.__lastObservedCue !== '') {
              window.__lastObservedCue = '';
              window.__currentCue = '';
              try {
                if (window.FlutterSubChannel) {
                  window.FlutterSubChannel.postMessage(JSON.stringify({action: 'clear'}));
                }
              } catch(e) {}
            }
          }

          if (!window.__cueObserverAttached) {
            window.__cueObserverAttached = true;
            var cueContainer = document.querySelector('.jw-text-track-display, .vjs-text-track-display, .art-subtitles, div[class*="subtitle"]');
            if (cueContainer) {
              var observer = new MutationObserver(function() {
                scanCues();
              });
              observer.observe(cueContainer, { childList: true, subtree: true });
            }
          }

          // 6. Inject "Indonesian" into player CC popup menu (lightweight & targeted)
          function injectIndonesianOptionIntoPlayerCC() {
            try {
              var existing = document.getElementById('sub-id-option');
              if (existing) {
                if (window.__subIndoEnabled) {
                  existing.style.color = '#FA5A32';
                  existing.style.fontWeight = 'bold';
                } else {
                  existing.style.color = '';
                  existing.style.fontWeight = 'normal';
                }
                return;
              }

              // Targeted menu item query to prevent layout thrashing
              var menuItems = document.querySelectorAll(
                '.jw-settings-content li, .mg3-menu-item, [role="menuitem"], [role="option"], ul.jw-reset > li, .jw-reset li, div[class*="menu"] li'
              );
              var sampleItem = null;

              for (var i = 0; i < menuItems.length; i++) {
                var el = menuItems[i];
                var t = (el.innerText || el.textContent || '').trim();
                if (t === 'German' || t === 'Italian' || t === 'English' || t === 'Russian' || t === 'Spanish' || t === 'Off') {
                  if (el.children.length <= 2) {
                    sampleItem = el;
                    break;
                  }
                }
              }

              if (!sampleItem || !sampleItem.parentElement) return;
              var container = sampleItem.parentElement;

              var indoOption = sampleItem.cloneNode(true);
              indoOption.classList.add('sub-id-custom-cc');
              indoOption.id = 'sub-id-option';

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
                window.__subIndoEnabled = true;
                try {
                  if (window.FlutterSubChannel) {
                    window.FlutterSubChannel.postMessage(JSON.stringify({action: 'enable'}));
                  }
                } catch(e) {}

                activateCaptions();

                indoOption.style.color = '#FA5A32';
                indoOption.style.fontWeight = 'bold';
                if (hideStyle) {
                  hideStyle.innerHTML = 'video::cue { opacity: 0 !important; visibility: hidden !important; font-size: 0 !important; line-height: 0 !important; height: 0 !important; } .jw-text-track-cue { opacity: 0 !important; visibility: hidden !important; font-size: 0 !important; line-height: 0 !important; height: 0 !important; } .jw-captions-text { opacity: 0 !important; visibility: hidden !important; font-size: 0 !important; } div[class*="text-track-cue"] { opacity: 0 !important; visibility: hidden !important; } .jw-text-track-display { pointer-events: none !important; }';
                }
              };

              var siblings = container.children;
              for (var k = 0; k < siblings.length; k++) {
                (function(sib) {
                  if (!sib.__hookedClick) {
                    sib.__hookedClick = true;
                    sib.addEventListener('click', function() {
                      if (sib === indoOption) return;
                      window.__subIndoEnabled = false;
                      if (overlay) overlay.style.display = 'none';
                      if (hideStyle) hideStyle.innerHTML = '';
                      indoOption.style.color = '';
                      indoOption.style.fontWeight = 'normal';
                      try {
                        if (window.FlutterSubChannel) {
                          window.FlutterSubChannel.postMessage(JSON.stringify({action: 'disable'}));
                        }
                      } catch(e) {}
                    });
                  }
                })(siblings[k]);
              }

              container.insertBefore(indoOption, container.firstChild);
            } catch(e) {}
          }

          // Initial runs
          activateCaptions();
          tryLoadVttDirectly();
          scanCues();
          injectIndonesianOptionIntoPlayerCC();

          // Hook into user clicks on player controls to inject instantly
          if (!window.__playerClickHooked) {
            window.__playerClickHooked = true;
            document.addEventListener('click', function() {
              setTimeout(function() {
                if (!document.getElementById('sub-id-option')) {
                  injectIndonesianOptionIntoPlayerCC();
                }
              }, 120);
            }, true);
          }

          // Gentle fallback polling loop (1500ms)
          if (window.__subPoller) clearInterval(window.__subPoller);
          window.__subPoller = setInterval(function() {
            if (window.__subIndoEnabled) {
              if (!window.__vttLoaded) tryLoadVttDirectly();
              if (!document.getElementById('sub-id-option')) injectIndonesianOptionIntoPlayerCC();
            }
          }, 1500);
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
      ..addJavaScriptChannel(
        'FlutterSubChannel',
        onMessageReceived: (JavaScriptMessage msg) {
          _handleSubChannelMessage(msg.message);
        },
      )
      ..addJavaScriptChannel(
        'FlutterPlayerChannel',
        onMessageReceived: (JavaScriptMessage msg) {
          _handlePlayerChannelMessage(msg.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final targetUrl = request.url.trim().toLowerCase();
            // Block mobile app intents, market, apk downloads
            if (targetUrl.startsWith('intent:') ||
                targetUrl.startsWith('market:') ||
                targetUrl.startsWith('tel:') ||
                targetUrl.startsWith('sms:') ||
                targetUrl.startsWith('whatsapp:') ||
                targetUrl.endsWith('.apk') ||
                targetUrl.contains('/download/')) {
              return NavigationDecision.prevent;
            }
            // Block ad networks, redirects, search engines, gambling/slot domains
            const adKeywords = [
              'google.com/search',
              'google.com/url',
              'bing.com',
              'yahoo.com',
              'slot',
              'judi',
              'gacor',
              'poker',
              'casino',
              'bet88',
              'togel',
              'adsterra',
              'popcash',
              'exoclick',
              'propeller',
              'clickadu',
              'syndication',
              'histats',
              'adkeeper',
              'popunder',
              'traffic',
              'banner',
              'track',
              'zeus',
              'olympus',
              'pragmatic'
            ];
            for (final kw in adKeywords) {
              if (targetUrl.contains(kw)) {
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('WebView Resource Error: ${error.errorCode} - ${error.description}');
          },
          onPageFinished: (finishedUrl) {
            _webViewController?.runJavaScript('''
              try {
                window.open = function() { return null; };
                window.openPopup = function() { return null; };
                // MegaCloud / Vidstream player sizing
                var el = document.getElementById('megaplay-player');
                if (el) {
                  el.style.width = '100vw';
                  el.style.height = '100vh';
                  el.style.position = 'fixed';
                  el.style.top = '0';
                  el.style.left = '0';
                  el.style.zIndex = '999999';
                }
                // ZokoAnime / generic players sizing
                var wrap = document.getElementById('wrap');
                if (wrap) {
                  wrap.style.width = '100vw';
                  wrap.style.height = '100vh';
                  wrap.style.position = 'fixed';
                  wrap.style.top = '0';
                  wrap.style.left = '0';
                }
                var stage = document.getElementById('stage');
                if (stage) {
                  stage.style.width = '100vw';
                  stage.style.height = '100vh';
                }
                var pEl = document.getElementById('player');
                if (pEl) {
                  pEl.style.width = '100vw';
                  pEl.style.height = '100vh';
                }
                var adbar = document.getElementById('adbar');
                if (adbar) {
                  adbar.style.display = 'none';
                }
                var ov = document.getElementById('ov');
                if (ov && !ov.querySelector('.err')) {
                  ov.style.display = 'none';
                }
                // Immediate hiding of web player display controls and title bars
                var hideCss = '.jw-controls, .jw-controls-backdrop, .jw-controlbar, .jw-display, .jw-display-controls, .jw-display-icon-container, .jw-display-icon-display, .jw-display-icon-rewind, .jw-display-icon-next, .jw-dock, .jw-dock-btn, .jw-title, .jw-title-primary, .jw-title-secondary, .jw-top, .jw-overlays, .jw-preview, .jwplayer .jw-controls, .jwplayer .jw-display, .jwplayer .jw-display-controls, .jwplayer .jw-display-icon-container, .jwplayer .jw-display-icon-display, .jwplayer .jw-display-icon-rewind, .jwplayer .osp-display-forward, .jwplayer[class*="centre-controls"] .jw-display, .jwplayer[class*="centre-controls"] .jw-display-icon-rewind, .jwplayer[class*="centre-controls"] .osp-display-forward, .jwplayer.osp-centre-controls .jw-display, .jwplayer.osp-centre-controls .jw-display-icon-rewind, .jwplayer.osp-centre-controls .osp-display-forward, .osp-centre-controls, .osp-display-forward, .osp-brand, .osp-skip, .osp-unmute, .osp-dl, .osp-qmenu, .float-pill, .card-top, .vjs-control-bar, .vjs-big-play-button, .vjs-modal-dialog, .vjs-dock-text, .vjs-dock-title, .art-controls, .art-bottom, .art-top, .art-state, .art-mask, .art-video-player .art-state, .art-video-player .art-controls, .art-video-player .art-top, .art-video-player .art-bottom, .plyr__controls, .plyr__control--overlaid, media-controls, media-video-layout, #overlay-control-handle, #skip-intro-handle, #skip-outro-handle, .skip-intro, .skip-op, .botright { display: none !important; opacity: 0 !important; visibility: hidden !important; pointer-events: none !important; width: 0 !important; height: 0 !important; max-width: 0 !important; max-height: 0 !important; line-height: 0 !important; font-size: 0 !important; overflow: hidden !important; } video::-webkit-media-controls, video::-webkit-media-controls-enclosure, video::-webkit-media-controls-panel, video::-webkit-media-controls-play-button, video::-webkit-media-controls-timeline { display: none !important; }';
                var hs = document.getElementById('web-player-hide-controls-style');
                if (!hs) {
                  hs = document.createElement('style');
                  hs.id = 'web-player-hide-controls-style';
                  document.head.appendChild(hs);
                }
                hs.innerHTML = hideCss;
                // Initial autoplay trigger if player is ready
                if (typeof window.jwplayer === 'function') {
                  try {
                    var jw = window.jwplayer();
                    if (jw && typeof jw.play === 'function') {
                      jw.play(true);
                    }
                  } catch(e) {}
                }
              } catch(e) {}
            ''');
            _injectSubtitleTranslationScript();
            _injectPlayerControlScript();
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                _injectSubtitleTranslationScript();
                _injectPlayerControlScript();
              }
            });
            Future.delayed(const Duration(milliseconds: 3000), () {
              if (mounted) {
                _injectSubtitleTranslationScript();
                _injectPlayerControlScript();
              }
            });
          },
        ),
      );

    final platform = _webViewController!.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
      platform.setOverScrollMode(WebViewOverScrollMode.never);
    }

    _webViewController!.loadRequest(
      Uri.parse(url),
      headers: {
        'Referer': 'https://hianime.at/',
      },
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    _webViewController?.runJavaScript(
      'window.__togglePlay && window.__togglePlay();',
    );
  }

  String _formatDuration(Duration d) {
    if (d < Duration.zero) d = Duration.zero;
    final totalSeconds = d.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _seekTo(Duration position) {
    setState(() {
      _currentPosition = position;
    });
    _webViewController?.runJavaScript(
      'window.__seekVideo && window.__seekVideo(${position.inSeconds});',
    );
  }

  void _seekRelative(int seconds) {
    final newSeconds = (_currentPosition.inSeconds + seconds)
        .clamp(0, _totalDuration.inSeconds);
    setState(() {
      _currentPosition = Duration(seconds: newSeconds);
    });
    _webViewController?.runJavaScript(
      'window.__seekRelative && window.__seekRelative($seconds);',
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _webViewController?.runJavaScript(
      'window.__toggleMute && window.__toggleMute();',
    );
  }

  void _toggleSubDub() {
    setState(() {
      _isDub = !_isDub;
    });
    StorageService.setDub(_isDub);
    _loadStreamForEpisode(_currentEpisode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Beralih ke audio ${_isDub ? "DUB" : "SUB"}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSpeedPicker() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Text(
                    'Kecepatan Putar',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            ...speeds.map(
              (s) => ListTile(
                title: Text(
                  s == 1.0 ? '1.0x (Normal)' : '${s}x',
                  style: TextStyle(
                    color: _playbackSpeed == s
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    fontWeight: _playbackSpeed == s
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                trailing: _playbackSpeed == s
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _playbackSpeed = s);
                  _webViewController?.runJavaScript(
                    'window.__setSpeed && window.__setSpeed($s);',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerPicker() {
    final options = [
      {'label': 'Mati (Off)', 'duration': null},
      {'label': '15 Menit', 'duration': const Duration(minutes: 15)},
      {'label': '30 Menit', 'duration': const Duration(minutes: 30)},
      {'label': '45 Menit', 'duration': const Duration(minutes: 45)},
      {'label': '60 Menit', 'duration': const Duration(minutes: 60)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Text(
                    'Timer Tidur',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            ...options.map((opt) {
              final dur = opt['duration'] as Duration?;
              return ListTile(
                title: Text(
                  opt['label'] as String,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _setSleepTimer(dur);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timer tidur dimatikan'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _sleepTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _webViewController?.runJavaScript(
          'window.__togglePlay && window.__togglePlay();',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timer tidur: Pemutaran dihentikan'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timer tidur disetel untuk ${duration.inMinutes} menit'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCastDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cast_rounded,
                  size: 36,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pemeran Layar (Cast to TV)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hubungkan ponsel dan Smart TV atau Chromecast Anda ke jaringan Wi-Fi yang sama untuk transmisi video.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerPip() {
    _webViewController?.runJavaScript('''
      try {
        var v = document.querySelector('video');
        if (v && document.pictureInPictureEnabled) {
          if (document.pictureInPictureElement) {
            document.exitPictureInPicture();
          } else {
            v.requestPictureInPicture();
          }
        }
      } catch(e) {}
    ''');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengaktifkan Picture-in-Picture...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadCurrentEpisode() {
    DownloadProgressDialog.show(
      context,
      episodeNumber: _currentEpisode.number,
      totalEpisodes: _allEpisodes.isNotEmpty ? _allEpisodes.length : 1,
      resolution: '720p',
      totalMb: 246.5,
      onHide: () async {
        await StorageService.saveDownload(
          DownloadItem(
            animeId: widget.anime.id,
            animeSlug: widget.anime.slug,
            animeTitle: widget.anime.title,
            animePoster: widget.anime.posterUrl,
            episodeNumber: _currentEpisode.number,
            episodeTitle: _currentEpisode.title,
            resolution: '720p',
            sizeMb: 246.5,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unduhan tersimpan di daftar Download'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Text(
                      'Opsi Video',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.border, height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.speed_rounded,
                          color: AppColors.accent),
                      title: const Text('Kecepatan Putar'),
                      subtitle: Text('${_playbackSpeed}x'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showSpeedPicker();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.timer_outlined,
                          color: AppColors.accent),
                      title: const Text('Timer Tidur'),
                      subtitle: Text(_sleepTimer != null
                          ? 'Aktif'
                          : 'Nonaktif'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showSleepTimerPicker();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.fast_forward_rounded,
                          color: AppColors.accent),
                      title: const Text('Lewati Intro Sekarang (+85d)'),
                      subtitle:
                          const Text('Langsung lompat melewati intro video'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _skipIntro();
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.skip_next_rounded,
                          color: AppColors.accent),
                      title: const Text('Lewati Intro Otomatis'),
                      subtitle: Text(_autoSkipIntro
                          ? 'Aktif (Intro langsung dilewati saat diputar)'
                          : 'Nonaktif (Tombol muncul saat intro berlangsung)'),
                      value: _autoSkipIntro,
                      onChanged: (val) async {
                        setState(() => _autoSkipIntro = val);
                        await StorageService.setAutoSkipIntro(val);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.mic_none_rounded,
                          color: AppColors.accent),
                      title: const Text('Pilihan Audio (SUB / DUB)'),
                      subtitle: Text(_isDub ? 'DUB (Inggris)' : 'SUB (Jepang)'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _toggleSubDub();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.subtitles_rounded,
                          color: AppColors.accent),
                      title: Text(_subIndoEnabled
                          ? 'Nonaktifkan Subtitle Indo'
                          : 'Aktifkan Subtitle Indo'),
                      subtitle: Text(_subIndoEnabled
                          ? 'Teks diterjemahkan otomatis ke Bahasa Indonesia'
                          : 'Menggunakan teks bawaan server (English CC)'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _toggleSubtitleIndonesia();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.cast_rounded,
                          color: AppColors.accent),
                      title: const Text('Cast ke Smart TV / Layar Nirkabel'),
                      subtitle:
                          const Text('Koneksikan ke Google Cast atau TV'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCastDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                          Icons.picture_in_picture_alt_rounded,
                          color: AppColors.accent),
                      title: const Text('Picture in Picture (PiP)'),
                      subtitle:
                          const Text('Tonton sambil membuka aplikasi lain'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _triggerPip();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.file_download_outlined,
                          color: AppColors.accent),
                      title: const Text('Unduh Episode Ini'),
                      subtitle: const Text('Simpan untuk ditonton luring'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _downloadCurrentEpisode();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.video_library_outlined,
                          color: AppColors.accent),
                      title: const Text('Daftar Episode'),
                      subtitle:
                          Text('${_allEpisodes.length} episode tersedia'),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _isEpisodeDrawerOpen = true);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.open_in_new,
                          color: AppColors.accent),
                      title:
                          const Text('Buka di Pemutar Eksternal (MPV / VLC)'),
                      subtitle: const Text(
                          'Putar langsung dengan pemutar video pihak ketiga'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openInExternalPlayer();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline,
                          color: AppColors.accent),
                      title: const Text('Panduan Sub Indo di MPV'),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showMpvGuideDialog();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSubtitleIndonesia() {
    setState(() {
      _subIndoEnabled = !_subIndoEnabled;
      if (!_subIndoEnabled) {
        _currentSubtitleText = '';
      }
    });
    StorageService.setSubLanguage(_subIndoEnabled ? 'id' : 'en');
    _injectSubtitleTranslationScript();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _subIndoEnabled
              ? 'Subtitle Indonesia diaktifkan (Latar belakang transparan)'
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
        content: Column(
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
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Episode (${_allEpisodes.length})',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
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
        body: _buildPlayerView(),
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
              style: TextStyle(
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
                    style: TextStyle(
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
                        Row(
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
                            Row(
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
                          style: TextStyle(
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
                      Flexible(
                        child: Text(
                          'Pilihan Audio Suara:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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
                    onPressed: _allEpisodes.isEmpty
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Anime ini belum resmi rilis di server streaming.',
                                ),
                                backgroundColor: AppColors.surface,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : _showEpisodePickerSheet,
                    icon: Icon(Icons.list_rounded,
                        color: AppColors.textPrimary),
                    label: Text(
                      _isLoadingEpisodes
                          ? 'Memuat Daftar Episode...'
                          : (_allEpisodes.isEmpty
                              ? 'Daftar Episode (Akan Datang)'
                              : 'Daftar Episode (${_allEpisodes.length})'),
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
                          icon: Icon(Icons.open_in_new,
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
                        icon: Icon(Icons.help_outline,
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
                          Text(
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
                            style: TextStyle(
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
      final isUpcoming = widget.anime.isUpcoming ||
          _allEpisodes.isEmpty ||
          (widget.anime.status?.toLowerCase().contains('not yet') == true);

      if (isUpcoming) {
        return Container(
          color: const Color(0xFF1E293B),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Anime Belum Rilis (Akan Datang)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Kembali ke Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(140, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

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
      final currentIndex =
          _allEpisodes.indexWhere((e) => e.number == _currentEpisode.number);
      final hasPrev = currentIndex > 0;
      final hasNext =
          currentIndex >= 0 && currentIndex < _allEpisodes.length - 1;

      final Widget webView;
      final platform = _webViewController!.platform;
      if (platform is AndroidWebViewController) {
        webView = WebViewWidget.fromPlatformCreationParams(
          params: AndroidWebViewWidgetCreationParams(
            controller: platform,
            displayWithHybridComposition: true,
          ),
        );
      } else {
        webView = WebViewWidget(controller: _webViewController!);
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          webView,
          if (_subIndoEnabled && _currentSubtitleText.isNotEmpty)
            Positioned(
              bottom: _isFullscreen
                  ? (_isControlsVisible ? 76.0 : 24.0)
                  : (_isControlsVisible ? 48.0 : 10.0),
              left: 12,
              right: 12,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isFullscreen ? 14 : 10,
                      vertical: _isFullscreen ? 5 : 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _currentSubtitleText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isFullscreen ? 17.0 : 13.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        height: 1.25,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            color: Colors.black87,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          VideoPlayerOverlay(
            title: '${widget.anime.title} - Episode ${_currentEpisode.number}',
            currentPosition: _currentPosition,
            totalDuration: _totalDuration,
            isPlaying: _isPlaying,
            isMuted: _isMuted,
            isLocked: _isLocked,
            isFullscreen: _isFullscreen,
            isSubIndoActive: _subIndoEnabled,
            playbackSpeed: _playbackSpeed,
            onControlsVisibilityChanged: (visible) {
              if (mounted && _isControlsVisible != visible) {
                setState(() => _isControlsVisible = visible);
              }
            },
            onBackPressed: () {
              if (_isFullscreen) {
                _toggleFullscreen();
              } else {
                Navigator.pop(context);
              }
            },
            onPlayPausePressed: _togglePlayPause,
            onSeek: _seekTo,
            onRewind10: () => _seekRelative(-10),
            onForward10: () => _seekRelative(10),
            onPreviousEpisode: hasPrev ? _goToPreviousEpisode : null,
            onNextEpisode: hasNext ? _goToNextEpisode : null,
            onToggleMute: _toggleMute,
            onToggleLock: () => setState(() => _isLocked = !_isLocked),
            onToggleFullscreen: _toggleFullscreen,
            onSpeedPressed: _showSpeedPicker,
            onTimerPressed: _showSleepTimerPicker,
            onSubtitlesPressed: _toggleSubtitleIndonesia,
            onAudioTrackPressed: _toggleSubDub,
            onCastPressed: _showCastDialog,
            onPipPressed: _triggerPip,
            onMorePressed: _showMoreOptions,
            onDownloadPressed: _downloadCurrentEpisode,
            onEpisodeListPressed: () {
              setState(() {
                _isEpisodeDrawerOpen = !_isEpisodeDrawerOpen;
              });
            },
            showSkipIntro: _showSkipIntroButton,
            onSkipIntro: _skipIntro,
            showSkipOutro: _showSkipOutroButton,
            onSkipOutro: _skipOutro,
            isBuffering: _isBuffering,
            isNetworkStalled: _isNetworkStalled,
            stallSeconds: _stallSeconds,
            onRetryPlayback: _retryPlayback,
            onSwitchServer: _switchServerQuickly,
          ),
          if (_isEpisodeDrawerOpen) ...[
            // Dimmed dismiss barrier over left side
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isEpisodeDrawerOpen = false),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
            // Right-side episode drawer matching Figma reference
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: PlayerEpisodeDrawer(
                episodes: _allEpisodes,
                currentEpisodeNumber: _currentEpisode.number,
                currentProgress: _totalDuration.inSeconds > 0
                    ? (_currentPosition.inSeconds / _totalDuration.inSeconds)
                    : 0.85,
                totalDurationText: _formatDuration(_totalDuration),
                onEpisodeSelected: (ep) {
                  setState(() {
                    _currentEpisode = ep;
                    _isEpisodeDrawerOpen = false;
                  });
                  _loadStreamForEpisode(ep);
                },
                onClose: () {
                  setState(() => _isEpisodeDrawerOpen = false);
                },
              ),
            ),
          ],
        ],
      );
    }

    final isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows);
    if (isDesktop) {
      return _buildDesktopPlayerView();
    }

    return Container(color: Colors.black);
  }

  Future<void> _launchMpvPlayer([String? customUrl]) async {
    final targetUrl = customUrl ?? _directM3u8Url ?? _streamUrl;
    if (targetUrl == null || targetUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan video belum siap')),
        );
      }
      return;
    }

    try {
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        final List<String> args = [
          targetUrl,
          '--title=${widget.anime.title} - Episode ${_currentEpisode.number}',
          '--force-window=immediate',
        ];
        await Process.start('mpv', args, mode: ProcessStartMode.detached);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membuka MPV Player di jendela desktop...'),
              backgroundColor: AppColors.accent,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('Error starting mpv directly: $e');
    }

    await _openInExternalPlayer();
  }

  Widget _buildDesktopPlayerView() {
    final currentIndex =
        _allEpisodes.indexWhere((e) => e.number == _currentEpisode.number);
    final hasPrev = currentIndex > 0;
    final hasNext =
        currentIndex >= 0 && currentIndex < _allEpisodes.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.anime.title} - Episode ${_currentEpisode.number}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Server: ${_selectedServer?.name ?? "HD-1 CDN"} • ${_isDub ? "Audio DUB" : "Audio Asli SUB"}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _toggleSubDub,
            icon: const Icon(Icons.translate_rounded, color: AppColors.accent, size: 18),
            label: Text(
              _isDub ? 'DUB (Inggris)' : 'SUB (Asli)',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (_availableServers.isNotEmpty)
            PopupMenuButton<StreamServerItem>(
              icon: const Icon(Icons.dns_rounded, color: Colors.white),
              tooltip: 'Ganti Server Video',
              onSelected: _switchServer,
              itemBuilder: (ctx) => _availableServers.map((s) {
                final isCur = _selectedServer?.name == s.name;
                return PopupMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Icon(
                        isCur ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isCur ? AppColors.accent : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(s.name, style: TextStyle(fontWeight: isCur ? FontWeight.w700 : FontWeight.w400)),
                    ],
                  ),
                );
              }).toList(),
            ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_rounded, color: Colors.white),
            tooltip: 'Daftar Episode',
            onPressed: () {
              setState(() => _isEpisodeDrawerOpen = !_isEpisodeDrawerOpen);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 36),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pemutar Desktop Anirama',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Episode ${_currentEpisode.number}: ${_currentEpisode.title.isEmpty ? widget.anime.title : _currentEpisode.title}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _launchMpvPlayer(),
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: const Text('Putar di MPV Player'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _openInExternalPlayer,
                          icon: const Icon(Icons.ondemand_video_rounded, size: 20),
                          label: const Text('Buka di VLC / Default'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF64748B)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final url = _streamUrl;
                            if (url != null && url.isNotEmpty) {
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                          icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                          label: const Text('Buka di Browser'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Color(0xFF475569)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            final targetUrl = _directM3u8Url ?? _streamUrl ?? '';
                            if (targetUrl.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: targetUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tautan stream berhasil disalin ke clipboard!'),
                                  backgroundColor: AppColors.accent,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Salin Link M3U8'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Color(0xFF475569)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFF334155), height: 1),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: hasPrev ? _goToPreviousEpisode : null,
                          icon: const Icon(Icons.skip_previous_rounded, size: 18),
                          label: const Text('Episode Sebelumnya'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF334155),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF1E293B),
                            disabledForegroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _isEpisodeDrawerOpen = true);
                          },
                          icon: const Icon(Icons.list_rounded, size: 18),
                          label: Text('Daftar Episode (${_allEpisodes.length})'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Color(0xFF475569)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: hasNext ? _goToNextEpisode : null,
                          icon: const Icon(Icons.skip_next_rounded, size: 18),
                          label: const Text('Episode Selanjutnya'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF1E293B),
                            disabledForegroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isEpisodeDrawerOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isEpisodeDrawerOpen = false),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: PlayerEpisodeDrawer(
                episodes: _allEpisodes,
                currentEpisodeNumber: _currentEpisode.number,
                currentProgress: 0.5,
                totalDurationText: '24:00',
                onEpisodeSelected: (ep) {
                  setState(() {
                    _currentEpisode = ep;
                    _isEpisodeDrawerOpen = false;
                  });
                  _loadStreamForEpisode(ep);
                },
                onClose: () {
                  setState(() => _isEpisodeDrawerOpen = false);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
