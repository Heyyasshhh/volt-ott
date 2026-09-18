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

  Future<void> _powerOn() async {
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 6, child: _buildHero(context, wide: true)),
                            const SizedBox(width: 48),
                            Expanded(flex: 5, child: _buildCircuit(context)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHero(context, wide: false),
                            const SizedBox(height: 28),
                            _buildCircuit(context),
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

  Widget _buildHero(BuildContext context, {required bool wide}) {
    return Column(
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
        const BrandWordmark(fontSize: 22),
        const SizedBox(height: 28),
        Text('WELCOME BACK', style: AppTextStyles.eyebrow),
        const SizedBox(height: 12),
        Text(
          'Sign in to\nVOLT',
          style: AppTextStyles.displayTitle.copyWith(
            fontSize: wide ? 64 : 48,
            height: 0.92,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const ChromeRule(width: 42, thickness: 1.4, orange: true),
            const SizedBox(width: 12),
            Text(
              'Phone number',
              style: AppTextStyles.editorial.copyWith(
                fontSize: 18,
                color: AppColors.colorElectric,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const EnergyTrail(height: 2),
        const SizedBox(height: 16),
        Text(
          'Sign in to continue streaming.',
          style: AppTextStyles.meta.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCircuit(BuildContext context) {
    return _CircuitPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.colorOrange,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'PHONE NUMBER',
                style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2.4),
              ),
            ],
          ),
          const SizedBox(height: 22),
          DarkField(
            controller: phoneController,
            hintText: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            errorText: phoneError,
            onEditingComplete: () => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 28),
          GradientButton(
            label: 'Sign In',
            isLoading: _isButtonDisabled,
            onPressed: _isButtonDisabled ? null : _powerOn,
          ),
          const SizedBox(height: 28),
          const LightningDivider(),
          const SizedBox(height: 18),
          Text(
            'OR CONTINUE WITH',
            style: AppTextStyles.eyebrow.copyWith(
              color: AppColors.colorTextMuted,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SocialCircleButton(
                onPressed: _isButtonDisabled ? () {} : _googleSignInPressed,
                child: Image.asset("assets/images/google.png", width: 22),
              ),
              const SizedBox(width: 14),
              SocialCircleButton(
                onPressed: _isButtonDisabled ? () {} : _appleSignInPressed,
                child: const FaIcon(
                  FontAwesomeIcons.apple,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              SocialCircleButton(
                onPressed: () => FocusScope.of(context).unfocus(),
                child: const Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 28),
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
                    color: AppColors.colorPrimary,
                    fontWeight: FontWeight.w800,
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
                    fontWeight: FontWeight.bold,
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

class _CircuitPanel extends StatelessWidget {
  final Widget child;

  const _CircuitPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _CircuitPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: child,
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  const _CircuitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cut = 16.0;
    final path = Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cut)
      ..close();

    final fill = Paint()..color = AppColors.colorMidnight.withValues(alpha: 0.55);
    canvas.drawPath(path, fill);

    final stroke = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD9DDE3), Color(0xFF20B8FF), Color(0xFFFF6A00), Color(0xFFD9DDE3)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(path, stroke);

    final node = Paint()..color = AppColors.colorAccent;
    canvas.drawCircle(const Offset(8, 8), 2.4, node);
    canvas.drawCircle(Offset(size.width - 8, 8), 2.4, Paint()..color = AppColors.colorOrange);
    canvas.drawCircle(Offset(8, size.height - 8), 2.4, Paint()..color = AppColors.colorSilver);
    canvas.drawCircle(Offset(size.width - 10, size.height - 10), 2.4, node);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
