import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/models/media/media_item.dart';
import 'package:mozo/models/media/section.dart';
import 'package:mozo/presentation/components/bottom_sheet/media_bottomsheet.dart';
import 'package:mozo/presentation/components/media/media_item.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';
import 'package:mozo/providers/content_provider.dart';
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
  int _selectedCategory = 0;
  bool _searchOpen = false;
  bool _forceResults = false;
  static const _categories = ['All', 'Movies', 'Series', 'Kids', 'Docs'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<BaseItem> _catalog(ContentProvider content) {
    return [
      ...content.getMovies().where((item) => item.isReleased),
      ...content.getSeries().where((item) => item.isReleased),
    ];
  }

  bool _matchesChip(BaseItem item) {
    switch (_selectedCategory) {
      case 1:
        return item.mediaType == MediaType.movie;
      case 2:
        return item.mediaType == MediaType.series;
      case 3:
        return isKidsTitle(item);
      case 4:
        return isDocumentaryTitle(item);
      default:
        return true;
    }
  }

  void _applyQuery(ContentProvider content, String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _shows
        ..clear()
        ..addAll(
          _catalog(content).where((item) {
            if (!_matchesChip(item)) return false;
            if (q.isEmpty) return true;
            return item.title.toLowerCase().contains(q) ||
                item.categories.any((c) => c.toLowerCase().contains(q));
          }),
        );
    });
  }

  Map<String, BaseItem> _genres(List<BaseItem> items) {
    final map = <String, BaseItem>{};
    for (final item in items) {
      for (final category in item.categories) {
        final label = category.trim();
        if (label.isEmpty) continue;
        map.putIfAbsent(label, () => item);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final catalog = _catalog(contentProvider).where(_matchesChip).toList();
    final query = searchController.text.trim();
    final searching = query.isNotEmpty || _forceResults;

    if (widget.section != null && _shows.isEmpty && query.isEmpty) {
      _shows.addAll(widget.section!.allBaseItems.where((item) => item.isReleased));
    }

    if (widget.section != null) {
      return _sectionGrid(contentProvider);
    }

    final featured = catalog.isNotEmpty
        ? catalog.firstWhere(
            (item) => item.featuredPosterUrl.isNotEmpty || item.horizontalPosterUrl.isNotEmpty,
            orElse: () => catalog.first,
          )
        : null;
    final genres = _genres(catalog);
    final popular = catalog.take(12).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Explore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    CircleIconButton(
                      icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                      size: 44,
                      onPressed: () {
                        setState(() {
                          _searchOpen = !_searchOpen;
                          if (!_searchOpen) {
                            searchController.clear();
                            _shows.clear();
                            _forceResults = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (_searchOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: DarkField(
                    controller: searchController,
                    hintText: 'Search titles, topics, keywords',
                    icon: Icons.search_rounded,
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    onChanged: (value) => _applyQuery(contentProvider, value),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                child: CategoryChipBar(
                  labels: _categories,
                  selectedIndex: _selectedCategory,
                  onSelected: (index) {
                    setState(() => _selectedCategory = index);
                    if (searching) _applyQuery(contentProvider, query);
                  },
                ),
              ),
              Expanded(
                child: contentProvider.getStatus() == Status.fetching
                    ? const Center(child: CircularProgressIndicator())
                    : searching
                        ? _resultsGrid()
                        : _browse(featured, genres, popular),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionGrid(ContentProvider contentProvider) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: widget.section!.title, showBack: true),
            Expanded(
              child: contentProvider.getStatus() == Status.fetching
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2 / 3,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) => const ShimmerMediaItem(),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: _shows.length,
                      itemBuilder: (context, index) => MediaItem(baseItem: _shows[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsGrid() {
    if (_shows.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: "We don't have this yet",
        subtitle: 'Try a different title, topic, or keyword.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2 / 3,
      ),
      itemCount: _shows.length,
      itemBuilder: (context, index) => MediaItem(baseItem: _shows[index]),
    );
  }

  Widget _browse(BaseItem? featured, Map<String, BaseItem> genres, List<BaseItem> popular) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        if (featured != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            child: GestureDetector(
              onTap: () => showBottomSheetOrNavigate(context, featured),
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: PosterScrim(
                  title: featured.title,
                  subtitle: featured.categories.take(2).join('  •  ').toUpperCase(),
                  child: CachedNetworkImage(
                    imageUrl: featured.featuredPosterUrl.isNotEmpty
                        ? featured.featuredPosterUrl
                        : featured.horizontalPosterUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.colorSurface),
                    errorWidget: (_, __, ___) => Container(color: AppColors.colorSurface),
                  ),
                ),
              ),
            ),
          ),
        if (genres.isNotEmpty) ...[
          const SectionHeader(title: 'Genres'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: genres.length.clamp(0, 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.7,
              ),
              itemBuilder: (context, index) {
                final entry = genres.entries.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    searchController.text = entry.key;
                    setState(() => _searchOpen = true);
                    _applyQuery(Provider.of<ContentProvider>(context, listen: false), entry.key);
                  },
                  child: PosterScrim(
                    title: entry.key,
                    radius: 20,
                    child: CachedNetworkImage(
                      imageUrl: entry.value.horizontalPosterUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.colorSurfaceElevated),
                      errorWidget: (_, __, ___) => Container(color: AppColors.colorSurfaceElevated),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 8),
          SectionHeader(
            title: 'Popular This Week',
            onSeeAll: () {
              setState(() {
                _searchOpen = true;
                _forceResults = true;
              });
              _applyQuery(Provider.of<ContentProvider>(context, listen: false), '');
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.38 * 1.5,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: popular.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.32,
                  child: MediaItem(baseItem: popular[index]),
                );
              },
            ),
          ),
        ],
        if (featured == null && genres.isEmpty && popular.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 80),
            child: EmptyState(
              icon: Icons.explore_rounded,
              title: 'Nothing to explore yet',
              subtitle: 'Titles will appear here as soon as they are published.',
            ),
          ),
      ],
    );
  }
}
