import 'dart:async';

import 'package:flutter/material.dart';
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
        child: Column(
          children: [
            const Spacer(flex: 3),
            Image.asset(
              'assets/images/butterfly-logo.png',
              width: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
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
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
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
