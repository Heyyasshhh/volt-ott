import 'dart:math' as math;

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
    return Center(child: Image.asset(BrandAssets.logo, width: 72, fit: BoxFit.contain));
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
    this.showTitle = true,
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
    final orange = energyIndex.isEven;

    Widget poster = NetworkPoster(url: url);
    if (vault) {
      poster = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.9, 0.05, 0.05, 0, 0,
          0.05, 0.85, 0.1, 0, 0,
          0.1, 0.1, 1.05, 0, 8,
          0, 0, 0, 1, 0,
        ]),
        child: poster,
      );
    }

    final framed = Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _ChargeFramePainter(orange: orange, core: style == ChargePosterStyle.core),
          child: Padding(
            padding: EdgeInsets.all(style == ChargePosterStyle.core ? 10 : 5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                poster,
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.colorBackground.withValues(alpha: 0.18),
                        AppColors.colorBackground.withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
                if (showProgress && progress > 0)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: showTitle ? 28 : 10,
                    child: EnergyProgress(value: progress),
                  ),
                if (showTitle && item.title.isNotEmpty)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Text(
                      item.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.colorSilver,
                        fontSize: style == ChargePosterStyle.strip ? 11 : 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        fontFamily: AppTheme.fontFamily,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (style == ChargePosterStyle.core)
          Positioned(
            right: 8,
            top: 8,
            child: CustomPaint(
              size: const Size(18, 18),
              painter: _MiniBoltPainter(orange: orange),
            ),
          ),
      ],
    );

    return GestureDetector(
      onTap: () => showBottomSheetOrNavigate(context, item),
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: SizedBox(
          width: width,
          height: height,
          child: circle
              ? EnergyPortraitRing(
                  size: math.min(width, height),
                  child: poster,
                )
              : framed,
        ),
      ),
    );
  }
}

class _ChargeFramePainter extends CustomPainter {
  final bool orange;
  final bool core;

  _ChargeFramePainter({required this.orange, required this.core});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: orange
          ? [AppColors.colorOrange, AppColors.colorGold, AppColors.colorSilver]
          : [AppColors.colorAccent, AppColors.colorElectric, AppColors.colorSilver],
    ).createShader(rect);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = core ? 1.6 : 1.1;
    const cut = 10.0;
    final path = Path()
      ..moveTo(cut, 1)
      ..lineTo(size.width - 1, 1)
      ..lineTo(size.width - 1, size.height - cut)
      ..lineTo(size.width - cut, size.height - 1)
      ..lineTo(1, size.height - 1)
      ..lineTo(1, cut)
      ..close();
    canvas.drawPath(path, paint);

    if (core) {
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            (orange ? AppColors.colorOrange : AppColors.colorAccent).withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.42), radius: size.width * 0.7));
      canvas.drawRect(rect, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _ChargeFramePainter oldDelegate) =>
      oldDelegate.orange != orange || oldDelegate.core != core;
}

class _MiniBoltPainter extends CustomPainter {
  final bool orange;
  _MiniBoltPainter({required this.orange});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.58, 1)
      ..lineTo(size.width * 0.28, size.height * 0.48)
      ..lineTo(size.width * 0.5, size.height * 0.48)
      ..lineTo(size.width * 0.38, size.height - 1)
      ..lineTo(size.width * 0.78, size.height * 0.42)
      ..lineTo(size.width * 0.54, size.height * 0.42)
      ..close();
    final paint = Paint()
      ..color = orange ? AppColors.colorOrange : AppColors.colorAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniBoltPainter oldDelegate) => oldDelegate.orange != orange;
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
    final width = landscape ? 220.0 : 138.0;
    final height = landscape ? 128.0 : 210.0;

    return SizedBox(
      height: height + 18,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final tilt = index.isEven ? -0.035 : 0.028;
          final core = index % 3 == 0;
          return Padding(
            padding: EdgeInsets.only(
              right: 10,
              top: index.isEven ? 10 : 0,
              bottom: index.isEven ? 0 : 10,
            ),
            child: Transform.rotate(
              angle: tilt,
              child: ChargePoster(
                item: items[index],
                width: width,
                height: height,
                style: core ? ChargePosterStyle.core : style,
                showProgress: showProgress,
                energyIndex: index,
              ),
            ),
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
    final shown = items.take(6).toList();
    return SizedBox(
      height: 236,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
        scrollDirection: Axis.horizontal,
        itemCount: shown.length,
        itemBuilder: (context, index) {
          return Transform.translate(
            offset: Offset(index == 0 ? 0 : -18, index.isEven ? -6 : 8),
            child: Transform.rotate(
              angle: (index.isEven ? -1 : 1) * 0.045,
              child: ChargePoster(
                item: shown[index],
                width: 148,
                height: 214,
                style: index % 2 == 0 ? ChargePosterStyle.core : ChargePosterStyle.portrait,
                showProgress: showProgress,
                energyIndex: index,
              ),
            ),
          );
        },
      ),
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
      child: CustomPaint(
        painter: _PortraitRingPainter(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ClipOval(child: child),
        ),
      ),
    );
  }
}

