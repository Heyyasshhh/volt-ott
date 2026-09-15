import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/models/media/media_item.dart';
import 'package:butterfly/network/api_paths.dart';
import 'package:butterfly/presentation/components/controls/expandable_text.dart';
import 'package:butterfly/presentation/components/media/media_item.dart';
import 'package:butterfly/providers/content_provider.dart';
import 'package:butterfly/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:river_player/river_player.dart';

import '../../../providers/authentication_provider.dart';
import '../../components/controls/download_button.dart';
import '../../custom_controls/custom_controls_widget.dart';
import 'package:butterfly/video_js_bridge.dart';
import '../../../platform_utils.dart';
import '../authentication/login_screen.dart';
import '../payment/plans_list_page_mobile.dart';

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
    bool isSubscribed = true;
    final isLoggedIn = authenticationProvider.getUser() != null;
    if (isLoggedIn) {
      isSubscribed = authenticationProvider.getUser()!.userSubscription != null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Watch Movie", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.colorBackground,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.colorBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          )
                    : _betterPlayerController != null
                        ? BetterPlayer(
                            controller: _betterPlayerController!,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.baseItem.horizontalPosterUrl,
                          ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 15),
                child: Text(
                  movie.title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              Visibility(
                visible: !isSubscribed,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (isLoggedIn) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => PlansListPage(),
                        ));
                      } else {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginPage(
                            next: PlansListPage(),
                          ),
                        ));
                      }
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.colorPrimary,
                        ),
                        color: AppColors.colorPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.crown,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Subscribe",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 8, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpandableTextWidget(
                      text: movie.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              if (movie.trailerUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_betterPlayerController != null) {
                          _betterPlayerController!.dispose();
                        }
                        if (_playingMovie) {
                          PlatformUtils.isWeb ? _videoJsController = generateWebController(movie.trailerUrl) : _betterPlayerController = generateMobileController(movie.trailerUrl);
                          _buttonText = "Watch Movie";
                          _playingMovie = false;
                        } else {
                          PlatformUtils.isWeb ? _videoJsController = generateWebController(movie.videoUrl) : _betterPlayerController = generateMobileController(movie.videoUrl);
                          _buttonText = "Watch Trailer";
                          _playingMovie = true;
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.movie),
                          const SizedBox(width: 10),
                          Text(
                            _buttonText,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              if (!PlatformUtils.isWeb) DownloadButton(baseItem: movie),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                child: LayoutBuilder(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
