import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chill/constants/colors.dart';
import 'package:chill/platform_utils.dart';
import 'package:chill/presentation/components/media/media_tile.dart';
import 'package:chill/presentation/pages/drawer_pages/notifications_page.dart';
import 'package:chill/providers/content_provider.dart';
import 'package:chill/providers/in_app_notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../main.dart';
import '../../../models/media/media_item.dart';
import '../../../providers/authentication_provider.dart';
import '../../components/bottom_sheet/media_bottomsheet.dart';
import '../../components/carousel_hero.dart';

class SectionsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const SectionsPage({super.key, this.scaffoldKey});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

double _getAspectRatio(BuildContext context) {
  return 1.0; // Square aspect ratio for all screen sizes
}

double _getViewportFraction(BuildContext context) {
  return 1;
}

class _SectionsPageState extends State<SectionsPage> with WidgetsBindingObserver, RouteAware {
  int dotPosition = 0;
  late final GlobalKey<ScaffoldState> _key;
  int _current = 0;
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

  Widget _buildDots({
    required int count,
    required int current,
    required void Function(int index) onTapDot,
  }) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == current;
        return GestureDetector(
          onTap: () => onTapDot(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: active ? AppColors.colorPrimary : Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final inAppNotificationProvider = Provider.of<InAppNotificationProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    final double appBarHeight = kToolbarHeight;

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
      body: SafeArea(
        child: Stack(
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
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: contentProvider.getStatus() == Status.fetching
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: appBarHeight),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                initialPage: 0,
                                aspectRatio: _getAspectRatio(context),
                                viewportFraction: _getViewportFraction(context),
                                enlargeCenterPage: false,
                                autoPlay: false,
                              ),
                              items: [1].map((_) {
                                return Builder(
                                  builder: (context) {
                                    return AspectRatio(
                                      aspectRatio: _getAspectRatio(context),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: const Color(0xFF1F1F1F),
                                            highlightColor: Colors.grey[800]!,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1F1F1F),
                                                borderRadius: BorderRadius.circular(16.0),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Image.asset(
                                              "assets/images/chill-text.png",
                                              width: 200,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 12),
                          const ShimmerTile(),
                          const ShimmerTile(),
                          const ShimmerTileHorizontal(),
                          const ShimmerTile(),
                          const SizedBox(height: 20),
                        ],
                      )
                    : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: appBarHeight),
                  if (contentProvider.getPosters().isEmpty && (contentProvider.getMovies().isEmpty || contentProvider.getSeries().isEmpty)) const SizedBox(height: 10),
                  if (contentProvider.getPosters().isEmpty && (contentProvider.getMovies().isEmpty || contentProvider.getSeries().isEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          initialPage: 0,
                          aspectRatio: _getAspectRatio(context),
                          viewportFraction: _getViewportFraction(context),
                          enlargeCenterPage: false,
                          autoPlay: false,
                          autoPlayInterval: const Duration(seconds: 7),
                        ),
                        items: [1].map((slide) {
                          return Builder(
                            builder: (BuildContext context) {
                              return AspectRatio(
                                aspectRatio: _getAspectRatio(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F1F1F),
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      "assets/images/chill-text.png",
                                      width: 200,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    )
                  else if (contentProvider.getPosters().isEmpty)
                    Container()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          initialPage: 0,
                          aspectRatio: _getAspectRatio(context),
                          viewportFraction: _getViewportFraction(context),
                          enlargeCenterPage: true,
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
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CarouselHeroItem(
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
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12),
                      _buildDots(
                        count: contentProvider.getPosters().length,
                        current: _current,
                        onTapDot: (i) {
                          _carouselController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                  if (contentProvider.getMovies().isEmpty && contentProvider.getSeries().isEmpty)
                    const Column(children: [
                      ShimmerTile(),
                      ShimmerTile(),
                      ShimmerTileHorizontal(),
                      ShimmerTile(),
                    ])
                  else
                    Column(
                      children: contentProvider.getSections().skip(1).map((section) {
                        return Container(
                          margin: EdgeInsets.only(top: 8),
                          child: MediaTile(section),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 20),
                  if (PlatformUtils.isWeb) FooterWithBadges(),
                ],
              ),
            ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: Container(
                  height: appBarHeight,
                  color: AppColors.colorBackground.withValues(alpha: 1),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    foregroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    centerTitle: false,
                    toolbarHeight: appBarHeight,
                    leading: Container(
                      margin: const EdgeInsets.only(left: 13.0),
                      child: Image.asset(
                        "assets/images/chill-text.png",
                      ),
                    ),
                    leadingWidth: 80,
                    actions: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.solidBell, color: AppColors.colorPrimary, size: 26),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => NotificationsPage()),
                              );
                            },
                          ),
                          if (inAppNotificationProvider.getNotifications().isNotEmpty)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  inAppNotificationProvider.getNotifications().length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/icons/share.svg',
                          width: 26,
                          height: 26,
                          colorFilter: ColorFilter.mode(
                            AppColors.colorPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () {
                          Share.share(
                            contentProvider.getShareUrl(),
                            subject: contentProvider.getShareText(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                  'Download Chill Apps',
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
                        "https://play.google.com/store/apps/details?id=com.chill.entertainment",
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
