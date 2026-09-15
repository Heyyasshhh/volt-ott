import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:chill/constants/colors.dart';

/// Shimmer placeholder for the Subscribe Now / plans list page.
/// Title and subtitle are shown as real text (only plans load from API). Shimmer only on plan cards.
class PlansListPageShimmer extends StatelessWidget {
  const PlansListPageShimmer({super.key});

  static const _shimmerBase = Color(0xFF1A1A1A);
  static const _shimmerHighlight = Color(0xFF262626);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle — real text (not loaded from API)
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
          // Plan card placeholders with darker, subtle shimmer
          Shimmer.fromColors(
            baseColor: _shimmerBase,
            highlightColor: _shimmerHighlight,
            child: Column(
              children: [
                _buildPlanCardShimmer(context),
                const SizedBox(height: 10),
                _buildPlanCardShimmer(context),
                const SizedBox(height: 10),
                _buildPlanCardShimmer(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCardShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.colorBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge row
          Row(
            children: [
              Container(
                height: 22,
                width: 100,
                decoration: BoxDecoration(
                  color: _shimmerBase,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Validity / title line
          Container(
            height: 16,
            width: 140,
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          // Description line
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          // Feature rows
          _buildFeatureShimmer(),
          const SizedBox(height: 6),
          _buildFeatureShimmer(),
          const SizedBox(height: 6),
          _buildFeatureShimmer(),
          const SizedBox(height: 12),
          // Price line
          Container(
            height: 20,
            width: 80,
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          // Button placeholder
          Container(
            height: 44,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureShimmer() {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: _shimmerBase,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}
