import 'package:flutter/material.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/models/media/media_item.dart';
import 'package:mozo/presentation/components/media/media_item.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';
import 'package:mozo/providers/content_provider.dart';
import 'package:mozo/providers/my_list_provider.dart';
import 'package:provider/provider.dart';

class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  List<BaseItem> _resolveItems(ContentProvider content, List<String> ids) {
    final items = <BaseItem>[];
    for (final id in ids) {
      final movie = content.getMediaById(id, MediaType.movie);
      final series = content.getMediaById(id, MediaType.series);
      final item = movie ?? series ?? content.getMediaById(id);
      if (item != null) items.add(item);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final myList = Provider.of<MyListProvider>(context);
    final saved = _resolveItems(contentProvider, myList.ids);
    final continueWatching = contentProvider
        .getSections()
        .where((section) => section.isContinueWatching || section.title.toLowerCase().contains('continue'))
        .expand((section) => section.baseItems)
        .toList();
    final upcoming = contentProvider.getUpcoming();
    final nested = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        bottom: false,
        child: saved.isEmpty && continueWatching.isEmpty && upcoming.isEmpty
            ? Column(
                children: [
                  PageHeader(title: 'My List', showBack: nested),
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'Your list is empty',
                      subtitle: 'Save titles from a details page to watch them later.',
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  PageHeader(title: 'My List', showBack: nested),
                  if (saved.isNotEmpty) ...[
                    const SectionHeader(title: 'Saved'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: saved.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2 / 3,
                        ),
                        itemBuilder: (context, index) => MediaItem(baseItem: saved[index]),
                      ),
                    ),
                  ],
                  if (continueWatching.isNotEmpty) ...[
                    const SectionHeader(title: 'Continue Watching'),
                    _ContinueRow(items: continueWatching),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    const SectionHeader(title: 'Coming Soon'),
                    _PosterRow(items: upcoming),
                  ],
                ],
              ),
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  final List<BaseItem> items;

  const _PosterRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.32;
    return SizedBox(
      height: width * 1.5,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: width,
            child: MediaItem(baseItem: items[index]),
          );
        },
      ),
    );
  }
}

class _ContinueRow extends StatelessWidget {
  final List<BaseItem> items;

  const _ContinueRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.42;
    return SizedBox(
      height: width * 0.72 + 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final left = remainingWatchLabel(item);
          return SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaItemHorizontal(baseItem: item, isContinueWatching: true),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                if (left.isNotEmpty)
                  Text(left, style: const TextStyle(color: AppColors.colorTextMuted, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}
