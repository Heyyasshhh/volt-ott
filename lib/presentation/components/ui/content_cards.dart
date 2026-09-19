import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/models/media/section.dart';
import 'package:volt/presentation/components/bottom_sheet/media_bottomsheet.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/fragments/search_page.dart';

class NetworkPoster extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const NetworkPoster({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(color: AppColors.colorSurface, child: _fallback());
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: Duration.zero,
      placeholder: (_, __) => Container(color: AppColors.colorSurface, child: _fallback()),
      errorWidget: (_, __, ___) => Container(color: AppColors.colorSurface, child: _fallback()),
    );
  }

  Widget _fallback() {
    return Center(child: Image.asset(BrandAssets.logo, width: 64, fit: BoxFit.contain));
  }
}

String bestLandscape(BaseItem item) {
  if (item.featuredPosterUrl.isNotEmpty) return item.featuredPosterUrl;
  if (item.horizontalPosterUrl.isNotEmpty) return item.horizontalPosterUrl;
  return item.verticalPosterUrl;
}

String bestPortrait(BaseItem item) {
  if (item.verticalPosterUrl.isNotEmpty) return item.verticalPosterUrl;
  if (item.squarePosterUrl.isNotEmpty) return item.squarePosterUrl;
  return bestLandscape(item);
}

enum ChargePosterStyle { portrait, landscape, core, strip }

class ChargePoster extends StatelessWidget {
  final BaseItem item;
  final double width;
  final double height;
  final ChargePosterStyle style;
  final bool showProgress;
  final bool showTitle;
  final int energyIndex;
  final bool vault;
  final bool circle;
  final bool wide;
  final double offsetY;

  const ChargePoster({
    super.key,
    required this.item,
    this.width = 132,
    this.height = 198,
    this.style = ChargePosterStyle.portrait,
    this.showProgress = false,
    this.showTitle = false,
    this.energyIndex = 0,
    this.vault = false,
    this.circle = false,
    this.wide = false,
    this.offsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = item.getPercentageWatched().clamp(0.0, 1.0);
    final landscape = wide || style == ChargePosterStyle.landscape || style == ChargePosterStyle.strip;
    final url = landscape ? bestLandscape(item) : bestPortrait(item);
    final overlayTitle = showTitle || landscape;

    Widget poster = NetworkPoster(url: url);

    final framed = ClipRRect(
      borderRadius: BorderRadius.circular(circle ? 999 : AppLayout.radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          poster,
          if (overlayTitle)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x99030507),
                  ],
                ),
              ),
            ),
          if (showProgress && progress > 0)
            Positioned(
              left: 8,
              right: 8,
              bottom: overlayTitle ? 28 : 8,
              child: EnergyProgress(value: progress),
            ),
          if (overlayTitle && item.title.isNotEmpty)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.colorChrome,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => showBottomSheetOrNavigate(context, item),
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: SizedBox(
          width: width,
          height: height,
          child: framed,
        ),
      ),
    );
  }
}

class ChargeStackRow extends StatelessWidget {
  final List<BaseItem> items;
  final bool showProgress;
  final ChargePosterStyle style;

  const ChargeStackRow({
    super.key,
    required this.items,
    this.showProgress = false,
    this.style = ChargePosterStyle.portrait,
  });

  @override
  Widget build(BuildContext context) {
    final landscape = style == ChargePosterStyle.landscape || style == ChargePosterStyle.strip;
    final width = landscape ? 228.0 : 132.0;
    final height = landscape ? 128.0 : 198.0;

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return ChargePoster(
            item: items[index],
            width: width,
            height: height,
            style: style,
            showProgress: showProgress,
            showTitle: landscape,
            energyIndex: index,
          );
        },
      ),
    );
  }
}

class ChargeOverlapStack extends StatelessWidget {
  final List<BaseItem> items;
  final bool showProgress;

  const ChargeOverlapStack({
    super.key,
    required this.items,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChargeStackRow(
      items: items,
      showProgress: showProgress,
      style: ChargePosterStyle.portrait,
    );
  }
}

class EnergyPortraitRing extends StatelessWidget {
  final Widget child;
  final double size;

  const EnergyPortraitRing({super.key, required this.child, this.size = 112});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: ColoredBox(
          color: AppColors.colorSurface,
          child: child,
        ),
      ),
    );
  }
}

class NowPlayingHero extends StatelessWidget {
  final BaseItem item;
  final VoidCallback? onPlay;
  final VoidCallback? onMyList;
  final VoidCallback? onTrailer;
  final Widget? media;

