import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';

class SubmitButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLoading;

  const SubmitButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = constraints.maxWidth < 600
            ? double.infinity
            : 400; // Limit width on large screens

        return GestureDetector(
          onTap: isLoading ? null : () => onPressed(),
          child: Container(
            height: 50,
            width: buttonWidth,
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isLoading
                  ? AppColors.colorPrimary.withOpacity(0.7)
                  : AppColors.colorPrimary,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(CupertinoColors.white),
                      ),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(color: CupertinoColors.white, fontSize: 17),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        onPressed(),
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(17),
              bottomLeft: Radius.circular(17),
              topRight: Radius.circular(17)),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final Text text;
  final Widget logo;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.logo,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = constraints.maxWidth < 600
            ? double.infinity
            : 400; // Limit width on large screens

        return GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 50,
            width: buttonWidth,
            // Responsive width
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(14),
              ),
              color: backgroundColor,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    logo,
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: text,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SocialLoginIcon extends StatelessWidget {
  final Widget logo;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const SocialLoginIcon({
    super.key,
    required this.logo,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        onPressed();
      },
      child: Container(
        height: 57,
        width: 57,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(200),
          ),
          color: backgroundColor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            logo,
          ],
        ),
      ),
    );
  }
}
