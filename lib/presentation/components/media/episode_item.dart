import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:volt/services/deeplinkly_service.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:volt/providers/download_provider.dart';
import 'package:volt/providers/content_provider.dart';
import '../bottom_sheet/media_bottomsheet.dart';
import '../bottom_sheet/download_bottomsheet.dart';

class EpisodeItem extends StatefulWidget {
  final BaseItem baseItem;
  final bool isHighlighted;

  const EpisodeItem({super.key, required this.baseItem, this.isHighlighted = false});

  @override
  State<EpisodeItem> createState() => _EpisodeItemState();
}

class _EpisodeItemState extends State<EpisodeItem> with SingleTickerProviderStateMixin {
  bool _isSharing = false;
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatScale;

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 6),
    ]).animate(CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut));
    if (widget.isHighlighted) {
      _heartbeatController.repeat();
    }
  }

  @override
  void didUpdateWidget(EpisodeItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !_heartbeatController.isAnimating) {
      _heartbeatController.repeat();
    } else if (!widget.isHighlighted) {
      _heartbeatController.stop();
      _heartbeatController.reset();
    }
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "0 min";

    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      if (remainingMinutes > 0) {
        return "${hours}h ${remainingMinutes}min";
      }
      return "${hours}h";
    }
    return "${minutes}min";
  }

  @override
  Widget build(BuildContext context) {
    final episodeNo = widget.baseItem.episodeNumber;
    final progress = widget.baseItem.getPercentageWatched().clamp(0.0, 1.0);
    final numberLabel = episodeNo > 0 ? episodeNo.toString().padLeft(2, '0') : '•';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 42,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isHighlighted ? AppColors.colorOrange : AppColors.colorAccent,
                        width: 1.4,
                      ),
                      gradient: widget.isHighlighted ? AppColors.primaryGradient : null,
                    ),
                    child: Text(
                      numberLabel,
                      style: TextStyle(
                        color: widget.isHighlighted ? const Color(0xFF030609) : AppColors.colorSilver,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTheme.displayFamily,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.colorAccent, Color(0x00008CFF)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => showBottomSheetOrNavigate(context, widget.baseItem),
                child: AnimatedBuilder(
                  animation: _heartbeatScale,
                  builder: (context, child) {
                    final scale = widget.isHighlighted ? _heartbeatScale.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      alignment: Alignment.centerLeft,
                      child: child,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 132,
                            child: ChromeFrame(
                              inset: 3,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedNetworkImage(
                                  imageUrl: widget.baseItem.horizontalPosterUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (ctx, url) => Shimmer.fromColors(
                                    baseColor: const Color(0xFF1F1F1F),
                                    highlightColor: Colors.grey[800]!,
                                    child: Container(color: const Color(0xFF1F1F1F)),
                                  ),
                                  errorWidget: (ctx, url, err) => Shimmer.fromColors(
                                    baseColor: const Color(0xFF1F1F1F),
                                    highlightColor: Colors.grey[800]!,
                                    child: Container(color: const Color(0xFF1F1F1F)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.baseItem.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: AppTextStyles.editorial.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDuration(widget.baseItem.lengthSeconds),
                                  style: AppTextStyles.eyebrow.copyWith(
                                    color: AppColors.colorTextMuted,
                                    fontSize: 9,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _isSharing
                                          ? null
                                          : () async {
                                              setState(() => _isSharing = true);
                                              try {
                                                final url = await DeepLinklyLinkService.instance.generateLink(
                                                  context,
                                                  type: LinkType.episode,
                                                  data: {
                                                    'slug': widget.baseItem.id,
                                                    'title': widget.baseItem.title,
                                                    'description': widget.baseItem.description,
                                                    'poster': widget.baseItem.verticalPosterUrl,
                                                  },
                                                );
                                                if (mounted) Share.share(url);
                                              } finally {
                                                if (mounted) setState(() => _isSharing = false);
                                              }
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.colorHairline),
                                        ),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: _isSharing
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                )
                                              : const Icon(Icons.share, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (widget.baseItem.mediaType == MediaType.episode && widget.baseItem.isDownloadable)
                                      _EpisodeDownloadButton(baseItem: widget.baseItem),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.baseItem.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.baseItem.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.meta.copyWith(fontSize: 12, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 8,
                        child: EnergyProgress(value: progress),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeDownloadButton extends StatefulWidget {
  final BaseItem baseItem;

  const _EpisodeDownloadButton({required this.baseItem});

  @override
  State<_EpisodeDownloadButton> createState() => _EpisodeDownloadButtonState();
}

class _EpisodeDownloadButtonState extends State<_EpisodeDownloadButton> {
  bool downloadButtonClickable = true;
  bool isLoadingUrl = false;

  Future<bool> _ensureDownloadUrl() async {
    if (widget.baseItem.downloadUrl.isNotEmpty) {
      return true;
    }

    setState(() {
      isLoadingUrl = true;
    });

    final completer = Completer<bool>();
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);

    contentProvider.getVideoUrls(
      widget.baseItem.id,
      widget.baseItem.mediaType,
      parentId: widget.baseItem.parentSeriesId,
      () {
        if (mounted) {
          setState(() {
            isLoadingUrl = false;
          });
          // Get updated baseItem from contentProvider to check if downloadUrl is now available
          final series = contentProvider.getSeries().firstWhere(
            (s) => s.id == widget.baseItem.parentSeriesId,
            orElse: () => throw Exception("Series not found"),
          );
          final episode = series.episodes.firstWhere(
            (e) => e.id == widget.baseItem.id,
            orElse: () => throw Exception("Episode not found"),
          );
          completer.complete(episode.downloadUrl.isNotEmpty);
        } else {
          completer.complete(false);
        }
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AuthenticationProvider>(context);
    final user = userProvider.getUser();

    return Consumer<DownloadProvider>(
      builder: (BuildContext context, DownloadProvider value, Widget? child) {
        final downloadItemWrapper = value.getDownloadedBaseItemWrapper(widget.baseItem.id);
        final downloadItem = downloadItemWrapper?.downloadedBaseItem;

        bool isDownloaded = false;
        bool isDownloading = false;
        bool isPaused = false;
        double progress = 0.0;

        if (downloadItem != null) {
          String downloadStatus = downloadItem.status;
          if (downloadStatus == "downloaded" && downloadItem.progress < 1) {
            downloadItem.status = "paused";
            downloadStatus = "paused";
          }

          progress = downloadItem.progress;

          switch (downloadStatus) {
            case "downloaded":
              isDownloaded = true;
            case "downloading":
            case "waiting_to_start":
            case "retrying":
              isDownloading = true;
            case "paused":
              isDownloading = true;
              isPaused = true;
            default:
              break;
          }
        }

        return GestureDetector(
          onTap: () async {
            if (!downloadButtonClickable || isLoadingUrl) return;

            if (isDownloaded) {
              // Show delete dialog
              showDialog(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.7),
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.colorBackground.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.colorPrimary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Delete Download?",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Are you sure you want to delete ${widget.baseItem.title} from downloads?",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        value.deleteDownload(widget.baseItem.id, downloadItem?.taskId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (isDownloading || isPaused) {
              // Show bottom sheet with pause/resume/cancel options
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => DownloadBottomSheetWidget(
                  baseItemId: widget.baseItem.id,
                ),
              );
            } else {
              // Start download - first ensure we have download URL
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please Login To Download Content")),
                );
                return;
              }

              if (user.userSubscription == null || !user.canDownload) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please Upgrade Your Plan To Download")),
                );
                return;
              }

              // Get download URL if not available
              BaseItem? episodeToDownload = widget.baseItem;
              if (widget.baseItem.downloadUrl.isEmpty) {
                downloadButtonClickable = false;
                final hasUrl = await _ensureDownloadUrl();
                downloadButtonClickable = true;

                if (!hasUrl) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Unable to get download URL. Please try again.")),
                    );
                  }
                  return;
                }

                // Get updated episode with download URL
                final contentProvider = Provider.of<ContentProvider>(context, listen: false);
                final series = contentProvider.getSeries().firstWhere(
                  (s) => s.id == widget.baseItem.parentSeriesId,
                  orElse: () => throw Exception("Series not found"),
                );
                episodeToDownload = series.episodes.firstWhere(
                  (e) => e.id == widget.baseItem.id,
                  orElse: () => throw Exception("Episode not found"),
                );
              }

              downloadButtonClickable = false;
              await value.startDownload(episodeToDownload, user);
              downloadButtonClickable = true;
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: _buildButtonContent(isDownloaded, isDownloading, isPaused, progress, isLoadingUrl),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(bool isDownloaded, bool isDownloading, bool isPaused, double progress, bool isLoadingUrl) {
    if (isLoadingUrl) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (isDownloaded) {
      return const Icon(
        Icons.download_done,
        color: Colors.white,
        size: 18,
      );
    }

    if (isDownloading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            if (isPaused)
              const Icon(
                Icons.pause,
                color: Colors.white,
                size: 10,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      );
    }

    return const Icon(
      Icons.download,
      color: Colors.white,
      size: 18,
    );
  }
}
