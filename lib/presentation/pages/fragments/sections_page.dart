import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/platform_utils.dart';
import 'package:volt/presentation/components/carousel_hero.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/components/ui/content_cards.dart';
import 'package:volt/presentation/pages/drawer_pages/notifications_page.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:volt/providers/in_app_notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../../models/media/media_item.dart';
import '../../../models/media/section.dart';
import '../../components/bottom_sheet/media_bottomsheet.dart';

class SectionsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final VoidCallback? onSearchTap;

  const SectionsPage({super.key, this.scaffoldKey, this.onSearchTap});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> with WidgetsBindingObserver, RouteAware {
  late final GlobalKey<ScaffoldState> _key;
  int _current = 0;
  int _selectedCategory = 0;
  static const _categories = ['All', 'Movies', 'Series'];
  final List<GlobalKey<CarouselHeroItemState>> heroKeys = [];
  final PageController _pageController = PageController();

  static bool _isAbsoluteImageUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  void _preloadAdjacentPosters(int currentIndex) {
    final slides = Provider.of<ContentProvider>(context, listen: false).getPosters();
    if (slides.isEmpty) return;
    if (currentIndex > 0) {
      final url = slides[currentIndex - 1].getFeaturedPosterUrl();
      if (_isAbsoluteImageUrl(url)) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
    if (currentIndex < slides.length - 1) {
      final url = slides[currentIndex + 1].getFeaturedPosterUrl();
      if (_isAbsoluteImageUrl(url)) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _key = widget.scaffoldKey ?? GlobalKey<ScaffoldState>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final slides = Provider.of<ContentProvider>(context, listen: false).getPosters();
      if (slides.isNotEmpty) _preloadAdjacentPosters(0);
    });
  }

  void _pauseAllTrailers() {
    for (final key in heroKeys) {
      key.currentState?.pause();
    }
  }

  @override
  void didPushNext() {
    _pauseAllTrailers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _pauseAllTrailers();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseAllTrailers();
    routeObserver.unsubscribe(this);
    _pageController.dispose();
    super.dispose();
  }

  bool _matchesCategory(BaseItem item) {
    switch (_selectedCategory) {
      case 1:
        return item.mediaType == MediaType.movie;
      case 2:
        return item.mediaType == MediaType.series;
      default:
        return true;
    }
  }

  List<Section> _filteredSections(ContentProvider contentProvider) {
    final sections = contentProvider.getSections().skip(1);
    if (_selectedCategory == 0) return sections.toList();
    return sections
        .map((section) {
          final items = section.baseItems.where(_matchesCategory).toList();
          return section.copyWith(baseItems: items);
        })
        .where((section) => section.baseItems.isNotEmpty)
        .toList();
  }

  void _openSlide(BuildContext context, BaseItem slide) {
    final isExternal = slide.mediaType == MediaType.external &&
        slide.externalUrl != null &&
        slide.externalUrl!.trim().isNotEmpty;
    if (isExternal || !slide.autoPlayTrailer) {
      showBottomSheetOrNavigate(context, slide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final inAppNotificationProvider = Provider.of<InAppNotificationProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    final slides = contentProvider.getPosters();
    if (heroKeys.length != slides.length) {
      heroKeys
        ..clear()
        ..addAll(List.generate(slides.length, (_) => GlobalKey<CarouselHeroItemState>()));
    }
    BaseItem? featured;
    if (slides.isNotEmpty) {
      featured = slides[_current.clamp(0, slides.length - 1)];
    } else if (contentProvider.getMovies().isNotEmpty) {
      featured = contentProvider.getMovies().first;
    } else if (contentProvider.getSeries().isNotEmpty) {
      featured = contentProvider.getSeries().first;
    }
    final loading = contentProvider.getStatus() == Status.fetching;

    return Scaffold(
      key: _key,
      backgroundColor: AppColors.colorBackground,
      extendBody: true,
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<ContentProvider>(context, listen: false).init();
            if (mounted) {
              setState(() => _current = 0);
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            }
          },
          color: AppColors.colorOrange,
          backgroundColor: AppColors.colorBackground,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    if (loading || featured == null)
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.68,
                        child: Center(child: Image.asset(BrandAssets.logo, width: 180)),
                      )
                    else
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.78,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: slides.isEmpty ? 1 : slides.length,
                          onPageChanged: (index) {
                            _pauseAllTrailers();
                            setState(() => _current = index);
                            _preloadAdjacentPosters(index);
                          },
                          itemBuilder: (context, index) {
                            final slide = slides.isEmpty ? featured! : slides[index];
                            return NowPlayingHero(
                              item: slide,
                              onPlay: () => _openSlide(context, slide),
                              media: slides.isEmpty
                                  ? null
                                  : CarouselHeroItem(
                                      key: heroKeys.length > index ? heroKeys[index] : ValueKey('slide_$index'),
                                      slide: slide,
                                      user: user,
                                      aspectRatio: 9 / 16,
                                      isActive: _current == index,
                                      onTap: () => _openSlide(context, slide),
                                    ),
                            );
                          },
                        ),
                      ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(AppLayout.gutter(context), 4, AppLayout.gutter(context), 0),
                        child: Row(
                          children: [
                            const BrandWordmark(fontSize: 28),
                            const Spacer(),
                            CircleIconButton(
                              icon: Icons.search_rounded,
                              size: 40,
                              onPressed: widget.onSearchTap ?? () {},
                            ),
                            const SizedBox(width: 8),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleIconButton(
                                  icon: Icons.notifications_none_rounded,
                                  size: 40,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => NotificationsPage()),
                                    );
                                  },
                                ),
                                if (inAppNotificationProvider.getNotifications().isNotEmpty)
                                  const Positioned(
                                    right: 6,
                                    top: 6,
                                    child: SizedBox(
                                      width: 8,
                                      height: 8,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(color: AppColors.colorOrange, shape: BoxShape.circle),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: CategoryChipBar(
                    labels: _categories,
                    selectedIndex: _selectedCategory,
                    onSelected: (index) => setState(() => _selectedCategory = index),
                  ),
                ),
              ),
              if (loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator(color: AppColors.colorAccent)),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sections = _filteredSections(contentProvider);
                      if (index >= sections.length) {
                        return Column(
                          children: [
                            const SizedBox(height: 28),
                            if (PlatformUtils.isWeb) const FooterWithBadges(),
                            const SizedBox(height: 120),
                          ],
                        );
                      }
                      return DiscoveryRow(section: sections[index], visualIndex: index);
                    },
                    childCount: _filteredSections(contentProvider).length + 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FooterWithBadges extends StatelessWidget {
  const FooterWithBadges({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const LightningDivider(),
          const SizedBox(height: 16),
          Text('Download VOLT', style: AppTextStyles.editorial.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _launchUrl("https://play.google.com/store/apps/details?id=app.butterflyott.app"),
                child: Image.asset('assets/images/google-play.webp', width: 140, height: 50),
              ),
              GestureDetector(
                onTap: () => _launchUrl("http://apps.apple.com/app/"),
                child: Image.asset('assets/images/apple.webp', width: 140, height: 50),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} VOOVI DIGITAL PRIVATE LIMITED. All Rights Reserved.',
            textAlign: TextAlign.center,
            style: AppTextStyles.meta.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
