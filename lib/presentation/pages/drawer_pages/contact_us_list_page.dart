import 'package:flutter/material.dart';
import 'package:chill/presentation/components/controls/more_widget.dart';
import 'package:chill/presentation/pages/drawer_pages/contact_us_page.dart';

import '../../../services/logging_service.dart';

class ContactUsListPage extends StatefulWidget {
  const ContactUsListPage({super.key});

  @override
  State<ContactUsListPage> createState() => _ContactUsListPageState();
}

class _ContactUsListPageState extends State<ContactUsListPage> {
  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("contact_us_list_page");
    LoggingService().setCrashlyticsScreen("contact_us_list_page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text("Legal Information"),
      ),
      backgroundColor: Colors.black,
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
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: const Text(
                        "Tap The Options Below For More Info",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    MoreWidget(
                      text: "Concern/Queries",
                      icon: Icons.contact_page,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ContactUsPage(),
                        ));
                      },
                    ),
                    MoreWidget(
                      text: "Help/Support",
                      icon: Icons.privacy_tip,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ContactUsPage(),
                        ));
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
}
