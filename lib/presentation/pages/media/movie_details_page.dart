import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:butterfly/constants/app_theme.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/models/media/media_item.dart';
import 'package:butterfly/network/api_paths.dart';
import 'package:butterfly/presentation/components/media/media_item.dart';
import 'package:butterfly/providers/content_provider.dart';
import 'package:butterfly/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:river_player/river_player.dart';

import '../../../providers/authentication_provider.dart';
import '../../../providers/my_list_provider.dart';
import '../../components/controls/download_button.dart';
import '../../components/ui/app_widgets.dart';
import '../../custom_controls/custom_controls_widget.dart';
import 'package:butterfly/video_js_bridge.dart';
import '../../../platform_utils.dart';
import '../authentication/login_screen.dart';
import '../payment/plans_list_page_mobile.dart';
import 'package:share_plus/share_plus.dart';

class MovieDetailsPage extends StatefulWidget {
  final BaseItem baseItem;

  const MovieDetailsPage(this.baseItem, {super.key});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  BetterPlayerController? _betterPlayerController;
  VideoJsController? _videoJsController;
  String _buttonText = "Watch Trailer";
  bool _playingMovie = true;
  Duration _lastReported = Duration.zero;
  Timer? _positionTimer;
  bool _hasSeeked = false;
  int _detailTab = 0;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    String videoUrl = widget.baseItem.videoUrl;
    if (videoUrl.isNotEmpty) {
      setState(() {
        PlatformUtils.isWeb ? _videoJsController = generateWebController(videoUrl) : _betterPlayerController = generateMobileController(videoUrl);
      });
      return;
    }

