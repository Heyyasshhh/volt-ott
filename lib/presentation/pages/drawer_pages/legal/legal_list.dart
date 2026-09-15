import 'package:chill/presentation/pages/drawer_pages/legal/about_us_page.dart';
import 'package:flutter/material.dart';
import 'package:chill/constants/colors.dart';
import 'package:chill/platform_utils.dart';
import 'package:chill/presentation/components/controls/more_widget.dart';
import 'package:chill/presentation/pages/drawer_pages/legal/grievance.dart';
import 'package:chill/presentation/pages/drawer_pages/legal/privacy_policy_page.dart';
import 'package:chill/presentation/pages/drawer_pages/legal/refund_policy_page.dart';
import 'package:chill/presentation/pages/drawer_pages/legal/terms_and_conditions_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalListPage extends StatefulWidget {
  const LegalListPage({super.key});

  @override
  State<LegalListPage> createState() => _LegalListPageState();
}

class _LegalListPageState extends State<LegalListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: AppColors.colorBackground),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.colorBackground,
        title: const Text("Legal Information"),
      ),
      backgroundColor: AppColors.colorBackground,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.95,
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MoreWidget(
                      text: "Terms of use",
                      icon: Icons.contact_page,
                      onPressed: () {
                        if (PlatformUtils.isWeb) {
                          _launchURL('https://chillapp.in/legal/terms');
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TermsAndConditionsPage(),
                            ),
                          );
                        }
                      },
                    ),
                    MoreWidget(
                      text: "Privacy policy",
                      icon: Icons.privacy_tip,
                      onPressed: () {
                        if (PlatformUtils.isWeb) {
                          _launchURL(
                              'https://chillapp.in/legal/privacy-policy');
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyPage(),
                            ),
                          );
                        }
                      },
                    ),
                    MoreWidget(
                      text: "Refund policy",
                      icon: Icons.account_balance,
                      onPressed: () {
                        if (PlatformUtils.isWeb) {
                          _launchURL(
                              'https://chillapp.in/legal/refund-policy');
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RefundPolicyPage(),
                            ),
                          );
                        }
                      },
                    ),
                    MoreWidget(
                      text: "About US",
                      icon: Icons.info_outline,
                      onPressed: () {
                        if (PlatformUtils.isWeb) {
                          _launchURL(
                              'https://chillapp.in/legal/refund-policy');
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AboutUsPage(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String websiteUrl) async {
    final Uri url = Uri.parse(websiteUrl);
    if (!await launchUrl(url, webOnlyWindowName: '_blank')) {
      throw 'Could not launch $url';
    }
  }
}
