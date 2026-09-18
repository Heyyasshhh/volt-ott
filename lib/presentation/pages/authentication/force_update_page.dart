import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/platform_utils.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown when server requires a newer app version (compare by integer version code).
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key, this.releaseNotes});

  final String? releaseNotes;

  static Future<void> openStore() async {
    final uri = PlatformUtils.isAndroid
        ? Uri.parse('https://play.google.com/store/apps/details?id=app.butterflyott.app')
        : PlatformUtils.isIOS
            ? Uri.parse('https://apps.apple.com/app/id') // Replace with real App Store ID
            : null;
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReleaseNotes = releaseNotes != null && releaseNotes!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppLayout.gutter(context),
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandWordmark(fontSize: 22),
                  const SizedBox(height: 36),
                  Text('UPDATE REQUIRED', style: AppTextStyles.eyebrow),
                  const SizedBox(height: 12),
                  Text(
                    'A NEW VERSION\nIS AVAILABLE',
                    style: AppTextStyles.displayTitle.copyWith(fontSize: 44),
                  ),
                  const SizedBox(height: 14),
                  const EnergyTrail(orange: true),
                  const SizedBox(height: 18),
                  Text(
                    'A new version of the app is available. Please update to continue.',
                    style: AppTextStyles.meta.copyWith(fontSize: 15),
                  ),
                  if (hasReleaseNotes) ...[
                    const SizedBox(height: 28),
                    CustomPaint(
                      painter: const _UpdateFramePainter(),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "WHAT'S NEW",
                              style: AppTextStyles.eyebrow.copyWith(
                                color: AppColors.colorOrange,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              releaseNotes!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (!PlatformUtils.isWeb) ...[
                    const SizedBox(height: 36),
                    GradientButton(
                      label: 'Update',
                      onPressed: () => openStore(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _UpdateFramePainter extends CustomPainter {
  const _UpdateFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cut = 12.0;
    final path = Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cut)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = AppColors.colorMidnight.withValues(alpha: 0.6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF008CFF), Color(0xFFD9DDE3), Color(0xFFFF6A00)],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
