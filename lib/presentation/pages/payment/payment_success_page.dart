import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/presentation/age_popup.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/home_page.dart';
import 'package:volt/presentation/pages/payment/payment_failure_page.dart';
import 'package:volt/services/logging_service.dart';
import 'package:provider/provider.dart';

import '../../../providers/authentication_provider.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? paymentId;
  final String? productId;
  final String? referralCode;
  final String? couponCode;
  final String paymentGateway;

  const PaymentSuccessPage({
    super.key,
    required this.paymentId,
    required this.paymentGateway,
    required this.productId,
    required this.referralCode,
    this.couponCode,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authenticationProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    authenticationProvider.pollPaymentStatus(
      widget.paymentId,
      widget.paymentGateway,
      widget.referralCode,
      widget.couponCode,
      widget.productId ?? "NA",
      (user) {
        if (user.userSubscription == null) {
          showLinkedAccountDialog(context, onGotIt: () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          });
          return;
        }

        LoggingService().logPurchase(
          user.userSubscription!.planValue.toDouble(),
          currency: 'INR',
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      },
      (error) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentFailurePage(),
          ),
        );
      },
    );
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(120, 120),
                          painter: _SuccessRingPainter(),
                        ),
                        Image.asset(BrandAssets.logo, height: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('PAYMENT SUCCESSFUL', style: AppTextStyles.eyebrow),
                  const SizedBox(height: 10),
                  Text(
                    'Please wait',
                    style: AppTextStyles.displayTitle.copyWith(fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Please do not press the back button. We will redirect you shortly.',
                    style: AppTextStyles.meta,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  const EnergyProgress(value: 0.72),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      size.width * 0.46,
      Paint()
        ..color = AppColors.colorOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      c,
      size.width * 0.34,
      Paint()
        ..color = AppColors.colorAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
