import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/models/subscription_plan.dart';
import 'package:butterfly/presentation/components/subscription/not_logged_in_subscribe.dart';
import 'package:butterfly/presentation/pages/payment/payment_success_page.dart';
import 'package:butterfly/presentation/pages/payment/plans_list_page_shimmer.dart';
import 'package:butterfly/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class PlansListPage extends StatefulWidget {
  const PlansListPage({super.key});

  @override
  State<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends State<PlansListPage> {
  final _inAppPurchase = InAppPurchase.instance;

  /// Loaded once.
  late Future<Map<String, dynamic>> _plansFuture;

  /// Loaded once.
  List<SubscriptionPlan> _plans = [];
  List<ProductDetails> _products = [];

  SubscriptionPlan? selectedPlan;
  Set<String> _ids = {};

  bool _pendingDialogVisible = false;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSub;

  /// Track user-initiated purchase flow so we can ignore random restores/renewals.
  bool _purchaseInProgress = false;
  String? _activeProductId;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthenticationProvider>(context, listen: false);
    _plansFuture = auth.getPlansListAndEnabledMethods();

    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdates,
      onDone: () {
        debugPrint('Purchase stream done');
      },
      onError: (Object error) {
        debugPrint('Purchase stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _purchaseSub.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // PURCHASE LISTENER
  // ------------------------------------------------------------
  Future<void> _listenToPurchaseUpdates(List<PurchaseDetails> purchases) async {
    if (!mounted) return;

    for (final p in purchases) {
      debugPrint(
        'Purchase update -> '
            'product: ${p.productID}, '
            'status: ${p.status}, '
            'pendingComplete: ${p.pendingCompletePurchase}',
      );

      final bool isCurrentFlow =
          _purchaseInProgress && _activeProductId == p.productID;

      // ------------------------------------------------------------
      // 1) SPECIAL CASE: Subscription upgrade
      // Apple sends ONLY a "restored" event when user upgrades
      // We MUST treat restore as success if user initiated purchase,
      // even if the restored product is NOT the one just purchased.
      // ------------------------------------------------------------
      if (_purchaseInProgress &&
          p.status == PurchaseStatus.restored &&
          !isCurrentFlow) {
        debugPrint("✔ Apple accepted subscription upgrade via RESTORE.");

        final receipt = p.verificationData.serverVerificationData;
        final gateway = p.verificationData.source == 'google_play'
            ? 'google-in-app'
            : 'apple-in-app';

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessPage(
                paymentId: receipt,
                paymentGateway: gateway,
                productId: _activeProductId ?? p.productID,
                referralCode: null,
              ),
            ),
          );
        }

        if (p.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(p);
        }

        _purchaseInProgress = false;
        _activeProductId = null;
        continue;
      }

      // ------------------------------------------------------------
      // 2) Ignore unrelated old restores (normal behavior)
      // ------------------------------------------------------------
      if (!isCurrentFlow && p.status == PurchaseStatus.restored) {
        debugPrint("Ignoring unrelated restore for ${p.productID}");
        if (p.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(p);
        }
        continue;
      }

      // ------------------------------------------------------------
      // 3) Pending state → show loader
      // ------------------------------------------------------------
      if (p.status == PurchaseStatus.pending) {
        _showPendingUI();
        continue;
      }

      // Close pending loader for any non-pending state
      if (_pendingDialogVisible && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _pendingDialogVisible = false;
      }

      // ------------------------------------------------------------
      // 4) Handle all purchase outcomes
      // ------------------------------------------------------------
      switch (p.status) {
        case PurchaseStatus.error:
          debugPrint("Purchase error: ${p.error}");
          _purchaseInProgress = false;
          _activeProductId = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment failed. Try again.")),
          );
          break;

        case PurchaseStatus.canceled:
          debugPrint("Purchase canceled by user.");
          _purchaseInProgress = false;
          _activeProductId = null;
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
        // Normal success case for the SAME product
          final receipt = p.verificationData.serverVerificationData;
          final gateway = p.verificationData.source == 'google_play'
              ? 'google-in-app'
              : 'apple-in-app';

          debugPrint("✔️ Purchase SUCCESS for ${p.productID}");

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                  paymentId: receipt,
                  paymentGateway: gateway,
                  productId: p.productID,
                  referralCode: null,
                ),
              ),
            );
          }
          break;

        default:
          break;
      }

      // ------------------------------------------------------------
      // 5) Always complete the transaction
      // ------------------------------------------------------------
      if (p.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(p);
      }

      // Reset
      _purchaseInProgress = false;
      _activeProductId = null;
    }
  }

  // ------------------------------------------------------------
  // UI HELPERS
  // ------------------------------------------------------------
  void _showPendingUI() {
    if (_pendingDialogVisible) return;
    _pendingDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5)),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.colorPrimary,),
                    SizedBox(height: 20),
                    Text(
                      "Processing Your Payment",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please do not close this screen.",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    ).then((_) => _pendingDialogVisible = false);
  }

  // ------------------------------------------------------------
  // LOAD IAP PRODUCTS — One Time
  // ------------------------------------------------------------
  Future<void> _loadProductsOnce() async {
    if (_ids.isEmpty || _products.isNotEmpty) return;

    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('In-app purchases not available on this device/store.');
      return;
    }
    print(_ids);
    final response = await _inAppPurchase.queryProductDetails(_ids);
    print(response.error);
    print(response.notFoundIDs);
    print(response.productDetails);
    if (!mounted) return;

    if (response.error != null) {
      debugPrint('ProductDetails error: ${response.error}');
    }

    setState(() {
      _products = response.productDetails;
    });

    debugPrint(
        'Loaded products: ${_products.map((p) => '${p.id} (${p.price})').join(', ')}');
  }

  ProductDetails? _getProductForPlan(SubscriptionPlan plan) {
    try {
      print(plan.iapId);
      return _products.firstWhere((p) => p.id == plan.iapId);
    } catch (_) {
      debugPrint('No ProductDetails found for plan ${plan.id} (${plan.iapId})');
      return null;
    }
  }

  Future<void> _startPurchase(SubscriptionPlan plan) async {
    final auth = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = auth.getUser();
    if (user == null) return;

    final product = _getProductForPlan(plan);
    if (product == null) {
      debugPrint('❌ Cannot start purchase — product is null.');
      return;
    }

    // Mark this purchase as user-initiated
    _purchaseInProgress = true;
    _activeProductId = product.id;

    final payload = '${user.id}-${plan.id}';

    final param = PurchaseParam(
      productDetails: product,
      applicationUserName: payload,
    );

    debugPrint("▶️ Starting purchase for ${product.id}");

    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint("buyNonConsumable ERROR: $e");
      _purchaseInProgress = false;
      _activeProductId = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to start payment.")),
      );
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthenticationProvider>(context);
    final user = auth.getUser();

    if (user == null) return NotLoggedInSubscribe();

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        backgroundColor: AppColors.colorBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Subscribe Now",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _plansFuture,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const PlansListPageShimmer();
            }

            final result = snap.data as Map<String, dynamic>;
            final allPlans = List<SubscriptionPlan>.from(result['plans']);

            // Show all plans regardless of subscription state
            if (_plans.isEmpty) {
              _plans = allPlans;

              // selected plan once (match Android: isDefaultSelected, then [1], then first)
              selectedPlan = _plans.firstWhereOrNull((e) => e.isDefaultSelected);
              if (selectedPlan == null && _plans.length > 1) selectedPlan = _plans[1];
              if (selectedPlan == null && _plans.isNotEmpty) selectedPlan = _plans.first;

              // prepare IAP IDs once
              _ids = _plans.map((p) => p.iapId).toSet();

              // load IAP products once
              _loadProductsOnce();
            }

            if (selectedPlan == null || _plans.isEmpty) {
              return const Center(
                child: Text(
                  'No plans available right now.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return _buildUI(context);
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI (Android-style: vertical list of full-width cards)
  // ------------------------------------------------------------
  Widget _buildUI(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Choose Your Plan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select the perfect plan for your entertainment",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          // Vertically stacked plan cards (same as Android)
          ..._plans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            final isSelected = selectedPlan == plan;
            return Padding(
              padding: EdgeInsets.only(bottom: index < _plans.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () {
                  if (!context.mounted) return;
                  setState(() => selectedPlan = plan);
                  _onPlanPressed(plan);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.colorBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.colorPrimary : Colors.white.withValues(alpha: 0.2),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.colorPrimary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges row
                          Row(
                            children: [
                              if (plan.isMostPopular)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.colorPrimary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "MOST POPULAR",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              if (plan.isBestValue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.yellow, width: 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "BEST VALUE",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (plan.isMostPopular || plan.isBestValue) const SizedBox(height: 8),
                          Text(
                            plan.validity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Select the perfect plan for your entertainment",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem("Two new releases every week"),
                          const SizedBox(height: 6),
                          _buildFeatureItem("Unlimited streaming"),
                          const SizedBox(height: 6),
                          _buildFeatureItem("Premium HD videos"),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (plan.originalCost != null) ...[
                                Text(
                                  "${plan.currency}${SubscriptionPlan.formatCost(plan.originalCost!)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                "${plan.currency}${SubscriptionPlan.formatCost(plan.cost)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!context.mounted) return;
                                setState(() => selectedPlan = plan);
                                _onPlanPressed(plan);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? AppColors.colorPrimary : Colors.white.withValues(alpha: 0.1),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                plan.buttonText,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.colorPrimary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.colorPrimary,
            size: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            feature,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ON PLAN PRESSED
  // ------------------------------------------------------------
  void _onPlanPressed(SubscriptionPlan plan) {
    setState(() => selectedPlan = plan);
    _startPurchase(plan);
  }
}
