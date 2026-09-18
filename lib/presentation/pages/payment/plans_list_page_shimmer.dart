import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:volt/constants/colors.dart';
import 'package:volt/presentation/components/subscription/plan_card.dart';

class PlansListPageShimmer extends StatelessWidget {
  const PlansListPageShimmer({super.key});

  static const _shimmerBase = Color(0xFF071426);
  static const _shimmerHighlight = Color(0xFF0B2B55);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PlansPageHeader(),
          const SizedBox(height: 18),
          Shimmer.fromColors(
            baseColor: _shimmerBase,
            highlightColor: _shimmerHighlight,
            child: Column(
              children: [
                _core(expanded: true),
                const SizedBox(height: 14),
                _core(),
                const SizedBox(height: 14),
                _core(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _core({bool expanded = false}) {
    return Container(
      height: expanded ? 220 : 92,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.colorHairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: expanded ? 54 : 42,
            height: expanded ? 54 : 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.colorAccent),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10, width: 88, color: _shimmerBase),
                const SizedBox(height: 10),
                Container(height: 16, width: 140, color: _shimmerBase),
                if (expanded) ...[
                  const Spacer(),
                  Container(height: 44, width: double.infinity, color: _shimmerBase),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
