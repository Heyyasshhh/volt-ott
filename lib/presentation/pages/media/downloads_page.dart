import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/media/download_item_wrapper.dart';
import 'package:volt/presentation/components/media/downloaded_media_item.dart';
import 'package:volt/providers/download_provider.dart';
import 'package:provider/provider.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  bool _isQueued(DownloadItemWrapper wrapper) {
    final status = wrapper.downloadedBaseItem.status;
    return status == 'waiting_to_start' || status == 'enqueued';
  }

  bool _isDownloading(DownloadItemWrapper wrapper) {
    final status = wrapper.downloadedBaseItem.status;
    final progress = wrapper.downloadedBaseItem.progress;
    return status == 'downloading' ||
        status == 'paused' ||
        status == 'retrying' ||
        status == 'failed' ||
        (progress > 0 && progress < 1 && status != 'downloaded');
  }

  bool _isDownloaded(DownloadItemWrapper wrapper) {
    final item = wrapper.downloadedBaseItem;
    return item.status == 'downloaded' || item.progress >= 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: Consumer<DownloadProvider>(
            builder: (context, downloadProvider, _) {
              final downloadWrappers = downloadProvider.getAllDownloads().values.toList();
              final live = <DownloadItemWrapper>[];
              for (final wrapper in downloadWrappers) {
                final item = wrapper.downloadedBaseItem;
                if (item.status == 'canceled' || item.validTill < DateTime.now().millisecondsSinceEpoch) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    downloadProvider.deleteDownload(item.id, item.taskId);
                  });
                  continue;
                }
                live.add(wrapper);
              }

              final downloaded = live.where(_isDownloaded).toList();
              final downloading = live.where((w) => !_isDownloaded(w) && _isDownloading(w)).toList();
              final queued = live.where((w) => !_isDownloaded(w) && !_isDownloading(w) && _isQueued(w)).toList();
              final leftover = live
                  .where((w) => !_isDownloaded(w) && !_isDownloading(w) && !_isQueued(w))
                  .toList();
              downloading.addAll(leftover);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (Navigator.of(context).canPop())
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: CircleIconButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  size: 40,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                'Downloads',
                                style: AppTextStyles.displayTitle.copyWith(fontSize: 28),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: AppColors.colorHairline, height: 1),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: live.isNotEmpty
                          ? ListView(
                              key: const ValueKey('downloads-list'),
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                              children: [
                                if (downloaded.isNotEmpty) ...[
                                  const _OfflineHeading(label: 'Downloaded'),
                                  ...downloaded.map((wrapper) => DownloadedMediaItem(wrapper: wrapper)),
                                ],
                                if (downloading.isNotEmpty) ...[
                                  const _OfflineHeading(label: 'Downloading'),
                                  ...downloading.map((wrapper) => DownloadedMediaItem(wrapper: wrapper)),
                                ],
                                if (queued.isNotEmpty) ...[
                                  const _OfflineHeading(label: 'Queued'),
                                  ...queued.map((wrapper) => DownloadedMediaItem(wrapper: wrapper)),
                                ],
                              ],
                            )
                          : const EmptyState(
                              icon: Icons.download_outlined,
                              title: 'No downloads yet',
                              subtitle: 'Videos you download will appear here for offline viewing.',
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OfflineHeading extends StatelessWidget {
  final String label;
  const _OfflineHeading({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          const Divider(color: AppColors.colorHairline, height: 1),
        ],
      ),
    );
  }
}
