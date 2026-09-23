import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/platform_utils.dart';
import 'package:volt/presentation/pages/fragments/search_page.dart';
import 'package:volt/presentation/pages/fragments/sections_page.dart';
import 'package:volt/presentation/pages/fragments/my_list_page.dart';
import 'package:volt/presentation/pages/media/downloads_page.dart';
import 'package:volt/presentation/pages/drawer_pages/profile_page.dart';
import 'package:volt/presentation/components/notification_permission_modal.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:volt/providers/home_page_provider.dart';
import 'package:volt/services/notification_service.dart';
import 'package:provider/provider.dart';

import 'fragments/sections_page_web.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _homeSectionsPageKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _isDrawerOpen = false;
  String? firstReelId;

  @override
  void initState() {
    super.initState();
    if (PlatformUtils.isIOS) {
      requestTrackingPermission();
    } else {
      FacebookAppEvents().setAdvertiserTracking(enabled: true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await NotificationService().tryConsume(context);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        await NotificationPermissionModal.showIfNeeded(context);
      }
    });
  }

  Future<void> requestTrackingPermission() async {
    final status = await AppTrackingTransparency.requestTrackingAuthorization();

    if (status == TrackingStatus.authorized) {
      FacebookAppEvents().setAdvertiserTracking(enabled: true);
    } else if (status == TrackingStatus.denied) {
      FacebookAppEvents().setAdvertiserTracking(enabled: false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deepLinkProvider = Provider.of<HomePageProvider>(context);
    if (deepLinkProvider.firstReelId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          firstReelId = deepLinkProvider.firstReelId;
          _currentIndex = 3;
        });
        deepLinkProvider.redirectToReels(null);
      });
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

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    precacheImage(const AssetImage(BrandAssets.logo), context);
    for (var movie in contentProvider.getMovies()) {
      if (_isAbsoluteImageUrl(movie.verticalPosterUrl)) {
        precacheImage(CachedNetworkImageProvider(movie.verticalPosterUrl), context);
      }
    }
    for (var series in contentProvider.getSeries()) {
      if (_isAbsoluteImageUrl(series.verticalPosterUrl)) {
        precacheImage(CachedNetworkImageProvider(series.verticalPosterUrl), context);
      }
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (_currentIndex == 0) {
          if (_scaffoldKey.currentState != null) {
            if (_scaffoldKey.currentState!.isEndDrawerOpen) {
              _scaffoldKey.currentState!.closeEndDrawer();
              return;
            }
          }
          final shouldExit = await showDialog<bool>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.72),
            builder: (context) {
              return GlassDialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.exit_to_app_rounded, color: AppColors.colorOrange, size: 28),
                    const SizedBox(height: 18),
                    Text('Exit App?', style: AppTextStyles.displayTitle.copyWith(fontSize: 26)),
                    const SizedBox(height: 10),
                    Text(
                      'Are you sure you want to leave?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.meta,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: MetallicButton(
                              label: 'Stay',
                              onPressed: () => Navigator.pop(context, false),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            label: 'Exit',
                            height: 48,
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
          if (shouldExit ?? false) {
            SystemNavigator.pop(animated: true);
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        backgroundColor: AppColors.colorBackground,
        bottomNavigationBar: AnimatedSlide(
          offset: _isDrawerOpen ? const Offset(0, 1) : Offset.zero,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _isDrawerOpen ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: VoltBottomNav(
              currentIndex: _currentIndex,
              showDownloads: !kIsWeb,
              onTap: (idx) => setState(() => _currentIndex = idx),
            ),
          ),
        ),
        body: IndexedStack(
          index: _currentIndex.clamp(0, kIsWeb ? 3 : 4),
          children: [
            if (kIsWeb)
              SectionsPageWeb(
                onDrawerChanged: (isOpen) {
                  setState(() {
                    _isDrawerOpen = isOpen;
                  });
                },
              ),
            if (!kIsWeb)
              SectionsPage(
                scaffoldKey: _homeSectionsPageKey,
                onSearchTap: () => setState(() => _currentIndex = 1),
              ),
            const SearchPage(),
            const MyListPage(),
            if (!kIsWeb) const DownloadsPage(),
            const ProfilePage(),
          ],
        ),
      ),
    );
  }
}
