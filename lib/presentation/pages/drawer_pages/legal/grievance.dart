import 'package:flutter/material.dart';
import 'package:butterfly/constants/colors.dart';
import 'package:butterfly/providers/content_provider.dart';
import 'package:provider/provider.dart';

class GrievancePage extends StatelessWidget {
  const GrievancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.colorBackground,
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        title: Text("Grievance Redressal"),
      ),
      body: Container(
        color: AppColors.colorBackground,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                "If you have any grievances related to a title currently available in India or its age ratings, title, descriptions, synopses, content advisories or tags, or parental control features. You can raise a content grievance with our Grievance Redressal Officer on below mentioned details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                "Name: ${contentProvider.getGrievanceName()}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "Email: ${contentProvider.getGrievanceEmail()}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
