import 'package:flutter/material.dart';
import '../authentication/login_screen.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/subscription_plan.dart';
import 'package:volt/presentation/components/subscription/plan_card.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/payment/payment_success_page.dart';
import 'package:volt/presentation/pages/payment/plans_list_page_shimmer.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/user/user.dart';
import '../../../network/api_paths.dart';
import '../../../razorpay_js.dart';
import '../../../services/network_service.dart';

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
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        backgroundColor: AppColors.colorBackground,
        title: const Text("Subscribe"),
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: SafeArea(
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
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  itemCount: _plans.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: PlansPageHeader(),
                      );
                    }
                    final plan = _plans[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: PlanCard(
                        plan: plan,
                        index: index - 1,
                        total: _plans.length,
                        isSelected: selectedPlan == plan,
                        onTap: () async {
                          setState(() {
                            selectedPlan = plan;
                          });
                          _showPlanPopup(user, plan);
                        },
                        onSubscribe: () {
                          setState(() {
                            selectedPlan = plan;
                          });
                          _showPlanPopup(user, plan);
                        },
                      ),
                    );
                  },
                );
              } else {
                return const PlansListPageShimmer();
              }
            },
          ),
        ),
      ),
    );
  }

  void _showPlanPopup(User? user, SubscriptionPlan plan) async {
    if (user == null) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPage(next: const PlansListPage()),
        ),
      );
      return;
    }

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
