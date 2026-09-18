import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/presentation/pages/authentication/login_screen.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/subscription_plan.dart';
import '../payment_option.dart';
import '../ui/app_widgets.dart';

class PaymentBottomSheetWidget extends StatefulWidget {
  final SubscriptionPlan plan;
  final Set<String> enabledMethods;
  final Function(String) onMethodSelection;

  const PaymentBottomSheetWidget({
    super.key,
    required this.plan,
    required this.onMethodSelection,
    required this.enabledMethods,
  });

  @override
  State<PaymentBottomSheetWidget> createState() =>
      _PaymentBottomSheetWidgetState();
}

class _PaymentBottomSheetWidgetState extends State<PaymentBottomSheetWidget> {
  String _categoryFor(String method) {
    switch (method) {
      case 'juspay':
      case 'razorpay':
      case 'cashfree':
        return 'UPI';
      case 'stripe':
        return 'CARD';
      default:
        return 'OTHER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
      return Container();
    }

    // Map of available payment options
    final Map<String, Widget Function()> paymentOptions = {
      'juspay': () => PaymentOption(
            imagePath: "assets/images/volt-logo.png",
            methodName: "Pay Via UPI / Cards / Wallet",
            methods: Row(
              children: [
                Image(
                  image: AssetImage('assets/images/gpay.png'),
                  height: 20,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/phonepe.png',
                  height: 25,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/bhim.png',
                  height: 25,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/visa.png',
                  color: Colors.white,
                  height: 20,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/mastercard.png',
                  height: 20,
                ),
                SizedBox(width: 3),
              ],
            ),
            onTap: () async {
              Navigator.pop(context);
              widget.onMethodSelection("juspay");
            },
          ),
      'razorpay': () => PaymentOption(
        imagePath: "assets/images/razorpay.png",
        methodName: "Pay Via Razorpay",
        methods: Row(
          children: [
            Image(
              image: AssetImage('assets/images/gpay.png'),
              height: 20,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/phonepe.png',
              height: 25,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/bhim.png',
              height: 25,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/visa.png',
              color: Colors.white,
              height: 20,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/mastercard.png',
              height: 20,
            ),
            SizedBox(width: 3),
          ],
        ),
        onTap: () async {
          Navigator.pop(context);
          widget.onMethodSelection("razorpay");
        },
      ),
      'cashfree': () => PaymentOption(
        imagePath: "assets/images/volt-logo.png",
        methodName: "Pay Via Cashfree",
        methods: Row(
          children: [
            Image(
              image: AssetImage('assets/images/gpay.png'),
              height: 20,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/phonepe.png',
              height: 25,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/bhim.png',
              height: 25,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/visa.png',
              color: Colors.white,
              height: 20,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/mastercard.png',
              height: 20,
            ),
            SizedBox(width: 3),
          ],
        ),
        onTap: () async {
          Navigator.pop(context);
          widget.onMethodSelection("cashfree");
        },
      ),
      'sabpaisa': () => PaymentOption(
        imagePath: "assets/images/sabpaisa.png",
        methodName: "Pay Via Sabpaisa",
        methods: Row(
          children: [
            Image(
              image: AssetImage('assets/images/gpay.png'),
              height: 20,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/phonepe.png',
              height: 25,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/bhim.png',
              height: 25,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/visa.png',
              color: Colors.white,
              height: 20,
            ),
            SizedBox(width: 3),
            Image.asset(
              'assets/images/mastercard.png',
              height: 20,
            ),
            SizedBox(width: 3),
          ],
        ),
        onTap: () async {
          Navigator.pop(context);
          widget.onMethodSelection("sabpaisa");
        },
      ),
      'payu': () => PaymentOption(
            imagePath: "assets/images/payu.png",
            methodName: "Pay Via Payu",
            methods: Row(
              children: [
                Image(
                  image: AssetImage('assets/images/gpay.png'),
                  height: 20,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/phonepe.png',
                  height: 25,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/bhim.png',
                  height: 25,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/visa.png',
                  color: Colors.white,
                  height: 20,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/mastercard.png',
                  height: 20,
                ),
                SizedBox(width: 3),
              ],
            ),
            onTap: () async {
              Navigator.pop(context);
              widget.onMethodSelection("payu");
            },
          ),
      'stripe': () => PaymentOption(
            imagePath: "assets/images/stripe.png",
            methodName: "Pay Via Stripe",
            methods: Row(
              children: [
                Image(
                  image: AssetImage('assets/images/gpay.png'),
                  height: 20,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/phonepe.png',
                  height: 25,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/bhim.png',
                  height: 25,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/visa.png',
                  color: Colors.white,
                  height: 20,
                ),
                SizedBox(width: 3),
                Image.asset(
                  'assets/images/mastercard.png',
                  height: 20,
                ),
                SizedBox(width: 3),
              ],
            ),
            onTap: () async {
              Navigator.pop(context);
              widget.onMethodSelection("stripe");
            },
          ),
      'gpb': () => PaymentOption(
            imagePath: "assets/images/google-play.jpg",
            methodName: "Pay Via Google Play",
            methods: Text(
              "UPI / Debit Cards / Credit Cards",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onMethodSelection("gpb");
            },
          ),
    };

    final enabled = widget.enabledMethods.where(paymentOptions.containsKey).toList();

    return SafeArea(
      child: Container(
        color: AppColors.colorBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EnergyTrail(height: 2, orange: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Complete payment',
                      style: AppTextStyles.editorial,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '${widget.plan.name.isNotEmpty ? widget.plan.name : widget.plan.validity}  ·  ${widget.plan.currency}${SubscriptionPlan.formatCost(widget.plan.cost)}',
                style: AppTextStyles.meta,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < enabled.length; i++) ...[
                    if (i == 0 || _categoryFor(enabled[i]) != _categoryFor(enabled[i - 1]))
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4, left: 4),
                        child: Text(_categoryFor(enabled[i]), style: AppTextStyles.eyebrow),
                      ),
                    paymentOptions[enabled[i]]!(),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'PAY AND START WATCHING',
                style: TextStyle(
                  color: AppColors.colorOrange,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  fontSize: 11,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'SECURE PAYMENT   ·   CANCEL ANYTIME',
                style: TextStyle(
                  color: AppColors.colorTextMuted,
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
