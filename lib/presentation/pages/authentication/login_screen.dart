import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/network/api_paths.dart';
import 'package:butterfly/platform_utils.dart';
import 'package:butterfly/presentation/components/controls/buttons.dart';
import 'package:butterfly/presentation/pages/authentication/otp_verifiction_page.dart';
import 'package:butterfly/presentation/pages/home_page.dart';
import 'package:butterfly/presentation/pages/payment/plans_list_page.dart';
import 'package:butterfly/providers/authentication_provider.dart';
import 'package:butterfly/providers/content_provider.dart';
import 'package:butterfly/services/logging_service.dart';
import 'package:butterfly/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../drawer_pages/legal/legal_list.dart';

class LoginPage extends StatefulWidget {
  final Widget? next;

  const LoginPage({super.key, this.next});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool validateEmail(String email) {
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}

class _LoginPageState extends State<LoginPage> {
  bool _isButtonDisabled = false;
  late AuthenticationProvider authenticationProvider;
  late ContentProvider contentProvider;
  final PlatformUtils platformUtils = PlatformUtils();

  late GoogleSignIn _googleSignIn;
  String? phoneError;
  String phoneNumber = "";
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("login_screen");
    LoggingService().setCrashlyticsScreen("login_screen");
    if (PlatformUtils.isWeb) {
      _googleSignIn = GoogleSignIn(
        clientId:
            '227381852653-jskdv59enm926fpi7kv8934tshgjg5lc.apps.googleusercontent.com',
        scopes: [
          'email',
          'profile',
        ],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
    }

    phoneController.addListener(_phoneChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authenticationProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      attemptSilentSignIn();
    });
  }

