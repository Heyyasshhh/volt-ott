import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/app_theme.dart';

class PaymentOption extends StatelessWidget {
  final String imagePath;
  final String methodName;
  final Widget methods;
  final VoidCallback onTap;

  const PaymentOption({
    super.key,
    required this.imagePath,
    required this.methodName,
    required this.methods,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.colorHairline),
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 28,
              width: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methodName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.colorSilver,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      fontFamily: AppTheme.displayFamily,
                    ),
                  ),
                  const SizedBox(height: 6),
                  methods,
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: AppColors.colorOrange, size: 16),
          ],
        ),
      ),
    );
  }
}
