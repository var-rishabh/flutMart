import 'package:flutter/material.dart';

import 'package:flut_mart/utils/helper/responsive.dart';
import 'package:flut_mart/utils/models/category.model.dart';
import 'package:flut_mart/services/category.service.dart';

import 'package:flut_mart/screens/navigation/carousel/carousel.dart';
import 'package:flut_mart/widgets/category_card.dart';
import 'package:flut_mart/widgets/search_bar.dart';
import 'package:flut_mart/widgets/web_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const HomeScreen({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryApiService _categoryApiService = CategoryApiService();
  List<Category> _categories = [];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  Future<void> fetchCategories() async {
    final List<Category> categories = await _categoryApiService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int halfLength = (_categories.length / 2).ceil();

    return SingleChildScrollView(
      child: Column(
        children: [
          Responsive.isDesktop(context)
              ? WebAppBar(
                  currentIndex: widget.currentIndex,
                  onTabSelected: widget.onTabSelected,
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      KSearchBar(
                        controller: _searchController,
                        hintText: 'What are you looking for?',
                        onChanged: (query) {
                          setState(() {
                            searchQuery = query;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Deliver to ',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          Text(
                            'Hitech City, Hyderabad',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
          const SizedBox(height: 20),
          if (!Responsive.isDesktop(context))
            _categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : MobileCategory(
                    halfLength: halfLength,
                    categories: _categories,
                    widget: widget,
                  ),
          Padding(
            padding: Responsive.isDesktop(context)
                ? const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 20,
                  )
                : const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: const KCarousel(),
          ),
          Responsive.isDesktop(context)
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 50),
                      LaptopCategory(
                        categories: _categories,
                        widget: widget,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

// Mobile Category
class MobileCategory extends StatelessWidget {
  final int halfLength;
  final List<Category> _categories;
  final HomeScreen widget;

  const MobileCategory({
    super.key,
    required this.halfLength,
    required List<Category> categories,
    required this.widget,
  }) : _categories = categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: halfLength,
            itemBuilder: (context, index) {
              final Category category = _categories[index];
              return CategoryCard(
                key: Key(category.id.toString()),
                id: category.id,
                title: category.name,
                image: category.image,
                boxSize: 80,
                currentIndex: widget.currentIndex,
                onTabSelected: widget.onTabSelected,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length - halfLength,
            itemBuilder: (context, index) {
              final Category category = _categories[halfLength + index];
              return CategoryCard(
                key: Key(category.id.toString()),
                id: category.id,
                title: category.name,
                image: category.image,
                boxSize: 80,
                currentIndex: widget.currentIndex,
                onTabSelected: widget.onTabSelected,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Laptop Category
class LaptopCategory extends StatelessWidget {
  final List<Category> _categories;
  final HomeScreen widget;

  const LaptopCategory({
    super.key,
    required List<Category> categories,
    required this.widget,
  }) : _categories = categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 80,
        mainAxisExtent: 200,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final Category category = _categories[index];
        return CategoryCard(
          key: Key(category.id.toString()),
          id: category.id,
          title: category.name,
          image: category.image,
          boxSize: 160,
          currentIndex: widget.currentIndex,
          onTabSelected: widget.onTabSelected,
        );
      },
    );
  }
}
