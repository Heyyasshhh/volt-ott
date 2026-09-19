import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/models/media/section.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/components/ui/content_cards.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  final Section? section;

  const SearchPage({super.key, this.section});

  @override
  State<SearchPage> createState() => _ShowsPageState();
}

class _ShowsPageState extends State<SearchPage> {
  final List<BaseItem> _shows = [];
  final searchController = TextEditingController();
  String _query = '';

  static const _shortcuts = [
    'Action',
    'Drama',
    'Comedy',
    'Thriller',
    'Romance',
    'Latest releases',
  ];

  static const _genres = [
    'Action',
    'Romance',
    'Thriller',
    'Drama',
    'Comedy',
    'Horror',
    'Documentary',
    'Kids',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool _matches(BaseItem item, String q) {
    if (!item.isReleased) return false;
    if (q.isEmpty) return true;
    final hay = '${item.title} ${item.description} ${item.getClassificationString()} ${item.categories.join(' ')}'.toLowerCase();
    final needle = q.toLowerCase();
    if (needle.contains('intense') || needle.contains('thrill')) {
      return hay.contains('thrill') || hay.contains('action') || hay.contains('crime') || hay.contains('horror') || hay.contains('intense');
    }
    if (needle.contains('weekend')) {
      return hay.contains('drama') || hay.contains('comedy') || hay.contains('family') || hay.contains('romance') || hay.contains('weekend');
    }
    if (needle.contains('family')) {
      return hay.contains('family') || hay.contains('kids') || hay.contains('comedy');
    }
    if (needle.contains('hindi')) {
      final hindi = hay.contains('hindi');
      if (needle.contains('action')) return hindi || hay.contains('action');
      return hindi;
    }
    if (needle.contains('latest') || needle.contains('release')) {
      final cutoff = DateTime.now().subtract(const Duration(days: 730));
      return item.releaseTime.isAfter(cutoff);
    }
    if (needle.contains('2 hours') || needle.contains('under')) {
      return item.lengthSeconds > 0 && item.lengthSeconds < 7200;
    }
    return hay.contains(needle) || item.title.toLowerCase().contains(needle);
  }

  void _fill(ContentProvider content, String q) {
    _shows.clear();
    if (widget.section != null && q.isEmpty) {
      _shows.addAll(widget.section!.allBaseItems.where((item) => item.isReleased));
      return;
    }
    final pool = <BaseItem>[
      ...content.getMovies(),
      ...content.getSeries(),
    ];
    _shows.addAll(pool.where((item) => _matches(item, q)));
  }

  void _applyQuery(ContentProvider content, String value) {
    setState(() {
      _query = value;
      _fill(content, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    if (_shows.isEmpty && _query.isEmpty) {
      _fill(contentProvider, '');
    }

    final all = [...contentProvider.getMovies(), ...contentProvider.getSeries()].where((e) => e.isReleased).toList();
    final gutter = AppLayout.gutter(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                        if (widget.section != null)
                          CircleIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            size: 40,
                            onPressed: () => Navigator.pop(context),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          widget.section?.title ?? 'Explore',
                          style: AppTextStyles.displayTitle.copyWith(fontSize: 32),
                        ),
                        if (widget.section == null) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            cursorColor: AppColors.colorOrange,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.colorSurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.colorHairline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.colorHairline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.colorAccent),
                              ),
                              hintText: 'Search movies, series, actors...',
                              hintStyle: const TextStyle(color: AppColors.colorHint, fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.colorAccent),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (value) => _applyQuery(contentProvider, value),
                          ),
                          const SizedBox(height: 22),
                          const Text('Trending Searches', style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _shortcuts.map((label) {
                              return GestureDetector(
                                onTap: () {
                                  searchController.text = label;
                                  _applyQuery(contentProvider, label);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.colorSurface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.colorHairline),
                                  ),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: AppColors.colorSilver,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (widget.section == null && _query.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 12),
                      child: Text('Genres', style: AppTextStyles.sectionTitle),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.86,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final label = _genres[index];
                          final item = all.isEmpty ? null : all[index % all.length];
                          return GenrePortalTile(
                            label: label,
                            item: item,
                            shape: index,
                            onTap: () {
                              searchController.text = label;
                              _applyQuery(contentProvider, label);
                            },
                          );
                        },
                        childCount: _genres.length,
                      ),
                    ),
                  ),
                ],
                if (contentProvider.getStatus() == Status.fetching)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.colorAccent)),
                  )
                else if (_shows.isEmpty && _query.isNotEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: "We don't have this yet",
                      subtitle: 'Try a different title, topic, or keyword.',
                    ),
                  )
                else if (_shows.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 120),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: AppLayout.portraitColumns(context),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.66,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _shows[index];
                          return ChargePoster(
                            item: item,
                            width: double.infinity,
                            height: double.infinity,
                            style: ChargePosterStyle.portrait,
                          );
                        },
                        childCount: _shows.length,
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
