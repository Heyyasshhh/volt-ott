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
    'Something intense',
    'under 2 hours',
    'Weekend watch',
    'Latest releases',
    'Hindi action',
    'Family night',
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
                          widget.section?.title ?? 'Search',
                          style: AppTextStyles.displayTitle.copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: 6),
                        Text('Search', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
                        if (widget.section == null) ...[
                          const SizedBox(height: 18),
                          ChromeFrame(
                            inset: 4,
                            child: TextField(
                              controller: searchController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: AppTheme.displayFamily,
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                              ),
                              cursorColor: AppColors.colorOrange,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search for title, topic or keyword',
                                hintStyle: TextStyle(color: AppColors.colorHint, fontSize: 14, fontStyle: FontStyle.normal),
                                prefixIcon: Icon(Icons.search_rounded, color: AppColors.colorAccent),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (value) => _applyQuery(contentProvider, value),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text('QUICK SEARCH', style: AppTextStyles.eyebrow),
                          const SizedBox(height: 12),
                          ..._shortcuts.map((label) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () {
                                  searchController.text = label;
                                  _applyQuery(contentProvider, label);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.colorSilver.withValues(alpha: 0.28)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.bolt, color: AppColors.colorOrange, size: 16),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          label.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.colorSilver,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.8,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward, color: AppColors.colorAccent, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
                if (widget.section == null && _query.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 12),
                      child: Text('Browse by genre', style: AppTextStyles.editorial.copyWith(fontSize: 22)),
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
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _shows[index];
                          final mode = index % 6;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Align(
                              alignment: index.isOdd ? Alignment.centerRight : Alignment.centerLeft,
                              child: ChargePoster(
                                item: item,
                                width: mode == 0 || mode == 3 ? 220 : mode == 2 ? 148 : 168,
                                height: mode == 0 || mode == 3 ? 132 : 232,
                                wide: mode == 0 || mode == 3,
                                circle: mode == 2,
                                vault: mode == 4,
                              ),
                            ),
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
