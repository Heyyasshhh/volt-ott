import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/components/ui/content_cards.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:volt/providers/my_list_provider.dart';
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

    final watchLater = saved.where((item) => item.getPercentageWatched() <= 0).toList();
    final started = saved.where((item) {
      final p = item.getPercentageWatched();
      return p > 0 && p < 0.8;
    }).toList();
    final finishSoon = saved.where((item) => item.getPercentageWatched() >= 0.8).toList();
    final canSplit = started.isNotEmpty || finishSoon.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: saved.isEmpty && continueWatching.isEmpty && upcoming.isEmpty
              ? Column(
                  children: [
                    _header(context),
                    const Expanded(
                      child: EmptyState(
                        icon: Icons.bolt_outlined,
                        title: 'Your list is empty',
                        subtitle: 'Save titles from a details page to watch them later.',
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    _header(context),
                    if (canSplit) ...[
                      if (watchLater.isNotEmpty) ...[
                        const SectionHeader(title: 'Watch Later'),
                        ChargeOverlapStack(items: watchLater),
                      ],
                      if (started.isNotEmpty) ...[
                        const SectionHeader(title: 'STARTED'),
                        ChargeStackRow(items: started, showProgress: true, style: ChargePosterStyle.landscape),
                      ],
                      if (finishSoon.isNotEmpty) ...[
                        const SectionHeader(title: 'Finish Soon'),
                        ChargeStackRow(items: finishSoon, showProgress: true, style: ChargePosterStyle.core),
                      ],
                    ] else if (saved.isNotEmpty) ...[
                      const SectionHeader(title: 'My List'),
                      ChargeOverlapStack(items: saved),
                      ChargeStackRow(items: saved, style: ChargePosterStyle.landscape),
                    ],
                    if (continueWatching.isNotEmpty) ...[
                      const SectionHeader(title: 'CONTINUE WATCHING'),
                      ChargeStackRow(
                        items: continueWatching,
                        showProgress: true,
                        style: ChargePosterStyle.strip,
                      ),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      const SectionHeader(title: 'COMING SOON'),
                      ChargeStackRow(items: upcoming),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
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
                child: Text('My List', style: AppTextStyles.displayTitle.copyWith(fontSize: 28)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const EnergyTrail(height: 1.4, orange: true),
        ],
      ),
    );
  }
}
