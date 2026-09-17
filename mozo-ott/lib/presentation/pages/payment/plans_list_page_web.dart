import 'package:flutter/material.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/models/subscription_plan.dart';
import 'package:mozo/presentation/pages/payment/payment_success_page.dart';
import 'package:mozo/presentation/pages/payment/plans_list_page_shimmer.dart';
import 'package:mozo/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/user/user.dart';
import '../../../network/api_paths.dart';
import '../../../razorpay_js.dart';
import '../../../services/network_service.dart';
import '../authentication/login_screen.dart';

class PlansListPage extends StatefulWidget {
  const PlansListPage({super.key});

  @override
  State<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends State<PlansListPage> {
  late List<SubscriptionPlan> _plans = [];
  late BuildContext preContext;
  SubscriptionPlan? selectedPlan;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.colorBackground,
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 70),
              const Text(
                "Oops!, you are not logged in",
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
              const SizedBox(height: 2),
              const Text(
                "Login and Enjoy",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: Container(
                  height: 45,
                  width: 170,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.colorPrimary,
                  ),
                  child: const Text(
                    "Login Now",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        backgroundColor: AppColors.colorBackground,
        title: const Text("Subscribe Now"),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: authenticationProvider.getPlansListAndEnabledMethods(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<SubscriptionPlan> allPlans = snapshot.data?['plans'];

              // Show all plans regardless of subscription state
              _plans = allPlans;
              if (selectedPlan == null) {
                if (_plans.length > 1) {
                  selectedPlan = _plans[1];
                }
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _plans.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        final isSelected = selectedPlan == plan;

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedPlan = plan;
                            });
                            _showPlanPopup(user, plan);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [AppColors.colorBackground, AppColors.colorBackground],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              border: Border.all(
                                color: isSelected ? Colors.orange : Colors.grey.shade800,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? Colors.orange.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  plan.validity,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Select the perfect plan for your entertainment",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${plan.currency}${plan.cost}",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (plan.originalCost != null) const SizedBox(width: 10),
                                    if (plan.originalCost != null)
                                      Text(
                                        "${plan.currency}${plan.originalCost}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          decoration: TextDecoration.lineThrough,
                                          decorationColor: Colors.white,
                                          decorationThickness: 2.0,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "New web series release every week",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Unlimited streaming",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "HD + (2k) Quality",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const PlansListPageShimmer();
            }
          },
        ),
      ),
    );
  }

  void _showPlanPopup(User user, SubscriptionPlan plan) async {
    preContext = context;
    await NetworkService().post(
      APIPath.createRazorpayCharge,
      {"object_id": plan.id},
      (data) {
        // Instead of using the mobile-only _razorpay instance, use our web integration.
        openRazorpay(data['body']['options'], (response) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessPage(
                paymentId: response['razorpay_payment_id'],
                paymentGateway: 'razorpay',
                productId: plan.id,
                referralCode: null,
              ),
            ),
          );
        });
      },
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Failed"),
          ),
        );
      },
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please wait while we process your order"),
          ),
        );
      },
    );
  }
}
