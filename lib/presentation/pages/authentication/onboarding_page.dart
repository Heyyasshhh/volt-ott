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
    _IntroPage(
      number: '01',
      title: 'Discover',
      line: 'Find something to watch.',
      copy: 'Browse movies and series, then pick a title and start watching.',
    ),
    _IntroPage(
      number: '02',
      title: 'Watch',
      line: 'Stream in cinematic quality.',
      copy: 'Play titles in a dark, focused player built for movies and shows.',
    ),
    _IntroPage(
      number: '03',
      title: 'Your library',
      line: 'My List, downloads, and plans.',
      copy: 'Save titles, download for offline viewing, and subscribe when you are ready.',
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
        transitionDuration: const Duration(milliseconds: 480),
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
                    Image.asset(BrandAssets.logo, height: 28, fit: BoxFit.contain),
                    const Spacer(),
                    GestureDetector(
                      onTap: _finish,
                      child: Text('Skip', style: AppTextStyles.seeAll.copyWith(color: AppColors.colorTextMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ProgressDots(index: _index, total: _pages.length),
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
                      _controller.nextPage(duration: const Duration(milliseconds: 360), curve: Curves.easeOutCubic);
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

class _ProgressDots extends StatelessWidget {
  final int index;
  final int total;

  const _ProgressDots({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final on = i == index;
        return Expanded(
          child: Container(
            height: 2,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
            color: on ? AppColors.colorOrange : AppColors.colorHairline,
          ),
        );
      }),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final String number;
  final String title;
  final String line;
  final String copy;

  const _IntroPage({
    required this.number,
    required this.title,
    required this.line,
    required this.copy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 36, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: AppTextStyles.eyebrow),
          const Spacer(),
          Text(title, style: AppTextStyles.displayTitle.copyWith(fontSize: 44)),
          const SizedBox(height: 12),
          Text(line, style: AppTextStyles.editorial.copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          Text(copy, style: AppTextStyles.meta.copyWith(fontSize: 15, height: 1.55)),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
