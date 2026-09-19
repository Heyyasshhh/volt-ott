import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/network/api_paths.dart';
import 'package:volt/presentation/pages/home_page.dart';
import 'package:volt/presentation/purchase_history_page.dart';
import 'package:volt/services/network_service.dart';
import 'package:volt/presentation/components/controls/text_input.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/pages/payment/plans_list_page.dart';
import 'package:volt/presentation/pages/authentication/login_screen.dart';
import 'package:volt/presentation/pages/drawer_pages/contact_us_page.dart';
import 'package:volt/presentation/pages/drawer_pages/legal/privacy_policy_page.dart';
import 'package:volt/presentation/pages/drawer_pages/legal/terms_and_conditions_page.dart';
import 'package:volt/presentation/pages/drawer_pages/legal/refund_policy_page.dart';
import 'package:volt/presentation/pages/drawer_pages/legal/about_us_page.dart';
import 'package:volt/presentation/pages/fragments/my_list_page.dart';
import 'package:volt/presentation/pages/media/downloads_page.dart';
import 'package:volt/presentation/pages/drawer_pages/notifications_page.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:volt/providers/content_provider.dart';
import 'package:volt/settings.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController deleteController = TextEditingController();
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    deleteController.dispose();
    super.dispose();
  }

  void _openManageProfiles(AuthenticationProvider auth) {
    final user = auth.getUser();
    usernameController.text = user?.username ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manage Profile', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              TextInput(
                controller: usernameController,
                hintText: 'Full Name',
                obscureText: false,
                isLast: true,
                padding: 0,
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Save',
                onPressed: () async {
                  final username = usernameController.text.trim();
                  if (username.isEmpty) return;
                  await NetworkService().post(
                    APIPath.updateProfile,
                    {"username": username},
                    (data) {
                      auth.updateUsername(username);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Profile Updated Successfully')),
                      );
                    },
                    (error) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Profile Update Failed')),
                      );
                    },
                    () {},
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);
    final user = authenticationProvider.getUser();
    final isSubscribed = user?.userSubscription != null;

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (Navigator.of(context).canPop())
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 40,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        'Profile',
                        style: AppTextStyles.displayTitle.copyWith(fontSize: 28),
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.settings_outlined,
                      size: 40,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AppSettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.colorHairline, height: 1),
                const SizedBox(height: 28),
                Center(
                  child: ClipOval(
                    child: Container(
                      width: 88,
                      height: 88,
                      color: AppColors.colorSurface,
                      child: Image.asset(
                        BrandAssets.logo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user?.username?.isNotEmpty == true ? user!.username! : 'Guest',
                    style: AppTextStyles.editorial.copyWith(fontSize: 26),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    user?.getUniqueCredential().isNotEmpty == true
                        ? user!.getUniqueCredential()
                        : 'Sign in to personalize your experience',
                    style: AppTextStyles.meta,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                if (user != null)
                  Center(
                    child: GestureDetector(
                      onTap: () => _openManageProfiles(authenticationProvider),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: AppColors.colorAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  GradientButton(
                    label: 'Sign In',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlansListPage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: AppColors.colorSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.colorHairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSubscribed ? 'Membership' : 'Not subscribed',
                          style: AppTextStyles.eyebrow.copyWith(
                            color: isSubscribed ? AppColors.colorOrange : AppColors.colorAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSubscribed
                              ? (user?.userSubscription!.planName ?? 'Premium')
                              : 'Subscribe',
                          style: AppTextStyles.editorial.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isSubscribed
                              ? 'Valid until ${user?.userSubscription!.getDisplayEndTime()}'
                              : 'Subscribe to watch all titles.',
                          style: AppTextStyles.meta,
                        ),
                        if (!isSubscribed) ...[
                          const SizedBox(height: 16),
                          GradientButton(
                            label: 'Subscribe',
                            height: 48,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PlansListPage()),
                              );
                            },
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          const EnergyProgress(value: 1),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Library', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.55,
                  children: [
                    _PowerShortcut(
                      label: 'My List',
                      icon: Icons.bookmark_border_rounded,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyListPage()));
                      },
                    ),
                    _PowerShortcut(
                      label: 'Downloads',
                      icon: Icons.download_outlined,
                      accent: true,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage()));
                      },
                    ),
                    _PowerShortcut(
                      label: 'Watch History',
                      icon: Icons.history_rounded,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyListPage()));
                      },
                    ),
                    if (user != null)
                      _PowerShortcut(
                        label: 'Purchase History',
                        icon: Icons.receipt_long_outlined,
                        accent: true,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => PurchaseHistoryPage()));
                        },
                      ),
                    _PowerShortcut(
                      label: 'Notifications',
                      icon: Icons.notifications_none_rounded,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationsPage()));
                      },
                    ),
                    _PowerShortcut(
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppSettingsPage()));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _GroupLabel(label: 'ACCOUNT'),
                ProfileMenuTile(
                  icon: Icons.child_care_outlined,
                  label: 'Parental Controls',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.colorSurface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) {
                        return Consumer<ContentProvider>(
                          builder: (context, content, __) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Kids Mode',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Switch(
                                    value: content.showChildSafe,
                                    activeTrackColor: AppColors.colorOrange,
                                    inactiveTrackColor: AppColors.colorAccent.withValues(alpha: 0.35),
                                    onChanged: (_) => content.toggleSwitch(),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContactUsPage()));
                  },
                ),
                const _GroupLabel(label: 'LEGAL'),
                ProfileMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PrivacyPolicyPage()));
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.article_outlined,
                  label: 'Terms and Conditions',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TermsAndConditionsPage()));
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.replay_circle_filled_outlined,
                  label: 'Refund Policy',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RefundPolicyPage()));
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About Us',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutUsPage()));
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.star_border_rounded,
                  label: 'Rate Us',
                  onPressed: () => InAppReview.instance.openStoreListing(),
                ),
                if (user != null)
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    iconColor: AppColors.colorOrange,
                    labelColor: AppColors.colorOrange,
                    showChevron: false,
                    onPressed: () => _confirmLogout(authenticationProvider, contentProvider),
                  ),
                if (user != null)
                  TextButton(
                    onPressed: _confirmDelete,
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.redAccent, decoration: TextDecoration.underline),
                    ),
                  ),
                const SizedBox(height: 8),
                Center(
                  child: Text(_appVersion, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(AuthenticationProvider authenticationProvider, ContentProvider contentProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return GlassDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(FontAwesomeIcons.rightFromBracket, color: AppColors.colorPrimary, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Logout?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await authenticationProvider.logout();
                        final loginConfig = contentProvider.getLoginConfigConfirm();
                        contentProvider.removeContinueWatching();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        if (loginConfig == 'B' || loginConfig == 'C') {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (_) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.colorPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.colorSurface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete your account? This cannot be undone and subscriptions are not refunded.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextInput(
                controller: deleteController,
                hintText: 'Reason For Deletion',
                obscureText: false,
                isLast: true,
                padding: 5,
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
                NetworkService().post(
                  APIPath.deleteAccount,
                  {"reason": deleteController.text},
                  (data) async {
                    await authenticationProvider.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  (error) {},
                  () {},
                );
              },
              child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          const ChromeRule(width: double.infinity, thickness: 1),
        ],
      ),
    );
  }
}

class _PowerShortcut extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool accent;

  const _PowerShortcut({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.colorSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.colorHairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent ? AppColors.colorAccent : AppColors.colorOrange, size: 20),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
