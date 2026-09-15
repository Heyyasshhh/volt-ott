import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chill/constants/text.dart';
import 'package:chill/providers/authentication_provider.dart';
import 'package:chill/services/notification_service.dart';
import 'package:chill/presentation/pages/home_page.dart';

import '../main.dart';
import '../platform_utils.dart';
import '../screen_recording_detector.dart';
import '../splash.dart';

final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  final Widget? nextPage;

  const MainApp({super.key, this.nextPage});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!PlatformUtils.isWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
        NotificationService().startTokenRefreshListener(() async => authProvider.getUser());
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryConsumePendingNotification();
    }
  }

  void _tryConsumePendingNotification() {
    if (NotificationService().getPendingPayload() == null) return;
    final overlay = mainNavigatorKey.currentState?.overlay;
    final context = overlay?.context;
    if (context != null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          await NotificationService().tryConsume(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget startPage = widget.nextPage ?? const HomePage();
    final Widget splashScreen = SplashScreen(nextPage: startPage);

    return MaterialApp(
      navigatorKey: mainNavigatorKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Mulish',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      title: AppText.appName,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (PlatformUtils.isIOS) const ScreenRecordingBlocker(),
          ],
        );
      },
      home: splashScreen,
    );
  }
}
