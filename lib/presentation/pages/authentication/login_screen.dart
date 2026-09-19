import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/network/api_paths.dart';
import 'package:volt/platform_utils.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/authentication/otp_verifiction_page.dart';
import 'package:volt/presentation/pages/home_page.dart';
import 'package:volt/presentation/pages/payment/plans_list_page.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:volt/services/logging_service.dart';
import 'package:volt/services/network_service.dart';
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

  Future<void> _signIn() async {
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
          Navigator.of(context).pushReplacement(MaterialPageRoute(
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
              content: Text(errorMessage ?? "Something Went Wrong"),
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
  }

  Future<void> _googleSignInPressed() async {
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
            await authenticationProvider.saveUserToken(
              sessionId,
              userJson: userJson,
            );
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
    } catch (error) {
      if (mounted) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    }
  }

  Future<void> _appleSignInPressed() async {
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
        {
          "token": token,
          "first_name": appleCredential.givenName,
          "last_name": appleCredential.familyName
        },
        (data) {
          final sessionId = data['body']['session_id'];
          final userJson = data['body']['user'];
          authenticationProvider.saveUserToken(
            sessionId,
            userJson: userJson,
          );
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
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= AppLayout.tablet;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppLayout.gutter(context),
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 6, child: _buildVisual(context, wide: true)),
                            const SizedBox(width: 56),
                            Expanded(
                              flex: 5,
                              child: Center(child: _buildForm(context)),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVisual(context, wide: false),
                            const SizedBox(height: 28),
                            _buildForm(context),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVisual(BuildContext context, {required bool wide}) {
    return Padding(
      padding: EdgeInsets.only(top: wide ? 48 : 8, bottom: wide ? 48 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: wide ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (Navigator.of(context).canPop())
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                size: 40,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          Image.asset(BrandAssets.logo, height: wide ? 72 : 48, fit: BoxFit.contain),
          const SizedBox(height: 28),
          Text(
            'Welcome Back',
            style: AppTextStyles.displayTitle.copyWith(fontSize: wide ? 44 : 32),
          ),
          const SizedBox(height: 10),
          Text(
            'Sign in to continue watching',
            style: AppTextStyles.meta.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DarkField(
            controller: phoneController,
            hintText: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            errorText: phoneError,
            onEditingComplete: () => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Sign In',
            isLoading: _isButtonDisabled,
            onPressed: _isButtonDisabled ? null : _signIn,
          ),
          const SizedBox(height: 24),
          const LightningDivider(),
          const SizedBox(height: 18),
          Text(
            'Or continue with',
            style: AppTextStyles.meta.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SocialCircleButton(
                  onPressed: _isButtonDisabled ? () {} : _googleSignInPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/google.png", width: 18),
                      const SizedBox(width: 8),
                      const Text('Google', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SocialCircleButton(
                  onPressed: _isButtonDisabled ? () {} : _appleSignInPressed,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.apple, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Apple', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.colorTextSecondary,
                fontSize: 14,
                fontFamily: AppTheme.fontFamily,
              ),
              children: [
                const TextSpan(text: "Don't have an account? "),
                TextSpan(
                  text: 'Sign Up',
                  style: const TextStyle(
                    color: AppColors.colorAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      FocusScope.of(context).unfocus();
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                height: 1.4,
                color: AppColors.colorTextMuted,
                fontSize: 12,
                fontFamily: AppTheme.fontFamily,
              ),
              children: <TextSpan>[
                const TextSpan(text: "By using this app you confirm that you agree to our "),
                TextSpan(
                  text: 'Policies',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.colorAccent,
                  ),
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
        ],
      ),
    );
  }
}
