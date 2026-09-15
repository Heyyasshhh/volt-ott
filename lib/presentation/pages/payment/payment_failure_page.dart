import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/presentation/pages/drawer_pages/contact_us_page.dart';
import 'package:butterfly/services/logging_service.dart';

import '../../components/controls/buttons.dart';
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                height: 130,
                "assets/images/butterfly-text.png",
              ),
              const SizedBox(height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Your payment failed, if any money was deducted from your account it will soon be refunded, please contact support for more info",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),
              SubmitButton(
                buttonText: 'Contact Support',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactUsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              SubmitButton(
                buttonText: 'Back to home',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
