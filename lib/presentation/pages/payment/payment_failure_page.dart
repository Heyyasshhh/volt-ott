import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/drawer_pages/contact_us_page.dart';
import 'package:volt/services/logging_service.dart';

import '../home_page.dart';

class PaymentFailurePage extends StatefulWidget {
  const PaymentFailurePage({super.key});

  @override
  State<PaymentFailurePage> createState() => _PaymentFailurePageState();
}

class _PaymentFailurePageState extends State<PaymentFailurePage> {
  @override
  void initState() {
    LoggingService().logEvent('checkout_failure');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(96, 96),
                  painter: _FailureBoltPainter(),
                ),
                const SizedBox(height: 28),
                const Text('PAYMENT FAILED', style: AppTextStyles.eyebrow),
                const SizedBox(height: 10),
                Text(
                  'Payment failed',
                  style: AppTextStyles.displayTitle.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'If any money was deducted from your account it will be refunded. Please contact support if you need help.',
                  style: AppTextStyles.meta,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Contact Support',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Back to home',
                    style: TextStyle(
                      color: AppColors.colorSilver,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FailureBoltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      size.width * 0.46,
      Paint()
        ..color = Colors.redAccent.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final path = Path()
      ..moveTo(size.width * 0.58, 14)
      ..lineTo(size.width * 0.32, size.height * 0.48)
      ..lineTo(size.width * 0.5, size.height * 0.48)
      ..lineTo(size.width * 0.4, size.height - 14)
      ..lineTo(size.width * 0.72, size.height * 0.42)
      ..lineTo(size.width * 0.52, size.height * 0.42)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.colorOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
