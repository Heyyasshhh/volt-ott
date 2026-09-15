import 'package:flutter/material.dart';
import 'package:butterfly/presentation/pages/authentication/login_screen.dart';
import 'package:butterfly/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/subscription_plan.dart';
import '../payment_option.dart';

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
            imagePath: "assets/images/butterfly-512.png",
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
        imagePath: "assets/images/butterfly-512.png",
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

    return SafeArea(
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...widget.enabledMethods
                            .where(paymentOptions.containsKey)
                            .map((method) => paymentOptions[method]!()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