  void attemptSilentSignIn() async {
    if (!PlatformUtils.isWeb) return;
    final account = await _googleSignIn.signInSilently();
    if (account == null) return;
    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken != null) {
      await NetworkService().post(
        APIPath.googleSignIn,
        {'id_token': idToken},
        (data) {
          final sessionId = data['body']['session_id'];
          authenticationProvider.saveUserToken(sessionId);
        },
        (error) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['body']['message']),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: keyboardHeight),
            ),
          );
        },
        () {},
      );
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  @override
  void dispose() {
    phoneController.removeListener(_phoneChanged);
    phoneController.dispose();
    super.dispose();
  }

  void _phoneChanged() {
    if (phoneNumber != phoneController.text) {
      setState(() {
        _isButtonDisabled = false;
        phoneError = null; // Clear error when user starts typing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    authenticationProvider = Provider.of<AuthenticationProvider>(context);
    contentProvider = Provider.of<ContentProvider>(context, listen: false);
    final loginMethod = contentProvider.getLoginConfigConfirm();

    if (authenticationProvider.getUser() != null && mounted) {
      LoggingService().logEvent('signup');
      contentProvider.init();
      if (loginMethod == 'B' || loginMethod == 'C') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authenticationProvider.getUser()!.userSubscription == null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => PlansListPage(),
              ),
              (_) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
              (_) => false,
            );
            // Modal will be shown from HomePage's initState
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => widget.next ?? HomePage(),
              ),
              (_) => false,
            );
            // Modal will be shown from HomePage's initState
          }
        });
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/butterfly-text.png",
              width: 200,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0x45454545),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                border: Border.all(
                                  color: phoneError != null
                                      ? Colors.redAccent
                                      : const Color(0xFF878787),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '+91',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0x45454545),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  border: Border(
                                    left: BorderSide.none,
                                    top: BorderSide(
                                      color: phoneError != null
                                          ? Colors.redAccent
                                          : const Color(0xFF878787),
                                      width: 1,
                                    ),
                                    right: BorderSide(
                                      color: phoneError != null
                                          ? Colors.redAccent
                                          : const Color(0xFF878787),
                                      width: 1,
                                    ),
                                    bottom: BorderSide(
                                      color: phoneError != null
                                          ? Colors.redAccent
                                          : const Color(0xFF878787),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  style: const TextStyle(color: Colors.white),
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  cursorColor: AppColors.colorPrimary,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    counterText: "",
                                    hintText: 'Phone Number',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF878787),
                                    ),
                                  ),
                                  onEditingComplete: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (phoneError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 16),
                            child: Text(
                              phoneError!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            SubmitButton(
              buttonText: "Continue",
              isLoading: _isButtonDisabled,
              onPressed: _isButtonDisabled
                  ? () {}
                  : () async {
                      phoneNumber = phoneController.text;
                      if (phoneNumber.isNotEmpty) {
                        setState(() {
                          _isButtonDisabled = true;
                        });
                        FocusManager.instance.primaryFocus?.unfocus();
                        await NetworkService().post(
                          APIPath.sendOTP,
                          {"phone_number": phoneNumber},
                          (data) async {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => OtpVerificationPage(
                                phoneNumber: phoneNumber,
                                next: widget.next,
                              ),
                            ));
                          },
                          (error) {
                            String? errorMessage;
                            if (error.toString().contains('body')) {
                              errorMessage = error['body']["message"];
                            } else {
                              errorMessage = error;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    errorMessage ?? "Something Went Wrong"),
                              ),
                            );
                            setState(() {
                              _isButtonDisabled = false;
                            });
                          },
                          () {},
                        );
                      } else {
                        setState(() {
                          phoneError = "Please Enter A Phone Number";
                        });
                      }
                    },
            ),
            const SizedBox(height: 20),
            SocialLoginButton(
              text: Text(
                "Continue With Google",
                style: TextStyle(color: Colors.black),
              ),
              logo: Image.asset("assets/images/google.png", width: 49),
              backgroundColor: Colors.white,
              onPressed: _isButtonDisabled
                  ? () {}
                  : () async {
                try {
                  final account = await _googleSignIn.signIn();

                  if (account == null) return;

                  final googleAuth = await account.authentication;
                  final idToken = googleAuth.idToken;

                  if (idToken != null) {
                    await NetworkService().post(
                      APIPath.googleSignIn,
                      {'id_token': idToken},
                          (data) async {
                        final sessionId = data['body']['session_id'];
                        final userJson = data['body']['user'];
                        await authenticationProvider.saveUserToken(sessionId,
                            userJson: userJson);
                        // Modal will be shown from HomePage's initState after navigation
                        // or from the build method if user is already on HomePage
                      },
                          (error) {
                        final keyboardHeight =
                            MediaQuery.of(context).viewInsets.bottom;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error['body']['message']),
                            behavior: SnackBarBehavior.floating,
                            margin:
                            EdgeInsets.only(bottom: keyboardHeight),
                          ),
                        );
                      },
                          () {},
                    );
                    setState(() {
                      _isButtonDisabled = false;
                    });
                  }
                } catch (error) {
                  if (mounted) {
                    setState(() {
                      _isButtonDisabled = false;
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            SocialLoginButton(
              text: Text(
                "Continue With Apple",
                style: TextStyle(color: Colors.black),
              ),
              logo: Container(
                margin: EdgeInsets.only(left: 12),
                child: const FaIcon(
                  FontAwesomeIcons.apple,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              backgroundColor: Colors.white,
              onPressed: _isButtonDisabled
                  ? () {}
                  : () async {
                try {
                  final appleCredential = await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                      AppleIDAuthorizationScopes.fullName,
                    ],
                    webAuthenticationOptions: WebAuthenticationOptions(
                      clientId: "app.butterflyott.app.signin",
                      redirectUri: Uri.parse(
                        "https://butterflyott.com/api/v1/auth/callback/apple-sign-in",
                      ),
                    ),
                  );

                  final token = appleCredential.identityToken;

                  NetworkService().post(
                    APIPath.appleSignIn,
                    {"token": token, "first_name": appleCredential.givenName, "last_name": appleCredential.familyName},
                        (data) {
                      final sessionId = data['body']['session_id'];
                      final userJson = data['body']['user'];
                      authenticationProvider.saveUserToken(sessionId, userJson: userJson);
                    },
                        (error) {
                      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error['body']['message']),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(bottom: keyboardHeight),
                        ),
                      );
                    },
                        () {},
                  );
                } catch (error) {
                  print(error);
                }
              },
            ),
            // const SizedBox(height: 20),
            // SocialLoginButton(
            //   text: Text(
            //     "Continue With Facebook",
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   logo: Container(
            //     margin: EdgeInsets.only(left: 12),
            //     child: const FaIcon(
            //       FontAwesomeIcons.facebookF,
            //       color: Colors.white,
            //       size: 24,
            //     ),
            //   ),
            //   backgroundColor: const Color(0xFF1877F2),
            //   onPressed: _isButtonDisabled
            //       ? () {}
            //       : () async {
            //           final LoginResult result = await FacebookAuth.instance.login();
            //           if (result.status == LoginStatus.success) {
            //             final AccessToken accessToken = result.accessToken!;
            //             NetworkService().post(
            //               APIPath.facebookSignIn,
            //               {"token": accessToken.tokenString},
            //               (data) {
            //                 final sessionId = data['body']['session_id'];
            //                 final userJson = data['body']['user'];
            //                 authenticationProvider.saveUserToken(sessionId, userJson: userJson);
            //               },
            //               (error) {
            //                 final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            //                 ScaffoldMessenger.of(context).showSnackBar(
            //                   SnackBar(
            //                     content: Text(error['body']['message']),
            //                     behavior: SnackBarBehavior.floating,
            //                     margin: EdgeInsets.only(bottom: keyboardHeight),
            //                   ),
            //                 );
            //               },
            //               () {},
            //             );
            //           } else {
            //             if (!context.mounted) return;
            //             final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               SnackBar(
            //                 content: Text(
            //                   "Facebook Login Failed ${result.message}",
            //                 ),
            //                 behavior: SnackBarBehavior.floating,
            //                 margin: EdgeInsets.only(bottom: keyboardHeight),
            //               ),
            //             );
            //           }
            //         },
            // ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          height: 1.3,
                          color: Colors.white,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                              text:
                                  "By using this app you confirm that you agree to our "),
                          TextSpan(
                            text: 'Policies',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const LegalListPage(),
                                ));
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