    Provider.of<ContentProvider>(context, listen: false).getVideoUrls(
      widget.baseItem.id,
      widget.baseItem.mediaType,
      parentId: "",
      () {
        videoUrl = widget.baseItem.videoUrl;
        setState(() {
          PlatformUtils.isWeb ? _videoJsController = generateWebController(videoUrl) : _betterPlayerController = generateMobileController(videoUrl);
        });
      },
    );
  }

  VideoJsController generateWebController(String videoUrl) {
    return VideoJsController(
      "video-$_playingMovie-${widget.baseItem.id}",
      videoJsOptions: VideoJsOptions(
        controls: true,
        loop: false,
        muted: false,
        poster: widget.baseItem.horizontalPosterUrl,
        aspectRatio: '16:9',
        fluid: true,
        language: 'en',
        liveui: false,
        notSupportedMessage: 'This video format is not supported',
        playbackRates: [1, 1.5, 2],
        responsive: true,
        sources: [
          Source(videoUrl, "application/x-mpegURL"),
        ],
        suppressNotSupportedError: false,
      ),
    );
  }

  BetterPlayerController generateMobileController(String url) {
    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: !widget.baseItem.getIsAdult(),
        showPlaceholderUntilPlay: true,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableFullscreen: true,
          backgroundColor: AppColors.colorBackground,
          controlBarColor: Colors.transparent,
          playerTheme: BetterPlayerTheme.custom,
          customControlsBuilder: (controller, onControlsVisibilityChanged) => CustomControlsWidget(
            onControlsVisibilityChanged: onControlsVisibilityChanged,
            controlsConfiguration: BetterPlayerControlsConfiguration(),
            data: {
              "title": widget.baseItem.title,
              "genres": widget.baseItem.getClassificationString(),
              "bottom_title": widget.baseItem.getTitleHeaderString(),
              "age_rating": widget.baseItem.ageRating,
              "age_limit": widget.baseItem.ageLimit,
              "title_start": widget.baseItem.titleStart,
              "title_end": widget.baseItem.titleEnd,
            },
          ),
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 5 * 1024 * 1024,
          maxCacheSize: 11 * 1024 * 1024,
          maxCacheFileSize: 11 * 1024 * 1024,
        ),
      ),
    );

    void startTracking() {
      _positionTimer?.cancel();
      _lastReported = Duration.zero;

      _positionTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        if (!mounted) return;

        final videoController = controller.videoPlayerController;
        if (videoController == null) return;
        if (!videoController.value.initialized) return;

        Duration? position;
        try {
          position = await videoController.position;
        } catch (e) {
          debugPrint("⚠️ Failed to get position: $e");
          return;
        }

        if (position == null) return;

        if (position - _lastReported >= const Duration(seconds: 30)) {
          _lastReported = position;
          sendCurrentTimestamp(_lastReported);
        }
      });
    }

    void stopTracking() {
      _positionTimer?.cancel();
    }

    controller.videoPlayerController?.addListener(() async {
      final videoController = controller.videoPlayerController;
      if (videoController == null || _hasSeeked) return;

      if (videoController.value.initialized) {
        final totalDuration = videoController.value.duration ?? Duration.zero;
        final lastSeconds = widget.baseItem.lastTimestamp ?? 0;

        if (lastSeconds > 0 && lastSeconds < totalDuration.inSeconds) {
          _hasSeeked = true;
          await videoController.seekTo(Duration(seconds: lastSeconds));
          print("⏩ Seeking to $lastSeconds seconds");
        }
      }
    });

    controller.addEventsListener((event) async {
      if (!_playingMovie) return;

      Future<Duration?> safePosition() async {
        final videoController = controller.videoPlayerController;
        if (videoController == null || !videoController.value.initialized) return null;
        try {
          return await videoController.position;
        } catch (e) {
          debugPrint("⚠️ Failed to get position in event listener: $e");
          return null;
        }
      }

      // Handle play or pause
      if (event.betterPlayerEventType == BetterPlayerEventType.play || event.betterPlayerEventType == BetterPlayerEventType.pause) {
        final duration = await safePosition();
        if (duration != null) {
          sendCurrentTimestamp(duration);
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.play) {
          startTracking();
        } else {
          stopTracking();
        }
      }

      // Handle finished
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        stopTracking();
        final duration = await safePosition();
        if (duration != null) {
          sendCurrentTimestamp(duration);
        }
      }

      // ✅ Handle seeking
      if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
        final duration = await safePosition();
        if (duration != null) {
          sendCurrentTimestamp(duration);
        }
      }
    });

    return controller;
  }

  void sendCurrentTimestamp(Duration? duration) {
    if (!_playingMovie) return;
    if (duration == null) return;
    final seconds = duration.inSeconds;

    NetworkService().post(
      APIPath.continueWatching,
      {
        "timestamp": seconds,
        "content_id": widget.baseItem.id,
      },
      (data) {
        if (!context.mounted) return;
        Provider.of<ContentProvider>(context, listen: false).updateWatchTimestamp(widget.baseItem.id, seconds);
      },
      (error) {},
      () {},
    );
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final movie = contentProvider.getMediaById(
      widget.baseItem.id,
      widget.baseItem.mediaType,
    );
    final movies = contentProvider.getSuggestionMovies(movie!.suggestions);

    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final myList = Provider.of<MyListProvider>(context);
    bool isSubscribed = true;
    final isLoggedIn = authenticationProvider.getUser() != null;
    if (isLoggedIn) {
      isSubscribed = authenticationProvider.getUser()!.userSubscription != null;
    }

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PlatformUtils.isWeb
                      ? _videoJsController != null
                          ? VideoJsWidget(
                              key: ValueKey(_videoJsController.hashCode),
                              videoJsController: _videoJsController!,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.baseItem.horizontalPosterUrl,
                              fit: BoxFit.cover,
                            )
                      : _betterPlayerController != null
                          ? BetterPlayer(
                              controller: _betterPlayerController!,
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.baseItem.horizontalPosterUrl,
                              fit: BoxFit.cover,
                            ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 8,
                  child: CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 40,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  right: 8,
                  child: CircleIconButton(
                    icon: myList.contains(movie.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 40,
                    iconColor: myList.contains(movie.id) ? AppColors.colorPrimary : Colors.white,
                    onPressed: () async {
                      final added = await myList.toggle(movie.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(added ? 'Added to My List' : 'Removed from My List')),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: AppTextStyles.displayTitle.copyWith(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(mediaMetaLine(movie), style: AppTextStyles.meta),
                  const SizedBox(height: 16),
                  if (!isSubscribed)
                    GradientButton(
                      label: 'Subscribe',
                      icon: Icons.workspace_premium_rounded,
                      onPressed: () {
                        if (isLoggedIn) {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => PlansListPage(),
                          ));
                        } else {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginPage(next: PlansListPage()),
                          ));
                        }
                      },
                    )
                  else
                    GradientButton(
                      label: 'Play',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        _betterPlayerController?.play();
                      },
                    ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DetailAction(
                        icon: myList.contains(movie.id) ? Icons.add_circle : Icons.add_circle_outline,
                        label: 'My List',
                        active: myList.contains(movie.id),
                        onPressed: () => myList.toggle(movie.id),
                      ),
                      DetailAction(
                        icon: _liked ? Icons.favorite : Icons.favorite_border,
                        label: 'Like',
                        active: _liked,
                        onPressed: () => setState(() => _liked = !_liked),
                      ),
                      DetailAction(
                        icon: Icons.ios_share_rounded,
                        label: 'Share',
                        onPressed: () {
                          Share.share(movie.title);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    movie.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.colorTextSecondary, height: 1.45, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _tabLabel('About', 0),
                      const SizedBox(width: 22),
                      _tabLabel('More Like This', 1),
                      const SizedBox(width: 22),
                      _tabLabel('Trailers', 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_detailTab == 0) _aboutBlock(movie),
                  if (_detailTab == 1)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double maxItemWidth = constraints.maxWidth > 600 ? 250 : 200;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            maxCrossAxisExtent: maxItemWidth,
                            childAspectRatio: 2 / 3,
                          ),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            return MediaItem(baseItem: movies[index], replacement: true);
                          },
                        );
                      },
                    ),
                  if (_detailTab == 2) ...[
                    if (movie.trailerUrl.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_betterPlayerController != null) {
                              _betterPlayerController!.dispose();
                            }
                            if (_playingMovie) {
                              PlatformUtils.isWeb
                                  ? _videoJsController = generateWebController(movie.trailerUrl)
                                  : _betterPlayerController = generateMobileController(movie.trailerUrl);
                              _buttonText = "Watch Movie";
                              _playingMovie = false;
                            } else {
                              PlatformUtils.isWeb
                                  ? _videoJsController = generateWebController(movie.videoUrl)
                                  : _betterPlayerController = generateMobileController(movie.videoUrl);
                              _buttonText = "Watch Trailer";
                              _playingMovie = true;
                            }
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.movie, color: Colors.black),
                              const SizedBox(width: 10),
                              Text(_buttonText, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text('No trailers available', style: AppTextStyles.meta),
                  ],
                  if (!PlatformUtils.isWeb) DownloadButton(baseItem: movie),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabLabel(String label, int index) {
    final selected = _detailTab == index;
    return GestureDetector(
      onTap: () => setState(() => _detailTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.colorTextMuted,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: selected ? 28 : 0,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutBlock(BaseItem movie) {
    String crew(String role) {
      final group = movie.castAndCrew?.firstWhere(
        (item) => item.role.toLowerCase() == role,
        orElse: () => CastAndCrew(role: '', members: []),
      );
      if (group == null || group.members.isEmpty) return 'N/A';
      return group.members.map((m) => m.name).join(', ');
    }

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Text(label, style: const TextStyle(color: AppColors.colorTextMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row('Director', crew('director')),
        row('Cast', crew('cast')),
        row('Language', 'Hindi'),
        row('Genre', movie.getClassificationString().isEmpty ? 'N/A' : movie.getClassificationString()),
      ],
    );
  }
}
