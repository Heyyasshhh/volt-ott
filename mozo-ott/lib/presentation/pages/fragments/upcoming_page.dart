import 'package:flutter/material.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/presentation/components/media/upcoming_item.dart';
import 'package:mozo/providers/content_provider.dart';
import 'package:provider/provider.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';

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
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 72,
        title: const PageHeader(title: 'Upcoming', showBack: true),
      ),
      backgroundColor: AppColors.colorBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SafeArea(
              child: contentProvider.getStatus() == Status.fetched &&
                      contentProvider.getUpcoming().isEmpty
                  ? const EmptyState(
                      icon: Icons.upcoming_outlined,
                      title: 'More coming soon',
                      subtitle: 'New titles will appear here as they are announced.',
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
