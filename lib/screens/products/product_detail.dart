import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// models
import 'package:flut_mart/utils/models/product.model.dart';

// services
import 'package:flut_mart/services/cart.service.dart';
import 'package:flut_mart/services/favourite.service.dart';
import 'package:flut_mart/services/product.service.dart';

// widgets
import 'package:flut_mart/widgets/app_bar.dart';
import 'package:flut_mart/widgets/snackbar.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details';

  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductApiService _productApiService = ProductApiService();
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();
  Product? _product;
  bool _isInCart = false;
  bool _isFavorite = false;
  int _productId = 0;
  bool _isInitialized = false;
  int _current = 0;

  // Add a variable to keep track of the selected size
  String _selectedSize = "S";

  Future<void> _loadProductDetails() async {
    final product =
        await _productApiService.getProductById(_productId.toString());
    final isInCart = await _cartService.isInCart(product.id.toString());
    final isFavorite =
        await _favoritesService.isFavorite(product.id.toString());

    setState(() {
      _product = product;
      _isInCart = isInCart;
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoritesService.removeFromFavorites(_product!.id.toString());
    } else {
      await _favoritesService.addToFavorites(_product!.id.toString());
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (mounted) {
      KSnackBar.show(
        context: context,
        label: _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
        type: "success",
      );
    }
  }

  Future<void> _toggleCart() async {
    if (_isInCart) {
      await _cartService.removeFromCart(_product!.id.toString());
    } else {
      await _cartService.addToCart(_product!.id.toString());
    }
    setState(() {
      _isInCart = !_isInCart;
    });
    if (mounted) {
      KSnackBar.show(
        context: context,
        label: _isInCart ? 'Added to Cart' : 'Removed from Cart',
        type: "success",
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;

      setState(() {
        _productId = arguments['productId'] ?? 0;
      });

      _loadProductDetails();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      appBar: KAppBar(
        currentIndex: arguments['currentIndex'],
        onTabSelected: arguments['onTabSelected'],
        needBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(),
              const SizedBox(height: 40),
              _buildProductDetails(),
              const SizedBox(height: 16),
              Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: ElevatedButton(
                    onPressed: _toggleCart,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          _isInCart ? 'Remove from Cart' : 'Add to Cart',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 350,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: [_product!.image, _product!.image].map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 2; i++)
                Container(
                  width: _current == i ? 30 : 10,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius:
                        _current == i ? BorderRadius.circular(5) : null,
                    shape: _current == i ? BoxShape.rectangle : BoxShape.circle,
                    color: _current == i
                        ? Theme.of(context).dividerColor
                        : Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _product!.name,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // add to favorites button
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 30,
                color: _isFavorite
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          _product!.description,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'In Stock',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Free Shipping',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${_product!.discountedPrice}',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '\$${_product!.price}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Theme.of(context).dividerColor,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 24,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _product!.rating.toString(),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Text(
              '(${_product!.noOfReviews} Reviews)',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.blue,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Size",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        // Display size buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["S", "M", "X", "XL", "XXL"].map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                // margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  size,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
