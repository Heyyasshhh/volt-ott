import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mozo/constants/app_theme.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/models/media/media_item.dart';
import 'package:mozo/models/user/user.dart';
import 'package:mozo/presentation/custom_controls/custom_controls_widget_slider.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';
import 'package:mozo/providers/my_list_provider.dart';
import 'package:provider/provider.dart';
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
            child: CachedNetworkImage(
              imageUrl: widget.slide.getFeaturedPosterUrl(),
              placeholder: (context, url) => Container(
                color: AppColors.colorSurface,
                child: Center(
                  child: Image.asset(
                    "assets/images/butterfly-text.png",
                    width: 200,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.colorSurface,
                child: Center(
                  child: Image.asset(
                    "assets/images/butterfly-text.png",
                    width: 200,
                  ),
                ),
              ),
              fit: BoxFit.cover,
            ),
          );

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (!_wantsTrailer)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
          if (!_wantsTrailer)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRENDING NOW',
                    style: TextStyle(
                      color: AppColors.colorAccent,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.slide.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.displayTitle.copyWith(fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mediaMetaLine(widget.slide as BaseItem),
                    style: AppTextStyles.meta,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 4),
                              Text(
                                'Watch Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          final id = widget.slide.id?.toString();
                          if (id == null || id.isEmpty) {
                            widget.onTap();
                            return;
                          }
                          final added = await Provider.of<MyListProvider>(context, listen: false).toggle(id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(added ? 'Added to My List' : 'Removed from My List')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'My List',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
