import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/authentication/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({super.key, required this.nextPage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _pendingNavigate = false;
  Timer? _fallbackTimer;
  late final AnimationController _master;
  late final AnimationController _sheen;

  @override
  void initState() {
    super.initState();
    _master = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));
    _sheen = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _master.forward();
    Future<void>.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) _sheen.forward();
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.colorBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _fallbackTimer = Timer(const Duration(milliseconds: 4600), _begin);
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
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _master.dispose();
    _sheen.dispose();
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
          animation: Listenable.merge([_master, _sheen]),
          builder: (context, _) => _VoltReveal(progress: _master.value, sheen: _sheen.value),
        ),
      ),
    );
  }
}

class _VoltReveal extends StatelessWidget {
  final double progress;
  final double sheen;

  const _VoltReveal({required this.progress, required this.sheen});

  @override
  Widget build(BuildContext context) {
    final line = Interval(0.0, 0.28, curve: Curves.easeInOut).transform(progress);
    final bolt = Interval(0.22, 0.48, curve: Curves.easeOutCubic).transform(progress);
    final logo = Interval(0.42, 0.72, curve: Curves.easeOut).transform(progress);
    final frame = Interval(0.62, 0.88, curve: Curves.easeOut).transform(progress);
    final copy = Interval(0.78, 1.0, curve: Curves.easeOut).transform(progress);

    return AppBackground(
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _LightningPathPainter(line: line, bolt: bolt),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: logo,
                  child: Transform.scale(
                    scale: 0.86 + (logo * 0.14),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(BrandAssets.logo, width: 280, fit: BoxFit.contain),
                        if (sheen > 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Transform.translate(
                                offset: Offset((sheen - 0.5) * 220, 0),
                                child: Container(
                                  width: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0),
                                        Colors.white.withValues(alpha: 0.22),
                                        Colors.white.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Opacity(
                  opacity: copy,
                  child: Column(
                    children: [
                      Text('VOLT OTT', style: AppTextStyles.chrome.copyWith(letterSpacing: 6, fontSize: 14)),
                      const SizedBox(height: 10),
                      Text('ENTERTAINMENT AT FULL POWER', style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: frame,
            child: CustomPaint(size: Size.infinite, painter: _CinematicFramePainter(frame)),
          ),
        ],
      ),
    );
  }
}

class _LightningPathPainter extends CustomPainter {
  final double line;
  final double bolt;

  _LightningPathPainter({required this.line, required this.bolt});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.46;
    final blue = Paint()
      ..color = AppColors.colorElectric.withValues(alpha: 0.9)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width * line, y), blue);

    if (bolt > 0) {
      final cx = size.width / 2;
      final path = Path()
        ..moveTo(cx - 36, y - 70 * bolt)
        ..lineTo(cx - 8, y - 8)
        ..lineTo(cx + 6, y - 8)
        ..lineTo(cx + 18, y + 70 * bolt)
        ..lineTo(cx - 2, y + 10)
        ..lineTo(cx - 16, y + 10)
        ..close();
      final orange = Paint()
        ..shader = AppColors.primaryGradient.createShader(Rect.fromCenter(center: Offset(cx, y), width: 90, height: 180))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawPath(path, orange);
      canvas.drawCircle(Offset(cx, y), 4 + (bolt * 6), Paint()..color = AppColors.colorElectric.withValues(alpha: 0.5 * bolt));
    }
  }

  @override
  bool shouldRepaint(covariant _LightningPathPainter oldDelegate) =>
      oldDelegate.line != line || oldDelegate.bolt != bolt;
}

class _CinematicFramePainter extends CustomPainter {
  final double t;
  _CinematicFramePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.colorAccent.withValues(alpha: 0.55 * t),
          AppColors.colorOrange.withValues(alpha: 0.4 * t),
          AppColors.colorAccent.withValues(alpha: 0.55 * t),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final inset = 18.0 + (1 - t) * 40;
    canvas.drawRect(Rect.fromLTWH(inset, inset * 1.6, size.width - inset * 2, size.height - inset * 3.2), paint);
  }

  @override
  bool shouldRepaint(covariant _CinematicFramePainter oldDelegate) =>       oldDelegate.t != t;
}
