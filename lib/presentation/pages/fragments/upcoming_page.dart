import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';
import 'package:volt/presentation/components/media/upcoming_item.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/providers/content_provider.dart';
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
    final gutter = AppLayout.gutter(context);
    final upcoming = contentProvider.getUpcoming();
    final loading = contentProvider.getStatus() == Status.fetching;
    final empty = contentProvider.getStatus() == Status.fetched && upcoming.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
          child: empty
              ? const EmptyState(
                  icon: Icons.upcoming_outlined,
                  title: 'More coming soon',
                  subtitle: 'New titles will appear here as they are announced.',
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (Navigator.canPop(context)) ...[
                              CircleIconButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                size: 40,
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text('Upcoming', style: AppTextStyles.displayTitle.copyWith(fontSize: 32)),
                            const SizedBox(height: 6),
                            Text('Coming soon', style: AppTextStyles.meta),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.colorHairline, height: 1),
                          ],
                        ),
                      ),
                    ),
                    if (loading)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 16),
                              child: ChromeFrame(child: const UpcomingItemShimmer()),
                            );
                          },
                          childCount: 4,
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 16),
                              child: ChromeFrame(
                                child: UpcomingItem(baseItem: upcoming[index]),
                              ),
                            );
                          },
                          childCount: upcoming.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                ),
        ),
      ),
    );
  }
}
