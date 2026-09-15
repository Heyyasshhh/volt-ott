import 'package:flutter/material.dart';
import 'package:chill/constants/colors.dart';
import 'package:chill/presentation/components/media/upcoming_item.dart';
import 'package:chill/providers/content_provider.dart';
import 'package:provider/provider.dart';

class UpcomingPage extends StatefulWidget {
  const UpcomingPage({super.key});

  @override
  State<UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Upcoming Shows", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.colorBackground,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.colorBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SafeArea(
              child: contentProvider.getStatus() == Status.fetched &&
                      contentProvider.getUpcoming().isEmpty
                  ? const Center(
                      child: Text("More Upcoming Content Coming Soon",
                          style: TextStyle(color: Colors.white)),
                    )
                  : contentProvider.getStatus() == Status.fetching
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return const UpcomingItemShimmer();
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: contentProvider.getUpcoming().length,
                          itemBuilder: (context, index) {
                            return UpcomingItem(baseItem: contentProvider.getUpcoming()[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
