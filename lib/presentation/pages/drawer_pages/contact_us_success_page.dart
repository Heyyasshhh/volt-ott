import 'package:flutter/material.dart';
import 'package:chill/constants/colors.dart';
import 'package:chill/presentation/components/controls/buttons.dart';

class ContactUsSuccessPage extends StatefulWidget {
  const ContactUsSuccessPage({super.key});

  @override
  State<ContactUsSuccessPage> createState() => _ContactUsSuccessPageState();
}

class _ContactUsSuccessPageState extends State<ContactUsSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                height: 100,
                "assets/images/chill-text.png",
              ),
              const Text(
                "Thank you for contacting us",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                "We will get back to you soon",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              SubmitButton(
                buttonText: 'Back to home',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
