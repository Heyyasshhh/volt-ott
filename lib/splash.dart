import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({super.key, required this.nextPage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _hasNavigated = false;
  bool _pendingNavigate = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      "assets/images/splash-video.mp4",
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
        }
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (_controller.value.isInitialized &&
        _controller.value.position >= _controller.value.duration &&
        !_hasNavigated) {
      _hasNavigated = true;
      _navigateToNextPage();
    }
  }

  void _navigateToNextPage() {
    if (!mounted) return;
    // If something was pushed on top of us (e.g. deeplink), don't replace or we'd close that page.
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
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we skipped replacement because a deeplink was on top, do it now that we're current again.
    if (_pendingNavigate && (ModalRoute.of(context)?.isCurrent ?? false)) {
      _pendingNavigate = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          _doReplacement();
        }
      });
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
