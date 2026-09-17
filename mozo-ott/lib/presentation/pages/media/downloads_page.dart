import 'package:flutter/material.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/presentation/components/media/downloaded_media_item.dart';
import 'package:mozo/providers/download_provider.dart';
import 'package:provider/provider.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nested = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(title: 'Downloads', showBack: nested),
            Expanded(
              child: Consumer<DownloadProvider>(
                builder: (context, downloadProvider, _) {
                  final downloadWrappers = downloadProvider.getAllDownloads().values.toList();
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: downloadWrappers.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: downloadWrappers.length,
                            itemBuilder: (context, index) {
                              final wrapper = downloadWrappers[index];
                              final item = wrapper.downloadedBaseItem;

                              if (item.status == "canceled" || item.validTill < DateTime.now().millisecondsSinceEpoch) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  downloadProvider.deleteDownload(item.id, item.taskId);
                                });
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DownloadedMediaItem(wrapper: wrapper),
                              );
                            },
                          )
                        : const EmptyState(
                            icon: Icons.download_rounded,
                            title: 'No Downloads Yet',
                            subtitle: 'Videos you download will appear here. Start watching to save them offline.',
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
