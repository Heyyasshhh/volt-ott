import 'package:flutter/material.dart';
import 'package:chill/models/media/media_item.dart';
import 'package:chill/models/media/section.dart';
import 'package:chill/presentation/components/controls/text_input.dart';
import 'package:chill/presentation/components/media/media_item.dart';
import 'package:chill/providers/content_provider.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';

class SearchPage extends StatefulWidget {
  final Section? section;

  const SearchPage({super.key, this.section});

  @override
  State<SearchPage> createState() => _ShowsPageState();
}

class _ShowsPageState extends State<SearchPage> {
  final List<BaseItem> _shows = [];
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    if (_shows.isEmpty && searchController.text.toString().isEmpty) {
      if (widget.section != null) {
        // Use allBaseItems for "view all" page to show all items from the section
        _shows.addAll(widget.section!.allBaseItems.where((item) => item.isReleased));
      } else {
        _shows.addAll(contentProvider.getSeries().where((item) => item.isReleased));
        _shows.addAll(contentProvider.getMovies().where((item) => item.isReleased));
      }
    }
    searchController.addListener(() {
      _shows.clear();
      if (searchController.text.toString().isEmpty) {
        setState(() {
          _shows.addAll(contentProvider.getMovies().where((item) => item.isReleased));
          _shows.addAll(contentProvider.getSeries().where((item) => item.isReleased));
        });
      } else {
        setState(() {
          _shows.addAll((contentProvider.getMovies().where((movie) => movie.isReleased && movie.title.toLowerCase().contains(searchController.text.toLowerCase()))));
          _shows.addAll((contentProvider.getSeries().where((series) => series.isReleased && series.title.toLowerCase().contains(searchController.text.toLowerCase()))));
        });
      }
    });
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.colorBackground,
        appBar: widget.section != null
            ? AppBar(
                backgroundColor: AppColors.colorBackground,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  widget.section!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                if (widget.section == null)
                  TextInput(
                    controller: searchController,
                    hintText: "Search for title, topic or keyword",
                    obscureText: false,
                    isLast: true,
                    padding: 10,
                  ),
                if (widget.section == null)
                  const SizedBox(height: 10),
                if (contentProvider.getStatus() == Status.fetching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return const ShimmerMediaItem();
                      },
                    ),
                  )
                else if (_shows.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 8,
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2 / 3,
                          ),
                          itemCount: _shows.length,
                          itemBuilder: (context, index) {
                            return MediaItem(baseItem: _shows[index]);
                          },
                        );
                      },
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: const Center(
                      child: Text(
                        "Oops! We don't have this content at the moment",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