class _PortraitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final orange = Paint()
      ..color = AppColors.colorOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final blue = Paint()
      ..color = AppColors.colorAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(c, size.width * 0.46, orange);
    canvas.drawCircle(c, size.width * 0.38, blue);
    for (int i = 0; i < 8; i++) {
      final a = (math.pi * 2 / 8) * i - math.pi / 2;
      final inner = Offset(c.dx + math.cos(a) * size.width * 0.38, c.dy + math.sin(a) * size.width * 0.38);
      final outer = Offset(c.dx + math.cos(a) * size.width * 0.46, c.dy + math.sin(a) * size.width * 0.46);
      canvas.drawLine(inner, outer, orange..strokeWidth = 1.2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final height = AppLayout.isDesktop(context) ? 720.0 : MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -24,
            right: 36,
            top: 0,
            bottom: 80,
            child: ClipPath(
              clipper: const DiagonalClipper(cut: 28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  media ?? NetworkPoster(url: bestPortrait(item)),
                  const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppLayout.gutter(context),
            right: AppLayout.gutter(context),
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOW PLAYING', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.displayTitle.copyWith(fontSize: 40),
                ),
                const SizedBox(height: 10),
                Text(mediaMetaLine(item), style: AppTextStyles.meta.copyWith(letterSpacing: 1.6, fontSize: 11)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    PlayCoreButton(
                      onPressed: onPlay ?? () => showBottomSheetOrNavigate(context, item),
                      size: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          MetallicButton(
                            label: 'MY LIST',
                            icon: Icons.add,
                            onPressed: onMyList ?? () => showBottomSheetOrNavigate(context, item),
                          ),
                          const SizedBox(height: 8),
                          MetallicButton(
                            label: 'TRAILER',
                            icon: Icons.play_circle_outline,
                            onPressed: onTrailer ?? () => showBottomSheetOrNavigate(context, item),
                          ),
                        ],
                      ),
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
    Widget framed = NetworkPoster(url: item == null ? '' : bestPortrait(item!));
    if (shape % 3 == 0) {
      framed = ClipPath(clipper: const DiagonalClipper(cut: 16), child: framed);
    } else if (shape % 3 == 1) {
      framed = ClipOval(child: framed);
    } else {
      framed = ChromeFrame(child: framed);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 108,
        child: Column(
          children: [
            SizedBox(width: 96, height: 118, child: framed),
            const SizedBox(height: 10),
            Text(label.toUpperCase(), style: AppTextStyles.eyebrow.copyWith(fontSize: 9, color: AppColors.colorOrange)),
          ],
        ),
      ),
    );
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
      return _ChargeSection(title: 'Continue Watching', items: items, section: section);
    }

    switch (visualIndex % 6) {
      case 0:
        return _OffsetPosters(title: _prettyTitle(section.title, 'Trending'), items: items, section: section);
      case 1:
        return _Originals(title: _prettyTitle(section.title, 'Originals'), items: items, section: section);
      case 2:
        return _FrequencyRow(title: 'Browse by mood', items: items);
      case 3:
        return _VaultRow(title: _prettyTitle(section.title, 'Classics'), items: items, section: section);
      case 4:
        return _JustDropped(title: _prettyTitle(section.title, 'New'), items: items, section: section);
      default:
        return _OffsetPosters(title: section.title, items: items, section: section);
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

class _ChargeSection extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;

  const _ChargeSection({required this.title, required this.items, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: _SeeAll.of(context, section)),
        ChargeStackRow(items: items.take(12).toList(), showProgress: true, style: ChargePosterStyle.landscape),
      ],
    );
  }
}

class _OffsetPosters extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;

  const _OffsetPosters({required this.title, required this.items, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: _SeeAll.of(context, section)),
        ChargeOverlapStack(items: items),
      ],
    );
  }
}

class _Originals extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;

  const _Originals({required this.title, required this.items, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAll: _SeeAll.of(context, section)),
        SizedBox(
          height: 280,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
            scrollDirection: Axis.horizontal,
            itemCount: math.min(items.length, 8),
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => showBottomSheetOrNavigate(context, item),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.84,
                  child: ChromeFrame(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkPoster(url: bestLandscape(item)),
                        const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: Text(item.title, maxLines: 2, style: AppTextStyles.editorial.copyWith(fontSize: 24)),
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

class _FrequencyRow extends StatelessWidget {
  final String title;
  final List<BaseItem> items;

  const _FrequencyRow({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    const moods = ['Intense', 'Romantic', 'Dark', 'Fun', 'Adventure', 'Mystery', 'Family'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index % items.length];
              return FrequencyPortal(
                label: moods[index],
                item: item,
                shape: index,
                onTap: () => showBottomSheetOrNavigate(context, item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VaultRow extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;

  const _VaultRow({required this.title, required this.items, required this.section});

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
            itemCount: math.min(items.length, 14),
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return ChargePoster(
                item: items[index],
                vault: true,
                width: 124,
                height: 186,
                style: ChargePosterStyle.core,
                energyIndex: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JustDropped extends StatelessWidget {
  final String title;
  final List<BaseItem> items;
  final Section section;

  const _JustDropped({required this.title, required this.items, required this.section});

  @override
  Widget build(BuildContext context) {
    final lead = items.first;
    final rest = items.skip(1).take(4).toList();
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
                    aspectRatio: 0.78,
                    child: ChromeFrame(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          NetworkPoster(url: bestLandscape(lead)),
                          const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 14,
                            child: Text(lead.title, style: AppTextStyles.editorial.copyWith(fontSize: 22)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  children: rest.take(3).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ChargePoster(
                        item: item,
                        width: double.infinity,
                        height: 92,
                        wide: true,
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
    Widget art = item == null
        ? Container(color: AppColors.colorSurface)
        : NetworkPoster(url: bestPortrait(item!));
    if (shape % 4 == 0) {
      art = ClipPath(clipper: const DiagonalClipper(cut: 18), child: art);
    } else if (shape % 4 == 1) {
      art = ClipOval(child: art);
    } else if (shape % 4 == 2) {
      art = ChromeFrame(child: art);
    } else {
      art = ClipPath(clipper: const DiagonalClipper(cut: 8), child: art);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          art,
          Container(color: Colors.black.withValues(alpha: 0.28)),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.editorial.copyWith(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