  const NowPlayingHero({
    super.key,
    required this.item,
    this.onPlay,
    this.onMyList,
    this.onTrailer,
    this.media,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = AppLayout.isDesktop(context);
    final height = desktop ? 680.0 : MediaQuery.sizeOf(context).height * 0.72;
    final description = item.description.trim();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          media ?? NetworkPoster(url: desktop ? bestLandscape(item) : bestPortrait(item)),
          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
          Positioned(
            left: AppLayout.gutter(context),
            right: desktop ? MediaQuery.sizeOf(context).width * 0.38 : AppLayout.gutter(context),
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.categories.isNotEmpty)
                  Text(
                    item.categories.first,
                    style: AppTextStyles.eyebrow,
                  ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.displayTitle.copyWith(fontSize: desktop ? 52 : 34),
                ),
                const SizedBox(height: 10),
                Text(mediaMetaLine(item), style: AppTextStyles.meta),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    maxLines: desktop ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.meta.copyWith(fontSize: 14, height: 1.45),
                  ),
                ],
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    PlayCoreButton(
                      onPressed: onPlay ?? () => showBottomSheetOrNavigate(context, item),
                      label: 'Watch Now',
                    ),
                    MetallicButton(
                      label: 'Add to My List',
                      icon: Icons.add,
                      onPressed: onMyList ?? () => showBottomSheetOrNavigate(context, item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FrequencyPortal extends StatelessWidget {
  final String label;
  final BaseItem? item;
  final VoidCallback onTap;
  final int shape;

  const FrequencyPortal({
    super.key,
    required this.label,
    required this.onTap,
    this.item,
    this.shape = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GenrePortalTile(label: label, item: item, onTap: onTap, shape: shape);
  }
}

class DiscoveryRow extends StatelessWidget {
  final Section section;
  final int visualIndex;

  const DiscoveryRow({super.key, required this.section, required this.visualIndex});

  @override
  Widget build(BuildContext context) {
    final items = section.baseItems.where((item) => item.isReleased).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final continueWatching = section.isContinueWatching ||
        section.title.toLowerCase().contains('continue');

    if (continueWatching) {
      return _RowSection(
        title: 'Continue Watching',
        items: items,
        section: section,
        style: ChargePosterStyle.landscape,
        showProgress: true,
      );
    }

    switch (visualIndex % 5) {
      case 0:
        return _RowSection(title: _prettyTitle(section.title, 'Trending Now'), items: items, section: section);
      case 1:
        return _BannerRow(title: _prettyTitle(section.title, 'VOLT Originals'), items: items, section: section);
      case 2:
        return _GenreRow(title: 'Genres', items: items);
      case 3:
        return _FeaturedSplit(title: _prettyTitle(section.title, 'New Releases'), items: items, section: section);
      default:
        return _RowSection(
          title: section.title.isEmpty ? 'Recommended For You' : section.title,
          items: items,
          section: section,
          style: ChargePosterStyle.landscape,
        );
    }
  }

  String _prettyTitle(String original, String fallback) {
    if (original.trim().isEmpty) return fallback;
    return original;
  }
}

class _SeeAll {
  static VoidCallback of(BuildContext context, Section section) {
    return () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage(section: section)));
    };
  }
}

class _RowSection extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;
  final ChargePosterStyle style;
  final bool showProgress;

  const _RowSection({
    required this.title,
    required this.items,
    required this.section,
    this.style = ChargePosterStyle.portrait,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: _SeeAll.of(context, section)),
        ChargeStackRow(items: items.take(16).toList(), showProgress: showProgress, style: style),
      ],
    );
  }
}

class _BannerRow extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;

  const _BannerRow({required this.title, required this.items, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: _SeeAll.of(context, section)),
        SizedBox(
          height: 210,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
            scrollDirection: Axis.horizontal,
            itemCount: items.length.clamp(0, 8),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => showBottomSheetOrNavigate(context, item),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.82,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppLayout.radius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkPoster(url: bestLandscape(item)),
                        const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Text(
                            item.title,
                            maxLines: 2,
                            style: AppTextStyles.editorial.copyWith(fontSize: 22),
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
      ],
    );
  }
}

class _GenreRow extends StatelessWidget {
  final String title;
  final List<BaseItem> items;

  const _GenreRow({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    const genres = ['Action', 'Drama', 'Romance', 'Thriller', 'Comedy', 'Horror', 'Documentary', 'Kids'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        SizedBox(
          height: 112,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index % items.length];
              return SizedBox(
                width: 168,
                child: GenrePortalTile(
                  label: genres[index],
                  item: item,
                  shape: index,
                  onTap: () => showBottomSheetOrNavigate(context, item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedSplit extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;

  const _FeaturedSplit({required this.title, required this.items, required this.section});

  @override
  Widget build(BuildContext context) {
    final lead = items.first;
    final rest = items.skip(1).take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: _SeeAll.of(context, section)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: GestureDetector(
                  onTap: () => showBottomSheetOrNavigate(context, lead),
                  child: AspectRatio(
                    aspectRatio: 0.72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppLayout.radius),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          NetworkPoster(url: bestPortrait(lead)),
                          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 14,
                            child: Text(lead.title, style: AppTextStyles.editorial.copyWith(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  children: rest.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ChargePoster(
                        item: item,
                        width: double.infinity,
                        height: 92,
                        wide: true,
                        showTitle: true,
                        style: ChargePosterStyle.strip,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GenrePortalTile extends StatelessWidget {
  final String label;
  final BaseItem? item;
  final int shape;
  final VoidCallback onTap;

  const GenrePortalTile({
    super.key,
    required this.label,
    required this.onTap,
    this.item,
    this.shape = 0,
  });

  @override
  Widget build(BuildContext context) {
    final art = item == null
        ? Container(color: AppColors.colorSurface)
        : NetworkPoster(url: bestLandscape(item!));

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppLayout.radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            art,
            Container(color: Colors.black.withValues(alpha: 0.38)),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  label,
                  style: AppTextStyles.editorial.copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
