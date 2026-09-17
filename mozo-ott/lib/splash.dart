import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mozo/constants/app_theme.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';

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
      child: Stack(
        children: [
          const Positioned.fill(child: _SplashRibbons()),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                Image.asset(
                  'assets/images/butterfly-icon.png',
                  width: 168,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                const BrandWordmark(fontSize: 36),
                const SizedBox(height: 16),
                Text(
                  'Movies. Series. Originals.\nAll in one place.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.meta.copyWith(
                    color: AppColors.colorTextSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Text(
                    'BIG STORIES\nBIGGER EMOTIONS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 11,
                      letterSpacing: 3.4,
                      fontWeight: FontWeight.w700,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashRibbons extends StatelessWidget {
  const _SplashRibbons();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -80,
            top: MediaQuery.of(context).size.height * 0.18,
            child: Transform.rotate(
              angle: -0.55,
              child: Container(
                width: 280,
                height: 420,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(180),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.colorAccent.withValues(alpha: 0.55),
                      AppColors.colorPrimaryDark.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -90,
            bottom: MediaQuery.of(context).size.height * 0.12,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 260,
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(180),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.colorPrimary.withValues(alpha: 0.5),
                      const Color(0xFF7C3AED).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
