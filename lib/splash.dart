import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/text.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/authentication/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({super.key, required this.nextPage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _pendingNavigate = false;
  Timer? _fallbackTimer;
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _intro.forward();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.colorBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _fallbackTimer = Timer(const Duration(milliseconds: 2400), _begin);
  }

  void _begin() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();
    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    if (!mounted) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      _pendingNavigate = true;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('volt_onboarding_seen') ?? false;
    final destination = seen ? widget.nextPage : OnboardingPage(nextPage: widget.nextPage);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 520),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingNavigate && (ModalRoute.of(context)?.isCurrent ?? false)) {
      _pendingNavigate = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          _begin();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: GestureDetector(
        onTap: _begin,
        child: AnimatedBuilder(
          animation: _intro,
          builder: (context, _) => _VoltIntro(progress: _intro.value),
        ),
      ),
    );
  }
}

class _VoltIntro extends StatelessWidget {
  final double progress;

  const _VoltIntro({required this.progress});

  @override
  Widget build(BuildContext context) {
    final logo = Curves.easeOutCubic.transform((progress / 0.7).clamp(0.0, 1.0));
    final copy = Curves.easeOut.transform(((progress - 0.45) / 0.45).clamp(0.0, 1.0));

    return AppBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: logo,
              child: Transform.scale(
                scale: 0.94 + (logo * 0.06),
                child: Image.asset(BrandAssets.logo, width: 220, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 28),
            Opacity(
              opacity: copy,
              child: Text(
                AppText.tagline,
                style: AppTextStyles.meta.copyWith(
                  color: AppColors.colorSilver,
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
