import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/models/media/media_item.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/components/ui/content_cards.dart';
import 'package:volt/presentation/pages/drawer_pages/notifications_page.dart';
import 'package:volt/presentation/pages/payment/plans_list_page.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:volt/providers/in_app_notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/bottom_sheet/media_bottomsheet.dart';
import '../authentication/login_screen.dart';

class SectionsPageWeb extends StatefulWidget {
  final void Function(bool)? onDrawerChanged;

  const SectionsPageWeb({super.key, this.onDrawerChanged});

  @override
  State<SectionsPageWeb> createState() => _SectionsPageWebState();
}

class _SectionsPageWebState extends State<SectionsPageWeb> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int _current = 0;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final slides = Provider.of<ContentProvider>(context, listen: false).getPosters();
      if (slides.isNotEmpty) _preloadAdjacentPosters(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final inAppNotificationProvider = Provider.of<InAppNotificationProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    final slides = contentProvider.getPosters();
    BaseItem? featured;
    if (slides.isNotEmpty) {
      featured = slides[_current.clamp(0, slides.length - 1)];
    } else if (contentProvider.getMovies().isNotEmpty) {
      featured = contentProvider.getMovies().first;
    } else if (contentProvider.getSeries().isNotEmpty) {
      featured = contentProvider.getSeries().first;
    }
    final loading = contentProvider.getStatus() == Status.fetching;
    final sections = contentProvider.getSections().skip(1).toList();

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.colorBackground,
      key: _key,
      onDrawerChanged: widget.onDrawerChanged,
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
                        height: MediaQuery.sizeOf(context).height * 0.62,
                        child: Center(child: Image.asset(BrandAssets.logo, width: 180)),
                      )
                    else
                      SizedBox(
                        height: AppLayout.isDesktop(context) ? 720 : MediaQuery.sizeOf(context).height * 0.78,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: slides.isEmpty ? 1 : slides.length,
                          onPageChanged: (index) {
                            setState(() => _current = index);
                            _preloadAdjacentPosters(index);
                          },
                          itemBuilder: (context, index) {
                            final slide = slides.isEmpty ? featured! : slides[index];
                            return NowPlayingHero(
                              item: slide,
                              onPlay: () => showBottomSheetOrNavigate(context, slide),
                              media: NetworkPoster(url: bestLandscape(slide)),
                            );
                          },
                        ),
                      ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(AppLayout.gutter(context), 4, AppLayout.gutter(context), 0),
                        child: Row(
                          children: [
                            CircleIconButton(
                              icon: Icons.menu,
                              size: 40,
                              onPressed: () => _key.currentState?.openDrawer(),
                            ),
                            const SizedBox(width: 12),
                            const BrandWordmark(fontSize: 24),
                            const Spacer(),
                            if (user != null && user.userSubscription == null)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => PlansListPage()));
                                },
                                child: Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: const Text(
                                    'SUBSCRIBE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.6,
                                      color: Color(0xFF030609),
                                    ),
                                  ),
                                ),
                              ),
                            if (user == null)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
                                },
                                child: Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.colorSilver.withValues(alpha: 0.5)),
                                  ),
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.6,
                                      color: AppColors.colorSilver,
                                    ),
                                  ),
                                ),
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
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      decoration: const BoxDecoration(
                                        color: AppColors.colorOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        inAppNotificationProvider.getNotifications().length.toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF030609),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            CircleIconButton(
                              icon: Icons.ios_share_rounded,
                              size: 40,
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
                  ],
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
                      if (index >= sections.length) {
                        return const SizedBox(height: kBottomNavigationBarHeight + 50);
                      }
                      return DiscoveryRow(section: sections[index], visualIndex: index);
                    },
                    childCount: sections.length + 1,
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              '© ${DateTime.now().year} VOOVI DIGITAL PRIVATE LIMITED. All Rights Reserved. All videos and shows on this platform are trademarks of, and all related images and content are the property of, Voovi Digital. Duplication and copy of this is strictly prohibited. All rights reserved.',
              style: AppTextStyles.meta.copyWith(fontSize: 12),
              textAlign: TextAlign.left,
            ),
          ),
          const Spacer(flex: 1),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Download VOLT', style: AppTextStyles.editorial.copyWith(fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _launchUrl("https://play.google.com/store/apps/details?id=app.butterflyott.app"),
                      child: Image.asset('assets/images/google-play.webp', width: 140, height: 50),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrl("http://apps.apple.com/app/a/id"),
                      child: Image.asset('assets/images/apple.webp', width: 140, height: 50),
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
