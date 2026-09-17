import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/platform_utils.dart';
import 'package:mozo/presentation/components/media/media_tile.dart';
import 'package:mozo/presentation/pages/drawer_pages/notifications_page.dart';
import 'package:mozo/presentation/pages/drawer_pages/profile_page.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';
import 'package:mozo/providers/content_provider.dart';
import 'package:mozo/providers/in_app_notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';
import '../../../models/media/media_item.dart';
import '../../../models/media/section.dart';
import '../../../providers/authentication_provider.dart';
import '../../components/bottom_sheet/media_bottomsheet.dart';
import '../../components/carousel_hero.dart';

class SectionsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final VoidCallback? onSearchTap;

  const SectionsPage({super.key, this.scaffoldKey, this.onSearchTap});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

double _heroHeight(BuildContext context) {
  return MediaQuery.of(context).size.height * 0.62;
}

double _getAspectRatio(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width / _heroHeight(context);
}

class _SectionsPageState extends State<SectionsPage> with WidgetsBindingObserver, RouteAware {
  int dotPosition = 0;
  late final GlobalKey<ScaffoldState> _key;
  int _current = 0;
  int _selectedCategory = 0;
  static const _categories = ['All', 'Movies', 'Series', 'Kids', 'Documentaries'];
  final List<GlobalKey<CarouselHeroItemState>> heroKeys = [];

  final CarouselSliderController _carouselController = CarouselSliderController();
  bool _isAutoPlayEnabled = false;

  void _applyAutoPlayForIndex(int index) {
    final slides = Provider.of<ContentProvider>(context, listen: false).getPosters();
    final bool isTrailer = index >= 0 && index < slides.length && slides[index].autoPlayTrailer;

    if (isTrailer && _isAutoPlayEnabled) {
      setState(() => _isAutoPlayEnabled = false);
    } else if (!isTrailer && !_isAutoPlayEnabled) {
      setState(() => _isAutoPlayEnabled = true);
    }
  }

  static bool _isAbsoluteImageUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  void _preloadAdjacentPosters(int currentIndex) {
    final slides = Provider.of<ContentProvider>(context, listen: false).getPosters();
    if (slides.isEmpty) return;

    // Preload left poster
    if (currentIndex > 0) {
      final leftSlide = slides[currentIndex - 1];
      final url = leftSlide.getFeaturedPosterUrl();
      if (_isAbsoluteImageUrl(url)) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }

    // Preload right poster
    if (currentIndex < slides.length - 1) {
      final rightSlide = slides[currentIndex + 1];
      final url = rightSlide.getFeaturedPosterUrl();
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
      if (slides.isNotEmpty) {
        _applyAutoPlayForIndex(0);
        _preloadAdjacentPosters(0);
      }
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
    super.dispose();
  }

  bool _matchesCategory(BaseItem item) {
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

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.colorBackground,
      key: _key,
      body: Stack(
        children: [
          RefreshIndicator(
              onRefresh: () async {
                await Provider.of<ContentProvider>(context, listen: false).init();
                if (mounted) {
                  setState(() => _current = 0);
                  _carouselController.jumpToPage(0);
                }
              },
              color: AppColors.colorPrimary,
              backgroundColor: AppColors.colorBackground,
              edgeOffset: 80,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: contentProvider.getStatus() == Status.fetching
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: _heroHeight(context),
                            child: Container(color: AppColors.colorSurface),
                          ),
                          const ShimmerTile(),
                          const ShimmerTile(),
                          const ShimmerTileHorizontal(),
                          const ShimmerTile(),
                          const SizedBox(height: 20),
                        ],
                      )
                    : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (contentProvider.getPosters().isEmpty && (contentProvider.getMovies().isEmpty || contentProvider.getSeries().isEmpty))
                    SizedBox(
                      height: _heroHeight(context),
                      width: double.infinity,
                      child: Container(
                        color: AppColors.colorSurface,
                        child: Center(
                          child: Image.asset(
                            "assets/images/butterfly-text.png",
                            width: 200,
                          ),
                        ),
                      ),
                    )
                  else if (contentProvider.getPosters().isEmpty)
                    Container()
                  else
                    SizedBox(
                      height: _heroHeight(context),
                      width: double.infinity,
                      child: CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          initialPage: 0,
                          height: _heroHeight(context),
                          viewportFraction: 1,
                          enlargeCenterPage: false,
                          autoPlay: _isAutoPlayEnabled,
                          autoPlayInterval: const Duration(seconds: 7),
                          onPageChanged: (index, reason) {
                            _pauseAllTrailers();
                            setState(() => _current = index);
                            _applyAutoPlayForIndex(index);
                            _preloadAdjacentPosters(index);
                          },
                        ),
                        items: contentProvider.getPosters().asMap().entries.map((entry) {
                          final index = entry.key;
                          final slide = entry.value;
                          return Builder(
                            builder: (context) {
                              return CarouselHeroItem(
                                key: ValueKey("slide_$index"),
                                slide: slide,
                                user: user,
                                aspectRatio: _getAspectRatio(context),
                                isActive: _current == index,
                                onTap: () {
                                  final isExternal = slide.mediaType == MediaType.external &&
                                      slide.externalUrl != null &&
                                      slide.externalUrl!.trim().isNotEmpty;
                                  if (isExternal || !slide.autoPlayTrailer) {
                                    showBottomSheetOrNavigate(context, slide);
                                  }
                                },
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (contentProvider.getMovies().isEmpty && contentProvider.getSeries().isEmpty)
                    const Column(children: [
                      ShimmerTile(),
                      ShimmerTile(),
                      ShimmerTileHorizontal(),
                      ShimmerTile(),
                    ])
                  else
                    Column(
                      children: _filteredSections(contentProvider).map((section) {
                        return Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: MediaTile(section),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 112),
                  if (PlatformUtils.isWeb) const FooterWithBadges(),
                ],
              ),
            ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 12, 8),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/butterfly-icon.png',
                              height: 32,
                            ),
                            const SizedBox(width: 8),
                            const BrandWordmark(fontSize: 20),
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
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.colorPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/butterfly-icon.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CategoryChipBar(
                        labels: _categories,
                        selectedIndex: _selectedCategory,
                        onSelected: (index) => setState(() => _selectedCategory = index),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Copyright Text
          Flexible(
            flex: 2,
            child: Text(
              '© 2025 VOOVI DIGITAL PRIVATE LIMITED. All Rights Reserved. All videos and shows on this platform are trademarks of, and all related images and content are the property of, Voovi Digital. Duplication and copy of this is strictly prohibited. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey[300]),
              textAlign: TextAlign.left,
            ),
          ),

          // CENTER: Empty space
          const Spacer(flex: 1),

          // RIGHT: App download section
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Download Mozo Apps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _launchUrl(
                        "https://play.google.com/store/apps/details?id=app.mozoott.app",
                      ),
                      child: Image.asset(
                        'assets/images/google-play.webp',
                        width: 140,
                        height: 50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrl("http://apps.apple.com/app/"),
                      child: Image.asset(
                        'assets/images/apple.webp',
                        width: 140,
                        height: 50,
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
