import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';

class ContactUsSuccessPage extends StatefulWidget {
  const ContactUsSuccessPage({super.key});

  @override
  State<ContactUsSuccessPage> createState() => _ContactUsSuccessPageState();
}

class _ContactUsSuccessPageState extends State<ContactUsSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(BrandAssets.logo, height: 64),
                const SizedBox(height: 28),
                const Text('MESSAGE SENT', style: AppTextStyles.eyebrow),
                const SizedBox(height: 10),
                Text(
                  'Thank you for contacting us',
                  style: AppTextStyles.displayTitle.copyWith(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'We will get back to you soon.',
                  style: AppTextStyles.meta,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Back to home',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
