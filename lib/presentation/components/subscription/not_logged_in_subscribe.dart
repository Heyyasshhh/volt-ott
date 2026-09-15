import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../pages/authentication/login_screen.dart';

class NotLoggedInSubscribe extends StatelessWidget {
  const NotLoggedInSubscribe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plans", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.colorBackground,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.colorBackground,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 70),
            const Text(
              "Oops!, you are not logged in",
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 2),
            const Text(
              "Login and Enjoy",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              child: Container(
                height: 45,
                width: 170,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.colorPrimary,
                ),
                child: const Text(
                  "Login Now",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
