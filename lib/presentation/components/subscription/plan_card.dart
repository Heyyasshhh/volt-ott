import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/models/subscription_plan.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';

class PlansPageHeader extends StatelessWidget {
  const PlansPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Membership', style: AppTextStyles.eyebrow),
        SizedBox(height: 8),
        Text('Choose Your Plan', style: AppTextStyles.displayTitle),
        SizedBox(height: 8),
        Text(
          'Select a membership and start watching.',
          style: AppTextStyles.meta,
        ),
      ],
    );
  }
}

String voltPowerLabel(SubscriptionPlan plan, int index, int total) {
  if (plan.isMostPopular) return 'Most Popular';
  if (plan.isBestValue) return 'Best Value';
  return 'Plan';
}

class PromoCodeBar extends StatelessWidget {
  final bool expanded;
  final String? appliedCouponCode;
  final String? couponMessage;
  final bool loading;
  final TextEditingController controller;
  final VoidCallback onExpand;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const PromoCodeBar({
    super.key,
    required this.expanded,
    required this.appliedCouponCode,
    required this.couponMessage,
    required this.loading,
    required this.controller,
    required this.onExpand,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded && appliedCouponCode == null) {
      return GestureDetector(
        onTap: onExpand,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(Icons.confirmation_number_outlined, color: AppColors.colorAccent, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Have a promo code?',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'Add',
                style: TextStyle(
                  color: AppColors.colorAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                cursorColor: AppColors.colorOrange,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'Promo code',
                  hintStyle: TextStyle(color: AppColors.colorHint, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorHairline),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorAccent, width: 1.4),
                  ),
                ),
                onSubmitted: (_) => onApply(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 96,
              child: GradientButton(
                label: 'Apply',
                height: 44,
                isLoading: loading,
                onPressed: loading ? null : onApply,
              ),
            ),
          ],
        ),
        if (appliedCouponCode != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.colorOrange, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  couponMessage ?? 'Promo applied',
                  style: const TextStyle(
                    color: AppColors.colorOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ] else if (couponMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            couponMessage!,
            style: const TextStyle(
              color: AppColors.colorOrange,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSubscribe;
  final List<String> features;
  final int index;
  final int total;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.onSubscribe,
    this.features = const [
      'Weekly releases',
      'Unlimited streaming',
      'Premium HD',
    ],
    this.index = 0,
    this.total = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: isSelected
            ? _ExpandedPlan(
                plan: plan,
                features: features,
                onSubscribe: onSubscribe,
                badge: voltPowerLabel(plan, index, total),
              )
            : _CompactPlan(
                plan: plan,
                badge: voltPowerLabel(plan, index, total),
              ),
      ),
    );
  }
}

({String number, String unit}) _splitValidity(String validity) {
  final match = RegExp(r'^(\d+)\s*(.*)$').firstMatch(validity.trim());
  if (match == null || (match.group(1) ?? '').isEmpty) {
    return (number: '•', unit: validity);
  }
  final unit = (match.group(2) ?? '').trim();
  return (number: match.group(1)!, unit: unit.isEmpty ? 'days' : unit);
}

class _CompactPlan extends StatelessWidget {
  final SubscriptionPlan plan;
  final String badge;

  const _CompactPlan({required this.plan, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppLayout.radius),
        border: Border.all(color: AppColors.colorHairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(badge, style: AppTextStyles.eyebrow),
                const SizedBox(height: 4),
                Text(
                  plan.name.isNotEmpty ? plan.name : plan.validity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${plan.currency}${SubscriptionPlan.formatCost(plan.cost)}',
            style: AppTextStyles.chrome,
          ),
        ],
      ),
    );
  }
}

class _ExpandedPlan extends StatelessWidget {
  final SubscriptionPlan plan;
  final List<String> features;
  final VoidCallback onSubscribe;
  final String badge;

  const _ExpandedPlan({
    required this.plan,
    required this.features,
    required this.onSubscribe,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final parts = _splitValidity(plan.validity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(AppLayout.radius),
        border: Border.all(color: AppColors.colorOrange.withValues(alpha: 0.7)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(badge, style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
                    const SizedBox(height: 4),
                    Text(
                      plan.name.isNotEmpty ? plan.name : plan.validity,
                      style: AppTextStyles.editorial.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
              if (plan.isMostPopular)
                Text('Most Popular', style: AppTextStyles.seeAll.copyWith(color: AppColors.colorOrange))
              else if (plan.isBestValue)
                Text('Best Value', style: AppTextStyles.seeAll),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                parts.number,
                style: AppTextStyles.displayTitle.copyWith(fontSize: 40),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  parts.unit,
                  style: const TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (plan.originalCost != null)
                    Text(
                      '${plan.currency}${SubscriptionPlan.formatCost(plan.originalCost!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.colorTextMuted,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.colorTextMuted,
                      ),
                    ),
                  Text(
                    '${plan.currency}${SubscriptionPlan.formatCost(plan.cost)}',
                    style: const TextStyle(
                      color: AppColors.colorChrome,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.colorHairline, height: 1),
          const SizedBox(height: 14),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, color: AppColors.colorAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: AppTextStyles.meta)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GradientButton(
            label: 'Subscribe',
            height: 48,
            onPressed: onSubscribe,
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Secure Payment  ·  Cancel Anytime',
              style: TextStyle(
                color: AppColors.colorTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
