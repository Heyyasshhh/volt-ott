import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/models/media/media_item.dart';
import 'package:butterfly/presentation/components/media/media_item.dart';
import 'package:butterfly/presentation/components/ui/app_widgets.dart';
import 'package:butterfly/providers/content_provider.dart';
import 'package:butterfly/providers/my_list_provider.dart';
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

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        title: const Text('My List'),
      ),
      body: saved.isEmpty && continueWatching.isEmpty && upcoming.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_add_outlined,
              title: 'Your list is empty',
              subtitle: 'Save titles from a details page to watch them later.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (saved.isNotEmpty) ...[
                  const SectionHeader(title: 'Saved'),
                  _PosterRow(items: saved),
                ],
                if (continueWatching.isNotEmpty) ...[
                  const SectionHeader(title: 'Continue Watching'),
                  _PosterRow(items: continueWatching, horizontal: true),
                ],
                if (upcoming.isNotEmpty) ...[
                  const SectionHeader(title: 'Coming Soon'),
                  _PosterRow(items: upcoming),
                ],
              ],
            ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  final List<BaseItem> items;
  final bool horizontal;

  const _PosterRow({required this.items, this.horizontal = false});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.32;
    return SizedBox(
      height: horizontal ? width * 0.7 : width * 1.45,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: horizontal ? width * 1.5 : width,
            child: MediaItem(
              baseItem: item,
              imageUrl: horizontal ? item.horizontalPosterUrl : '',
            ),
          );
        },
      ),
    );
  }
}
