import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/presentation/components/media/episode_item.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/components/ui/content_cards.dart';
import 'package:volt/presentation/pages/authentication/login_screen.dart';
import 'package:volt/providers/my_list_provider.dart';
import 'package:volt/presentation/pages/media/trailer_player.dart';
import 'package:volt/trailer_player_stub.dart' if (dart.library.html) 'package:volt/presentation/pages/media/trailer_player_web.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/bottom_sheet/media_bottomsheet.dart';
import '../../../providers/authentication_provider.dart';
import '../../../providers/content_provider.dart';
import '../../../services/deeplinkly_service.dart';

class TvShowDetailsPage extends StatefulWidget {
  final BaseItem baseItem;
  final String? highlightEpisodeId;

  const TvShowDetailsPage(this.baseItem, {super.key, this.highlightEpisodeId});

  @override
  State<TvShowDetailsPage> createState() => _TvShowDetailsPageState();
}

class _TvShowDetailsPageState extends State<TvShowDetailsPage> {
  List<String> seasonList = [];
  List<BaseItem> episodeList = [];
  String selectedItem = "";
  bool _isSharing = false;
  final ScrollController _episodeScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  final GlobalKey _episodesSectionKey = GlobalKey();
  final GlobalKey _highlightedEpisodeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    seasonList.addAll(
      List.generate(
        widget.baseItem.numberOfSeasons,
        (index) => 'Season ${index + 1}',
      ),
    );
    if (widget.highlightEpisodeId != null) {
      BaseItem? highlightEpisode;
      for (final e in widget.baseItem.episodes) {
        if (e.id == widget.highlightEpisodeId) {
          highlightEpisode = e;
          break;
        }
      }
      if (highlightEpisode != null) {
        selectedItem = 'Season ${highlightEpisode.seasonNumber}';
      } else {
        selectedItem = seasonList.isNotEmpty ? seasonList.first : '';
      }
    } else {
      selectedItem = seasonList.isNotEmpty ? seasonList.first : '';
    }
    if (widget.highlightEpisodeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scrollToHighlightedEpisode();
        });
      });
    }
  }

  void _scrollToHighlightedEpisode() {
    final episodesContext = _episodesSectionKey.currentContext;
    if (episodesContext != null) {
      Scrollable.ensureVisible(
        episodesContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    }
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final highlightedContext = _highlightedEpisodeKey.currentContext;
      if (highlightedContext != null) {
        Scrollable.ensureVisible(
          highlightedContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.2,
        );
      }
    });
  }

  @override
  void dispose() {
    _episodeScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final isLoggedIn = authenticationProvider.getUser() != null;
    final myList = Provider.of<MyListProvider>(context);
    final series = contentProvider.getMediaById(
      widget.baseItem.id,
      widget.baseItem.mediaType,
    );
    final displayItem = series ?? widget.baseItem;
    episodeList.clear();
    if (series != null && selectedItem.isNotEmpty) {
      episodeList.addAll(
        series.episodes.where(
          (episode) => episode.seasonNumber.toString() == selectedItem.split(" ")[1],
        ),
      );
    }

    final gutter = AppLayout.gutter(context);
    final artUrl = displayItem.featuredPosterUrl.isNotEmpty
        ? displayItem.featuredPosterUrl
        : (displayItem.verticalPosterUrl.isNotEmpty ? displayItem.verticalPosterUrl : bestPortrait(displayItem));

    Future<void> shareSeries() async {
      setState(() => _isSharing = true);
      try {
        final url = await DeepLinklyLinkService.instance.generateLink(
          context,
          type: LinkType.series,
          data: {
            'slug': widget.baseItem.id,
            'title': widget.baseItem.title,
            'description': widget.baseItem.description,
            'poster': widget.baseItem.verticalPosterUrl,
          },
        );
        if (mounted) Share.share(url);
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    }

    void openTrailer() {
      if (!isLoggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(next: TvShowDetailsPage(widget.baseItem)),
          ),
        );
        return;
      }
      final trailerPlayer = kIsWeb ? TrailerVideoPlayerWeb(displayItem) : TrailerVideoPlayer(displayItem);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => trailerPlayer),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _mainScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.78,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkPoster(url: artUrl),
                        const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cinemaWash)),
                        Positioned(
                          left: gutter,
                          right: gutter,
                          bottom: 36,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SERIES',
                                style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                displayItem.title,
                                style: AppTextStyles.displayTitle.copyWith(fontSize: 46, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                mediaMetaLine(displayItem),
                                style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorSilver, letterSpacing: 2.2, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
                    child: Column(
                      children: [
                        PlayCoreButton(
                          onPressed: () {
                            if (episodeList.isNotEmpty) {
                              showBottomSheetOrNavigate(context, episodeList.first);
                            }
                          },
                          size: 86,
                          label: 'WATCH NOW',
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            DetailAction(
                              icon: myList.contains(displayItem.id) ? Icons.add_circle : Icons.add_circle_outline,
                              label: 'My List',
                              active: myList.contains(displayItem.id),
                              onPressed: () => myList.toggle(displayItem.id),
                            ),
                            DetailAction(
                              icon: Icons.movie_filter_outlined,
                              label: 'Trailer',
                              onPressed: displayItem.trailerUrl.isNotEmpty ? openTrailer : () {},
                            ),
                            DetailAction(
                              icon: Icons.favorite_border,
                              label: 'Like',
                              onPressed: () {},
                            ),
                            DetailAction(
                              icon: Icons.ios_share_rounded,
                              label: 'Share',
                              onPressed: _isSharing ? () {} : shareSeries,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STORYLINE', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorAccent)),
                        const SizedBox(height: 10),
                        Text(
                          displayItem.description,
                          style: AppTextStyles.editorial.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.colorSilver,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (displayItem.trailerUrl.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 8),
                      child: GestureDetector(
                        onTap: openTrailer,
                        child: SizedBox(
                          height: 120,
                          child: ChromeFrame(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                NetworkPoster(url: bestLandscape(displayItem)),
                                Container(color: Colors.black.withValues(alpha: 0.28)),
                                const Center(
                                  child: Icon(Icons.play_circle_outline, color: AppColors.colorOrange, size: 42),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    key: _episodesSectionKey,
                    padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SEASONS', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
                        const SizedBox(height: 8),
                        Text('Episodes', style: AppTextStyles.sectionTitle),
                      ],
                    ),
                  ),
                  if (seasonList.isNotEmpty) _seasonTimeline(),
                  const SizedBox(height: 12),
                  if (episodeList.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: gutter),
                      child: Column(
                        children: List.generate(episodeList.length, (index) {
                          final episode = episodeList[index];
                          final highlighted = episode.id == widget.highlightEpisodeId;
                          return KeyedSubtree(
                            key: highlighted ? _highlightedEpisodeKey : ValueKey(episode.id),
                            child: EpisodeItem(
                              baseItem: episode,
                              isHighlighted: highlighted,
                            ),
                          );
                        }),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 30),
                      child: Center(
                        child: Text(
                          "Coming Soon",
                          style: TextStyle(color: Colors.white60, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: LightningDivider(),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 16),
                    child: _seriesCast(displayItem),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RELATED', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorAccent)),
                        const SizedBox(height: 8),
                        const Text('More like this', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final suggestedSeries = _getSuggestedSeries(displayItem, contentProvider);
                            if (suggestedSeries.isEmpty) {
                              return const Text(
                                "No suggestions available",
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              );
                            }
                            return SizedBox(
                              height: 230,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: suggestedSeries.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final item = suggestedSeries[index];
                                  switch (index % 4) {
                                    case 0:
                                      return ChargePoster(item: item, width: 148, height: 220, style: ChargePosterStyle.portrait);
                                    case 1:
                                      return ChargePoster(item: item, width: 210, height: 132, style: ChargePosterStyle.landscape, wide: true);
                                    case 2:
                                      return ChargePoster(item: item, width: 118, height: 172, style: ChargePosterStyle.core, circle: true);
                                    default:
                                      return ChargePoster(item: item, width: 128, height: 196, style: ChargePosterStyle.strip, vault: true);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              left: 8,
              child: CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                size: 40,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              right: 8,
              child: CircleIconButton(
                icon: myList.contains(displayItem.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 40,
                iconColor: myList.contains(displayItem.id) ? AppColors.colorPrimary : Colors.white,
                onPressed: () => myList.toggle(displayItem.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seasonTimeline() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppLayout.gutter(context)),
        scrollDirection: Axis.horizontal,
        itemCount: seasonList.length,
        separatorBuilder: (_, __) => const SizedBox(
          width: 18,
          child: Center(child: EnergyTrail(height: 2)),
        ),
        itemBuilder: (context, index) {
          final label = seasonList[index];
          final selected = label == selectedItem;
          return GestureDetector(
            onTap: () => setState(() => selectedItem = label),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: selected ? 22 : 12,
                  height: selected ? 22 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected ? AppColors.primaryGradient : null,
                    border: Border.all(color: selected ? AppColors.colorOrange : AppColors.colorAccent, width: 1.4),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.colorOrange.withValues(alpha: 0.45),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: selected ? AppColors.colorOrange : AppColors.colorTextMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _seriesCast(BaseItem displayItem) {
    final members = <CastMember>[];
    if (displayItem.castAndCrew != null) {
      final castGroup = displayItem.castAndCrew!.firstWhere(
        (group) => group.role.toLowerCase() == 'cast',
        orElse: () => CastAndCrew(role: '', members: []),
      );
      members.addAll(castGroup.members);
    }

    if (members.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DETAILS', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorGold)),
          const SizedBox(height: 8),
          const Text('Show Detail', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Text(
            'CAST  /  ${_getCastNames(displayItem)}',
            style: AppTextStyles.meta.copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            'DIRECTOR  /  ${_getDirectorName(displayItem)}',
            style: AppTextStyles.meta.copyWith(letterSpacing: 0.8),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CAST', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorGold)),
        const SizedBox(height: 8),
        const Text('Cast', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 14),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final member = members[index];
              final photo = member.profilePictureUrl ?? '';
              return SizedBox(
                width: 104,
                child: Column(
                  children: [
                    SizedBox(
                      height: 148,
                      width: 104,
                      child: ClipPath(
                        clipper: const DiagonalClipper(cut: 14),
                        child: photo.isEmpty
                            ? Container(
                                color: AppColors.colorSurface,
                                child: const Icon(Icons.person_outline, color: AppColors.colorSilver),
                              )
                            : NetworkPoster(url: photo),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.eyebrow.copyWith(fontSize: 9, color: AppColors.colorSilver, letterSpacing: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'DIRECTOR  /  ${_getDirectorName(displayItem).toUpperCase()}',
          style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorTextMuted),
        ),
      ],
    );
  }

  String _getCastNames(BaseItem item) {
    if (item.castAndCrew == null || item.castAndCrew!.isEmpty) {
      return "N/A";
    }

    final castGroup = item.castAndCrew!.firstWhere(
      (group) => group.role.toLowerCase() == "cast",
      orElse: () => CastAndCrew(role: "", members: []),
    );

    if (castGroup.members.isEmpty) {
      return "N/A";
    }

    return castGroup.members.map((member) => member.name).join(", ");
  }

  String _getDirectorName(BaseItem item) {
    if (item.castAndCrew == null || item.castAndCrew!.isEmpty) {
      return "N/A";
    }

    final directorGroup = item.castAndCrew!.firstWhere(
      (group) => group.role.toLowerCase() == "director",
      orElse: () => CastAndCrew(role: "", members: []),
    );

    if (directorGroup.members.isEmpty) {
      return "N/A";
    }

    return directorGroup.members.map((member) => member.name).join(", ");
  }

  List<BaseItem> _getSuggestedSeries(BaseItem series, ContentProvider contentProvider) {
    if (series.suggestions.isEmpty) {
      return [];
    }

    final suggestedItems = <BaseItem>[];
    for (final suggestionId in series.suggestions) {
      final suggestedItem = contentProvider.getMediaById(suggestionId, MediaType.series);
      if (suggestedItem != null) {
        suggestedItems.add(suggestedItem);
      }
    }

    return suggestedItems;
  }
}
