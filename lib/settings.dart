import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/network/api_paths.dart';
import 'package:butterfly/providers/authentication_provider.dart';
import 'package:butterfly/services/network_service.dart';
import 'package:provider/provider.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final isLoggedIn = authenticationProvider.getUser() != null;

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.colorBackground,
        title: const Text("App Settings"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 60,
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.colorSurface,
              border: Border.all(color: AppColors.colorInputBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text(
                    "Notifications From Us",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 4),
                  child: Switch(
                    value: true,
                    activeTrackColor: AppColors.colorPrimary,
                    onChanged: (bool newValue) {
                      setState(() {});
                    },
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 60,
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.colorSurface,
              border: Border.all(color: AppColors.colorInputBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text(
                    "Play Background Music",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 4),
                  child: Switch(
                    value: true,
                    activeTrackColor: AppColors.colorPrimary,
                    onChanged: (bool newValue) {
                      setState(() {});
                    },
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 60,
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.colorSurface,
              border: Border.all(color: AppColors.colorInputBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text(
                    "Download Only On Wifi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 4),
                  child: Switch(
                    value: true,
                    activeTrackColor: AppColors.colorPrimary,
                    onChanged: (bool newValue) {
                      setState(() {});
                    },
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          DownloadQualityContainer(),
          SizedBox(height: 20),
          if (isLoggedIn)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  // Dismiss the dialog when tapping outside
                  barrierColor: Colors.black.withValues(alpha: 0.7),
                  // Blurred background effect
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delete Your Account?",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "Are you sure you want to permanently delete your account? This action cannot be undone, any active subscription is non refundable",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    NetworkService().post(
                                      APIPath.deleteAccount,
                                      {},
                                      (data) {
                                        Navigator.of(context).pop();
                                        authenticationProvider.logout();
                                      },
                                      (error) {},
                                      () {},
                                    );
                                  },
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 60,
                margin: EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      child: Text(
                        "Permanently Delete My Account",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.dangerous,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DownloadQualityContainer extends StatefulWidget {
  const DownloadQualityContainer({super.key});

  @override
  _DownloadQualityContainerState createState() =>
      _DownloadQualityContainerState();
}

class _DownloadQualityContainerState extends State<DownloadQualityContainer> {
  String selectedQuality = 'High';

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Download Quality',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.colorPrimary,
                ),
              ),
              ListTile(
                title: Text('Low'),
                onTap: () {
                  setState(() {
                    selectedQuality = 'Low';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Medium'),
                onTap: () {
                  setState(() {
                    selectedQuality = 'Medium';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('High'),
                onTap: () {
                  setState(() {
                    selectedQuality = 'High';
                  });
                  Navigator.pop(context);
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
    return Container(
      width: double.infinity,
      height: 60,
      margin: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.colorSurface,
        border: Border.all(color: AppColors.colorInputBorder),
      ),
      child: GestureDetector(
        onTap: _showBottomSheet,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 12),
              child: Text(
                "Default Download Quality",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 4),
              child: Row(
                children: [
                  Text(
                    "High",
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
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
