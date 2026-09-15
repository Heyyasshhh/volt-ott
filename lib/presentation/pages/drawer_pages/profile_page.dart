import 'package:flutter/material.dart';
import 'package:chill/constants/colors.dart';
import 'package:chill/network/api_paths.dart';
import 'package:chill/presentation/pages/home_page.dart';
import 'package:chill/presentation/purchase_history_page.dart';
import 'package:chill/services/network_service.dart';
import 'package:chill/presentation/components/controls/text_input.dart';
import 'package:chill/presentation/components/controls/more_widget.dart';
import 'package:chill/presentation/pages/payment/plans_list_page.dart';
import 'package:chill/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController deleteController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    deleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    if (user != null) {
      usernameController.text = user.username!;
    }
    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Profile Header Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.colorBackground.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.colorPrimary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/chill-text.png",
                        height: 60,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.getUniqueCredential() ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Name Input Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "Full Name",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextInput(
                            controller: usernameController,
                            hintText: "Full Name",
                            obscureText: false,
                            isLast: true,
                            padding: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            final username = usernameController.text;
                            if (username.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter your name")),
                              );
                            } else if (username.length > 15) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Username must be less than 15 characters")),
                              );
                            } else if (username == user?.username) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Profile Updated Successfully")),
                              );
                            } else {
                              await NetworkService().post(
                                APIPath.updateProfile,
                                {
                                  "username": usernameController.text.toString(),
                                },
                                (data) {
                                  authenticationProvider.updateUsername(usernameController.text);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Profile Updated Successfully")),
                                  );
                                },
                                (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Profile Updated Failed")),
                                  );
                                },
                                () {},
                              );
                            }
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: AppColors.colorPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subscription Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.colorBackground.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.colorPrimary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.subscriptions,
                            color: AppColors.colorPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Current Plan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.userSubscription == null
                            ? "No Active Plan"
                            : "${user?.userSubscription!.planName}\nValid Until ${user?.userSubscription!.getDisplayEndTime()}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    MoreWidget(
                      text: "Sync Subscription",
                      icon: Icons.sync,
                      onPressed: () async {
                        authenticationProvider.init((user) {
                          if (user.userSubscription != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Sync Successful, You have an active plan")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Sync Successful, You have no active plan")),
                            );
                          }
                        }, (error) {}, sync: true);
                      },
                    ),
                    MoreWidget(
                      text: "Purchase History",
                      icon: Icons.history,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PurchaseHistoryPage(),
                          ),
                        );
                      },
                    ),
                    if (user?.userSubscription == null)
                      MoreWidget(
                        text: "Subscribe Now",
                        icon: Icons.upgrade,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PlansListPage(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Delete Account Text
              Center(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Warning',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.black,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Are you sure you want to delete your account?, this step cannot be undone, your subscription will NOT be refunded, all data associated with your account will permanently be removed',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              TextInput(
                                controller: deleteController,
                                hintText: "Reason For Deletion",
                                obscureText: false,
                                isLast: true,
                                padding: 5,
                              )
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                NetworkService().post(
                                  APIPath.deleteAccount,
                                  {"reason": deleteController.text},
                                  (data) async {
                                    await authenticationProvider.logout();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  },
                                  (error) {},
                                  () {},
                                );
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "Delete Account",
                    style: TextStyle(
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
