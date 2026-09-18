import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/components/ui/content_cards.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:provider/provider.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final List<BaseItem> _series = [];
  final searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _fill(ContentProvider contentProvider, String q) {
    _series.clear();
    if (q.isEmpty) {
      _series.addAll(contentProvider.getSeries());
      return;
    }
    final needle = q.toLowerCase();
    _series.addAll(contentProvider.getSeries().where((series) => series.title.toLowerCase().contains(needle)));
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    if (_series.isEmpty && _query.isEmpty) {
      _fill(contentProvider, '');
    }
    final gutter = AppLayout.gutter(context);

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Navigator.canPop(context)) ...[
                        CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 40,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text('WEB SERIES', style: AppTextStyles.displayTitle.copyWith(fontSize: 34)),
                      const SizedBox(height: 6),
                      Text('Series', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
                      const SizedBox(height: 18),
                      ChromeFrame(
                        inset: 4,
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(color: Colors.white, fontFamily: AppTheme.displayFamily, fontSize: 18),
                          cursorColor: AppColors.colorOrange,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search',
                            hintStyle: TextStyle(color: AppColors.colorHint, fontSize: 14),
                            prefixIcon: Icon(Icons.search_rounded, color: AppColors.colorAccent),
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _query = value;
                              _fill(contentProvider, value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (contentProvider.getStatus() == Status.fetching)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.colorAccent)),
                )
              else if (_series.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 22, gutter, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _series[index];
                        final mode = index % 5;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Align(
                            alignment: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
                            child: ChargePoster(
                              item: item,
                              width: mode == 0 ? 230 : 156,
                              height: mode == 0 ? 138 : 228,
                              wide: mode == 0,
                              circle: mode == 3,
                              vault: mode == 2,
                            ),
                          ),
                        );
                      },
                      childCount: _series.length,
                    ),
                  ),
                )
              else
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.tv_outlined,
                    title: 'No TV shows found',
                    subtitle: 'Try a different title or check back later.',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
