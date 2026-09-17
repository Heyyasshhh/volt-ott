import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:butterfly/constants/app_theme.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/presentation/components/ui/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({super.key, required this.nextPage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _pendingNavigate = false;
  Timer? _fallbackTimer;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.colorBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _fallbackTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!_hasNavigated) {
        _hasNavigated = true;
        _navigateToNextPage();
      }
    });
  }

  void _navigateToNextPage() {
    if (!mounted) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      _pendingNavigate = true;
      return;
    }
    _doReplacement();
  }

  void _doReplacement() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingNavigate && (ModalRoute.of(context)?.isCurrent ?? false)) {
      _pendingNavigate = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          _doReplacement();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: const _BrandedSplash(),
      ),
    );
  }
}

class _BrandedSplash extends StatelessWidget {
  const _BrandedSplash();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/butterfly-logo.png',
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stories that\nMove You',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.meta.copyWith(
                      color: AppColors.colorTextSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Text(
                'WATCH ANYWHERE\nBE YOURSELF',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
