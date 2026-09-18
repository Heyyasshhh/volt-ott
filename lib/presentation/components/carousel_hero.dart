import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/models/user/user.dart';
import 'package:volt/presentation/custom_controls/custom_controls_widget_slider.dart';
import 'package:river_player/river_player.dart';

class CarouselHeroItem extends StatefulWidget {
  final dynamic slide;
  final User? user;
  final double aspectRatio;
  final bool isActive;
  final VoidCallback onTap;

  const CarouselHeroItem({
    super.key,
    required this.slide,
    required this.user,
    required this.aspectRatio,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<CarouselHeroItem> createState() => CarouselHeroItemState();
}

class CarouselHeroItemState extends State<CarouselHeroItem> {
  BetterPlayerController? _bp;

  bool get _wantsTrailer {
    final s = widget.slide;
    final url = (s.trailerUrl ?? '').toString();
    return (s.autoPlayTrailer == true) && url.isNotEmpty;
  }

  void pause() {
    _bp?.pause();
  }

  void _ensureController() {
    if (_bp != null || !_wantsTrailer) return;
    final ds = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.slide.trailerUrl,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 30000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
    );

    _bp = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        fit: BoxFit.cover,
        aspectRatio: 16 / 9,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePlayPause: false,
          enableProgressBar: false,
          enableProgressText: false,
          enableSkips: false,
          enableMute: false,
          enableFullscreen: false,
          enableAudioTracks: false,
          enablePlaybackSpeed: false,
          enableSubtitles: false,
          playerTheme: BetterPlayerTheme.custom,
          customControlsBuilder: (controller, onControlsVisibilityChanged) => CustomControlsWidgetSlider(
            onControlsVisibilityChanged: onControlsVisibilityChanged,
            controlsConfiguration: const BetterPlayerControlsConfiguration(),
            data: {
              'rating': widget.slide.ageRating ?? '',
              'is_series': widget.slide.mediaType == MediaType.series,
              'item': widget.slide,
              'is_logged_in': widget.user != null,
              'is_subscribed': widget.user != null && widget.user!.userSubscription != null,
            },
          ),
        ),
        handleLifecycle: true,
      ),
      betterPlayerDataSource: ds,
    );

    _bp!.setVolume(0.0);
  }

  void _applyActiveState() {
    if (!_wantsTrailer || _bp == null) return;
    if (widget.isActive) {
      _bp!.play();
    } else {
      _bp!.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    if (_wantsTrailer) {
      _ensureController();
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyActiveState());
    }
  }

  void _togglePlayPause() {
    if (_bp == null) return;
    final isPlaying = _bp!.isPlaying() ?? false;
    if (isPlaying) {
      _bp!.pause();
    } else {
      _bp!.play();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(CarouselHeroItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_wantsTrailer && _bp == null) {
      _ensureController();
    }
    if (oldWidget.isActive != widget.isActive) {
      _applyActiveState();
    }
  }

  @override
  void dispose() {
    _bp?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _wantsTrailer && _bp != null
        ? AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayPause,
              child: BetterPlayer(controller: _bp!),
            ),
          )
        : AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: CachedNetworkImage(
                imageUrl: widget.slide.getFeaturedPosterUrl(),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      BrandAssets.logo,
                      width: 200,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      BrandAssets.logo,
                      width: 200,
                    ),
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
          );

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: widget.onTap,
      child: child,
    );
  }
}
