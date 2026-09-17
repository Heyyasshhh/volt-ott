import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/network/api_paths.dart';
import 'package:butterfly/presentation/pages/authentication/login_screen.dart';
import 'package:butterfly/presentation/pages/home_page.dart';
import 'package:butterfly/services/logging_service.dart';
import 'package:butterfly/services/network_service.dart';
import 'package:butterfly/presentation/components/ui/app_widgets.dart';
import 'package:butterfly/presentation/components/controls/timer_widget.dart';
import 'package:butterfly/providers/authentication_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../providers/content_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final Widget? next;

  const OtpVerificationPage({super.key, required this.phoneNumber, this.next});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  bool? isValidOtp;
  bool isClickable = true;
  String otp = "";
  String errorMessage = "Invalid OTP";
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final focusedBorderColor = Colors.white;
  final fillColor = const Color.fromRGBO(243, 246, 249, 0);
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Colors.white,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: Colors.white),
    ),
  );

  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("otp_verification_page");
    LoggingService().setCrashlyticsScreen("otp_verification_page");
    getSmsWithRetrieverApi();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              Image.asset('assets/images/butterfly-logo.png', height: 64),
              const SizedBox(height: 24),
              const Text(
                "Enter OTP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "We sent a code to\n${widget.phoneNumber}",
                style: const TextStyle(
                  color: AppColors.colorTextSecondary,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Form(
                key: formKey,
                child: Pinput(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  controller: pinController,
                  focusNode: focusNode,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                      color: AppColors.colorInputBorder,
                      width: 1.5,
                    ),
                    color: AppColors.colorInputFill,
                    ),
                  ),
                  separatorBuilder: (index) => const SizedBox(width: 12),
                  validator: (value) {
                    return _validateOtp(value);
                  },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    otp = pin;
                  },
                  onChanged: (value) {
                    otp = value;
                    isValidOtp = null;
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 2,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  focusedPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.colorPrimary,
                        width: 2,
                      ),
                      color: AppColors.colorInputFill,
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.colorInputBorder,
                        width: 1.5,
                      ),
                      color: AppColors.colorInputFill,
                    ),
                  ),
                  errorPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.redAccent,
                        width: 1.5,
                      ),
                      color: Colors.redAccent.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GradientButton(
                onPressed: () async {
                  if (!isClickable) return;
                  setState(() {
                    isClickable = false;
                  });
                  focusNode.unfocus();
                  if (otp.length != 4) {
                    setState(() {
                      isClickable = true;
                    });
                    isValidOtp = false;
                    errorMessage = "Please enter an OTP";
                    formKey.currentState!.validate();
                  } else {
                    await NetworkService().post(
                      APIPath.verifyOTP,
                      {
                        "otp": otp,
                        "phoneNumber": widget.phoneNumber,
                      },
                      (data) async {
                        isValidOtp = true;
                        LoggingService().logEvent('signup');
                        final sessionId = data['body']['session_id'];
                        final userJson = data['body']['user'];
                        await authenticationProvider.saveUserToken(sessionId, userJson: userJson);
                        Provider.of<ContentProvider>(context, listen: false).init();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widget.next ?? HomePage(),
                            ),
                            (route) => false,
                          );
                          // Modal will be shown from HomePage's initState
                        });
                      },
                      (error) {
                        setState(() {
                          isClickable = true;
                        });
                        isValidOtp = false;
                        errorMessage = error['body']['message'];
                        formKey.currentState!.validate();
                      },
                      () {},
                    );
                  }
                },
                label: "Verify",
                isLoading: !isClickable,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: const TextStyle(
                      color: AppColors.colorTextMuted,
                      fontSize: 14,
                    ),
                  ),
                  TimerWidget(
                    initialSeconds: 60,
                    onPressed: () async {
                      await NetworkService().post(
                        APIPath.sendOTP,
                        {"phone_number": widget.phoneNumber},
                        (data) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP resent successfully")));
                        },
                        (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['body']['message'])));
                          isValidOtp = false;
                          errorMessage = error['body']['message'];
                          formKey.currentState!.validate();
                        },
                        () {},
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: Text(
                  "Change Phone Number",
                  style: const TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.colorTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  _validateOtp(String? otp) {
    if (otp == null || otp.length != 4) return errorMessage;
    if (isValidOtp != null) {
      if (!isValidOtp!) return errorMessage;
    }
    return;
  }

  void getSmsWithRetrieverApi() async {
    final smartAuth = SmartAuth.instance;
    final res = await smartAuth.getSmsWithRetrieverApi();
    if (res.hasData) {
      final code = res.requireData.code;

      /// The code can be null if the SMS was received but the code was not extracted from it
      if (code == null) return;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          pinController.text = code;
        });
      },);
      //  Use the code
    } else {
      // handle the error
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
