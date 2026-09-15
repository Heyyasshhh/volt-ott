import 'package:flutter/material.dart';

import '../../constants/colors.dart';

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
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.colorPrimaryLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                imagePath,
                height: 48,
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methodName,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  methods

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
