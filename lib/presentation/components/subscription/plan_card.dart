import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/subscription_plan.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';

class PlansPageHeader extends StatelessWidget {
  const PlansPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MEMBERSHIP', style: AppTextStyles.eyebrow),
        SizedBox(height: 8),
        Text('Choose a plan', style: AppTextStyles.displayTitle),
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
  if (plan.isMostPopular) return 'MOST POPULAR';
  if (plan.isBestValue) return 'BEST VALUE';
  return 'PLAN';
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
              Icon(Icons.confirmation_number_outlined, color: AppColors.colorOrange, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Have a promo code?',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'ADD',
                style: TextStyle(
                  color: AppColors.colorOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
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
                  fontSize: 18,
                  fontFamily: AppTheme.displayFamily,
                  fontWeight: FontWeight.w700,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'PROMO CODE',
                  hintStyle: TextStyle(color: AppColors.colorHint, fontSize: 14, letterSpacing: 2),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorHairline),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.colorAccent, width: 1.6),
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
                height: 48,
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
                    fontWeight: FontWeight.w700,
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
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: isSelected
            ? _EnergyCore(
                plan: plan,
                features: features,
                onSubscribe: onSubscribe,
                powerLabel: voltPowerLabel(plan, index, total),
              )
            : _DormantCore(
                plan: plan,
                powerLabel: voltPowerLabel(plan, index, total),
              ),
      ),
    );
  }
}

({String number, String unit}) _splitValidity(String validity) {
  final match = RegExp(r'^(\d+)\s*(.*)$').firstMatch(validity.trim());
  if (match == null || (match.group(1) ?? '').isEmpty) {
    return (number: '•', unit: validity.toUpperCase());
  }
  final unit = (match.group(2) ?? '').trim();
  return (number: match.group(1)!, unit: unit.isEmpty ? 'PASS' : unit);
}

class _DormantCore extends StatelessWidget {
  final SubscriptionPlan plan;
  final String powerLabel;

  const _DormantCore({required this.plan, required this.powerLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.colorHairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CustomPaint(
            size: const Size(42, 42),
            painter: _CoreRingPainter(active: false),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(powerLabel, style: AppTextStyles.eyebrow),
                const SizedBox(height: 4),
                Text(
                  plan.name.isNotEmpty ? plan.name : plan.validity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

class _EnergyCore extends StatelessWidget {
  final SubscriptionPlan plan;
  final List<String> features;
  final VoidCallback onSubscribe;
  final String powerLabel;

  const _EnergyCore({
    required this.plan,
    required this.features,
    required this.onSubscribe,
    required this.powerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final parts = _splitValidity(plan.validity);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.colorOrange.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorOrange.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _CoreGlowPainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomPaint(
                      size: const Size(54, 54),
                      painter: _CoreRingPainter(active: true),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(powerLabel, style: AppTextStyles.eyebrow.copyWith(color: AppColors.colorOrange)),
                          const SizedBox(height: 4),
                          Text(
                            plan.name.isNotEmpty ? plan.name : plan.validity,
                            style: AppTextStyles.editorial.copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                    if (plan.isMostPopular)
                      Text('MOST POPULAR', style: AppTextStyles.seeAll)
                    else if (plan.isBestValue)
                      Text('BEST VALUE', style: AppTextStyles.seeAll.copyWith(color: AppColors.colorAccent)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      parts.number,
                      style: AppTextStyles.displayTitle.copyWith(fontSize: 56),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        parts.unit.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.colorOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
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
                            color: AppColors.colorSilver,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            fontFamily: AppTheme.displayFamily,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const EnergyTrail(height: 1.6, orange: true),
                const SizedBox(height: 14),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: AppColors.colorAccent, size: 14),
                        const SizedBox(width: 8),
                        Text(feature, style: AppTextStyles.meta),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GradientButton(
                  label: 'Subscribe',
                  height: 50,
                  onPressed: onSubscribe,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoreRingPainter extends CustomPainter {
  final bool active;
  _CoreRingPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final orange = Paint()
      ..color = active ? AppColors.colorOrange : AppColors.colorHairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2 : 1.1;
    final blue = Paint()
      ..color = active ? AppColors.colorAccent : AppColors.colorTextMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(c, size.width * 0.46, orange);
    canvas.drawCircle(c, size.width * 0.32, blue);
    if (active) {
      canvas.drawCircle(c, 4, Paint()..color = AppColors.colorElectric);
    }
  }

  @override
  bool shouldRepaint(covariant _CoreRingPainter oldDelegate) => oldDelegate.active != active;
}

class _CoreGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.colorOrange.withValues(alpha: 0.16),
          AppColors.colorAccent.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.18, size.height * 0.2), radius: 180));
    canvas.drawRect(Offset.zero & size, glow);
    final blue = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.colorAccent.withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.9, size.height * 0.85), radius: 160));
    canvas.drawRect(Offset.zero & size, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BillingPowerMeter extends StatelessWidget {
  final bool yearly;
  final ValueChanged<bool> onChanged;

  const BillingPowerMeter({
    super.key,
    required this.yearly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!yearly),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              'MONTHLY',
              style: TextStyle(
                color: yearly ? AppColors.colorTextMuted : AppColors.colorOrange,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomPaint(
                size: const Size(double.infinity, 10),
                painter: _MeterPainter(value: yearly ? 1 : 0),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'YEARLY',
              style: TextStyle(
                color: yearly ? AppColors.colorAccent : AppColors.colorTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeterPainter extends CustomPainter {
  final double value;
  _MeterPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final bg = Paint()
      ..color = AppColors.colorHairline
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), bg);
    final t = size.width * (0.12 + value * 0.76);
    canvas.drawCircle(
      Offset(t, y),
      5,
      Paint()..color = value > 0.5 ? AppColors.colorAccent : AppColors.colorOrange,
    );
  }

  @override
  bool shouldRepaint(covariant _MeterPainter oldDelegate) => oldDelegate.value != value;
}
