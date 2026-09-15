import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chill/constants/colors.dart';
import 'package:chill/presentation/components/media/downloaded_media_item.dart';
import 'package:chill/providers/download_provider.dart';
import 'package:provider/provider.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Downloads",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.colorBackground,
      ),
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        child: Consumer<DownloadProvider>(
          builder: (context, downloadProvider, _) {
            final downloadWrappers = downloadProvider.getAllDownloads().values.toList();
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: downloadWrappers.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: downloadWrappers.length,
                        itemBuilder: (context, index) {
                          final wrapper = downloadWrappers[index];
                          final item = wrapper.downloadedBaseItem;

                          // Delete expired or cancelled items
                          if (item.status == "canceled" || item.validTill < DateTime.now().millisecondsSinceEpoch) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              downloadProvider.deleteDownload(item.id, item.taskId);
                            });
                            return const SizedBox.shrink();
                          }

                          return DownloadedMediaItem(wrapper: wrapper);
                        },
                      ),
                    )
                  : BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          key: const ValueKey("empty-state"),
                          children: [
                            FaIcon(
                              FontAwesomeIcons.download,
                              size: 120,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "No Downloads Yet",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Videos you download will appear here. Start watching to save them offline!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
