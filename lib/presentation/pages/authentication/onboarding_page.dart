import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';

class OnboardingPage extends StatefulWidget {
  final Widget nextPage;

  const OnboardingPage({super.key, required this.nextPage});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _PowerPage(
      number: '01',
      title: 'DISCOVER',
      line: 'Find something to watch.',
      copy: 'Browse movies and series, then pick a title and start watching.',
    ),
    _PowerPage(
      number: '02',
      title: 'WATCH',
      line: 'Stream in cinematic quality.',
      copy: 'Play titles in a dark, focused player built for movies and shows.',
    ),
    _PowerPage(
      number: '03',
      title: 'EXPERIENCE',
      line: 'Your list, downloads, and plans.',
      copy: 'Save titles, download for offline, and subscribe when you are ready.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('volt_onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextPage,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppLayout.gutter(context), 12, AppLayout.gutter(context), 24),
            child: Column(
              children: [
                Row(
                  children: [
                    const BrandWordmark(fontSize: 22),
                    const Spacer(),
                    GestureDetector(
                      onTap: _finish,
                      child: Text('SKIP', style: AppTextStyles.seeAll.copyWith(color: AppColors.colorTextMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _PowerLine(index: _index),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) => _pages[index],
                  ),
                ),
                GradientButton(
                  label: _index == _pages.length - 1 ? 'Get Started' : 'Continue',
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PowerLine extends StatelessWidget {
  final int index;

  const _PowerLine({required this.index});

  @override
  Widget build(BuildContext context) {
    const stages = ['DISCOVER', 'WATCH', 'EXPERIENCE'];
    return Row(
      children: List.generate(stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          final active = index >= (i ~/ 2) + 1;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                gradient: active ? AppColors.premiumGradient : null,
                color: active ? null : AppColors.colorHairline,
              ),
            ),
          );
        }
        final stage = i ~/ 2;
        final on = index >= stage;
        return Text(
          stages[stage],
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w800,
            color: on ? (stage == index ? AppColors.colorOrange : AppColors.colorElectric) : AppColors.colorTextMuted,
          ),
        );
      }),
    );
  }
}

class _PowerPage extends StatelessWidget {
  final String number;
  final String title;
  final String line;
  final String copy;

  const _PowerPage({
    required this.number,
    required this.title,
    required this.line,
    required this.copy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _OnboardPainter(title.hashCode)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(number, style: AppTextStyles.eyebrow),
                    const Spacer(),
                    Text(title, style: AppTextStyles.displayTitle.copyWith(fontSize: 56)),
                    const SizedBox(height: 12),
                    const LightningDivider(),
                    const SizedBox(height: 16),
                    Text(line, style: AppTextStyles.editorial.copyWith(fontSize: 22, color: AppColors.colorSilver)),
                    const SizedBox(height: 14),
                    Text(copy, style: AppTextStyles.meta.copyWith(fontSize: 15, height: 1.55)),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardPainter extends CustomPainter {
  final int seed;
  _OnboardPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final orange = Paint()
      ..color = AppColors.colorOrange.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final blue = Paint()
      ..color = AppColors.colorAccent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 6; i++) {
      final y = 40.0 + i * 48 + (seed % 7);
      canvas.drawLine(Offset(0, y), Offset(size.width * (0.4 + (i % 3) * 0.15), y + 18), i.isEven ? orange : blue);
    }
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.22), 70, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
