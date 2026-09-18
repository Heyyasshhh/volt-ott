import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/presentation/pages/media/movie_details_page.dart';
import 'package:volt/presentation/pages/media/tv_show_details_page.dart';
import 'package:volt/episode_player_stub.dart' if (dart.library.html) 'package:volt/presentation/pages/media/episode_player_page_web.dart';
import 'package:volt/presentation/pages/media/episode_player_page.dart';
import 'package:flutter/foundation.dart';

import '../../models/notification.dart';
import 'package:volt/constants/colors.dart';

class NotificationItem extends StatefulWidget {
  final NotificationModel notification;

  const NotificationItem({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool get _isMediaType =>
      widget.notification.type == NotificationType.newRelease ||
      widget.notification.type == NotificationType.trailer;

  Color get _typeColor {
    switch (widget.notification.type) {
      case NotificationType.subscription:
        return AppColors.colorOrange;
      case NotificationType.newRelease:
        return AppColors.colorAccent;
      case NotificationType.trailer:
        return AppColors.colorElectric;
      case NotificationType.info:
        return AppColors.colorSilver;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isMediaType && widget.notification.baseItem != null) {
          final baseItem = widget.notification.baseItem;
          if (baseItem!.mediaType == MediaType.movie) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MovieDetailsPage(baseItem),
            ));
          } else if (baseItem.mediaType == MediaType.series) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TvShowDetailsPage(baseItem),
            ));
          } else if (baseItem.mediaType == MediaType.episode) {
            final player = kIsWeb
                ? EpisodePlayerPageWeb(baseItem)
                : EpisodePlayerPage(baseItem);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => player,
            ));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.colorHairline)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: _isMediaType ? 120 : 42,
              color: _typeColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _isMediaType && widget.notification.baseItem != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: widget.notification.baseItem!.horizontalPosterUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.colorSurface,
                            ),
                            errorWidget: (_, __, ___) => Image.asset(
                              'assets/images/volt-logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.notification.title,
                          style: AppTextStyles.editorial.copyWith(fontSize: 20),
                        ),
                        if (widget.notification.time != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.notification.time!,
                            style: AppTextStyles.meta,
                          ),
                        ],
                        if (widget.notification.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.notification.description!,
                            style: AppTextStyles.meta,
                          ),
                        ],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NotificationImage(
                          imageUrl: widget.notification.image,
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.notification.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (widget.notification.time != null)
                                    Text(
                                      widget.notification.time!,
                                      style: AppTextStyles.meta.copyWith(fontSize: 12),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (widget.notification.description != null)
                                Text(
                                  widget.notification.description!,
                                  style: AppTextStyles.meta,
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
}

class _NotificationImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _NotificationImage({
    required this.imageUrl,
    this.width = 40,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: AppColors.colorSurface,
        ),
        errorWidget: (_, __, ___) => Image.asset(
          'assets/images/volt-logo.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
  }
}
