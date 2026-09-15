import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/user/user_subscription.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late Future<List<UserSubscription>> _purchaseHistoryFuture;

  @override
  void initState() {
    super.initState();
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _purchaseHistoryFuture = authenticationProvider.getPurchaseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        backgroundColor: AppColors.colorBackground,
        foregroundColor: Colors.white,
        title: Text("Purchase History"),
      ),
      body: FutureBuilder<List<UserSubscription>>(
        future: _purchaseHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerPlaceholder();
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error loading purchase history",
                    style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text("No purchase history",
                    style: TextStyle(color: Colors.white)));
          }

          final purchases = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return _buildSubscriptionCard(purchase);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(UserSubscription purchase) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.colorBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            purchase.planName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Status: ${purchase.status}",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            "Order ID: ${purchase.orderId}",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            "Valid from: ${purchase.getDisplayStartTime()}",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            "Valid until: ${purchase.getDisplayEndTime()}",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[700]!,
          child: Container(
            height: 80,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
