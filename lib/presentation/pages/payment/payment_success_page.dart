import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/presentation/age_popup.dart';
import 'package:butterfly/presentation/pages/home_page.dart';
import 'package:butterfly/presentation/pages/payment/payment_failure_page.dart';
import 'package:butterfly/services/logging_service.dart';
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
  void initState() {
    super.initState();
  }

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                height: 110,
                "assets/images/butterfly-text.png",
              ),
              const SizedBox(height: 50),
              const Text(
                "Confirming Your Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Please do not press back button",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "We will redirect you shortly",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
