import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/network/api_paths.dart';
import 'package:volt/presentation/components/ui/content_cards.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:volt/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:river_player/river_player.dart';

import '../../../providers/authentication_provider.dart';
import '../../../providers/my_list_provider.dart';
import '../../components/controls/download_button.dart';
import '../../components/ui/app_widgets.dart';
import '../../custom_controls/custom_controls_widget.dart';
import 'package:volt/video_js_bridge.dart';
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

    final gutter = AppLayout.gutter(context);
    final artUrl = movie.featuredPosterUrl.isNotEmpty ? movie.featuredPosterUrl : bestPortrait(movie);

    void playWatch() {
      if (!isSubscribed) {
        if (isLoggedIn) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => PlansListPage(),
          ));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => LoginPage(next: PlansListPage()),
          ));
        }
        return;
      }
      _betterPlayerController?.play();
    }

    void toggleTrailer() {
      if (movie.trailerUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No trailers available')),
        );
        return;
      }
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
    }

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Row(
                      children: [
                        CircleIconButton(
                          icon: _liked ? Icons.favorite : Icons.favorite_border,
                          size: 40,
                          iconColor: _liked ? AppColors.colorOrange : Colors.white,
                          onPressed: () => setState(() => _liked = !_liked),
                        ),
                        const SizedBox(width: 8),
                        CircleIconButton(
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
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.86,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkPoster(url: artUrl),
                    const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
                    Positioned(
                      left: gutter,
                      right: gutter * 0.3,
                      top: 36,
                      child: Text(
                        movie.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.displayTitle.copyWith(
                          fontSize: 40,
                          height: 1.05,
                        ),
                      ),
                    ),
                    Positioned(
                      left: gutter,
                      right: gutter,
                      top: 188,
                      child: Text(
                        _floatingMeta(movie),
                        style: AppTextStyles.eyebrow.copyWith(
                          color: AppColors.colorSilver,
                          letterSpacing: 2.4,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.28),
                      child: _actionCore(
                        movie: movie,
                        myList: myList,
                        isSubscribed: isSubscribed,
                        onWatch: playWatch,
                        onTrailer: toggleTrailer,
                      ),
                    ),
                    if (!isSubscribed)
                      Positioned(
                        left: gutter,
                        right: gutter,
                        bottom: 28,
                        child: GradientButton(
                          label: 'Subscribe',
                          icon: Icons.workspace_premium_rounded,
                          onPressed: playWatch,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 10),
                    Text(
                      movie.description,
                      style: AppTextStyles.editorial.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: AppColors.colorTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: AppColors.colorHairline, height: 1),
                    const SizedBox(height: 22),
                    _castStrip(movie),
                    const SizedBox(height: 28),
                    Text('More Like This', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 8),
                    Text('Related', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 16),
                    _relatedMix(movies),
                    if (!PlatformUtils.isWeb) DownloadButton(baseItem: movie),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _floatingMeta(BaseItem item) {
    final parts = <String>[];
    if (item.showReleaseTime) {
      parts.add('${item.releaseTime.year}');
    }
    if (item.categories.isNotEmpty) {
      parts.add(item.categories.first.toUpperCase());
    }
    parts.add('HINDI');
    if (item.length.isNotEmpty) {
      parts.add(item.length.toUpperCase());
    } else if (item.lengthSeconds > 0) {
      final hours = item.lengthSeconds ~/ 3600;
      final minutes = (item.lengthSeconds % 3600) ~/ 60;
      parts.add(hours > 0 ? '${hours}H ${minutes}M' : '${minutes}M');
    }
    return parts.join('  /  ');
  }

  Widget _actionCore({
    required BaseItem movie,
    required MyListProvider myList,
    required bool isSubscribed,
    required VoidCallback onWatch,
    required VoidCallback onTrailer,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DetailAction(
              icon: Icons.play_circle_outline,
              label: 'Watch',
              active: _playingMovie,
              onPressed: onWatch,
            ),
            DetailAction(
              icon: Icons.movie_filter_outlined,
              label: 'Trailer',
              active: !_playingMovie,
              onPressed: onTrailer,
            ),
            DetailAction(
              icon: myList.contains(movie.id) ? Icons.add_circle : Icons.add_circle_outline,
              label: 'My List',
              active: myList.contains(movie.id),
              onPressed: () => myList.toggle(movie.id),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PlayCoreButton(
          onPressed: onWatch,
          size: 92,
          label: isSubscribed ? (_playingMovie ? 'Watch Now' : _buttonText) : 'Subscribe',
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _downloadOrbit(movie),
            DetailAction(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              onPressed: () {
                Share.share(movie.title);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _downloadOrbit(BaseItem movie) {
    if (PlatformUtils.isWeb) {
      return DetailAction(
        icon: Icons.download_outlined,
        label: 'Download',
        onPressed: () {},
      );
    }
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.colorHairline),
            ),
            child: ClipOval(
              child: OverflowBox(
                maxWidth: 220,
                maxHeight: 54,
                child: DownloadButton(baseItem: movie),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Download',
            style: TextStyle(
              color: AppColors.colorTextSecondary,
              fontSize: 9,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _castStrip(BaseItem movie) {
    final members = <CastMember>[];
    final group = movie.castAndCrew?.firstWhere(
      (item) => item.role.toLowerCase() == 'cast',
      orElse: () => CastAndCrew(role: '', members: []),
    );
    if (group != null) {
      members.addAll(group.members);
    }

    if (members.isEmpty) {
      return _aboutBlock(movie);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cast & Crew', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final member = members[index];
              final photo = member.profilePictureUrl ?? '';
              return SizedBox(
                width: 104,
                child: Column(
                  children: [
                    SizedBox(
                      height: 148,
                      width: 104,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: photo.isEmpty
                            ? Container(
                                color: AppColors.colorSurface,
                                child: const Icon(Icons.person_outline, color: AppColors.colorSilver),
                              )
                            : NetworkPoster(url: photo),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.eyebrow.copyWith(fontSize: 9, color: AppColors.colorSilver, letterSpacing: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _relatedMix(List<BaseItem> movies) {
    if (movies.isEmpty) {
      return Text('No related titles', style: AppTextStyles.meta);
    }
    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = movies[index];
          return ChargePoster(item: item, width: 132, height: 198, style: ChargePosterStyle.portrait);
        },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cast & Crew', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        Text(
          crew('cast'),
          style: AppTextStyles.meta.copyWith(fontSize: 15, color: AppColors.colorSilver),
        ),
        const SizedBox(height: 16),
        Text(
          'Director  ·  ${crew('director')}',
          style: AppTextStyles.meta,
        ),
      ],
    );
  }
}
