import 'dart:io';

import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/media/download_item_wrapper.dart';
import 'package:volt/presentation/components/bottom_sheet/download_bottomsheet.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/media/offline_video_player.dart';

class DownloadedMediaItem extends StatelessWidget {
  final DownloadItemWrapper wrapper;

  const DownloadedMediaItem({super.key, required this.wrapper});

  void _handleTap(BuildContext context) {
    if (wrapper.downloadedBaseItem.progress == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OfflineVideoDetailsPage(wrapper),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => DownloadBottomSheetWidget(
          baseItemId: wrapper.downloadedBaseItem.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = wrapper.downloadedBaseItem.progress.clamp(0.0, 1.0);
    final showProgress = progress > 0 && progress < 1;

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(wrapper.downloadedBaseItem.posterPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.colorSurface,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.cinemaWash),
                  ),
                  if (showProgress)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: EnergyProgress(value: progress),
                    ),
                  if (showProgress)
                    Positioned(
                      left: 12,
                      bottom: 24,
                      child: Text(
                        '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.colorSilver,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              wrapper.downloadedBaseItem.title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.colorSilver,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                fontFamily: AppTheme.displayFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              wrapper.downloadedBaseItem.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.meta,
            ),
          ],
        ),
      ),
    );
  }
}
