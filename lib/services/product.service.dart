import 'package:http/http.dart' as http;

// constants
import 'package:flut_mart/utils/constants/product.constant.dart';
import 'package:flut_mart/utils/constants/endpoint.constant.dart';

// models
import 'package:flut_mart/utils/models/product.model.dart';

class ProductApiService {
  final http.Client client;

  static const baseUrl = Endpoint.baseUrl;
  static const getProducts = Endpoint.getProducts;
  static const getProduct = Endpoint.getProduct;

  ProductApiService({http.Client? client}) : client = client ?? http.Client();

  // Get all Products
  Future<List<Product>> getAllProducts() async {
    // final response = await client.get(Uri.parse('$baseUrl$getProducts'));

    // if (response.statusCode == 200) {
    // return List<Product>.from(
    //   jsonDecode(response.body).map(
    //     (x) => Product(
    //       id: x['id'],
    //       name: x['name'],
    //       image: x['image'],
    //       price: x['price'],
    //       discount: x['discount'],
    //       rating: x['rating'],
    //       description: x['description'],
    //       categoryId: x['categoryId'],
    //     ),
    //   ),
    // );
    // } else {
    //   throw Exception(response.body);
    // }
    return allProducts;
  }

  // Get Product by ID
  Future<Product> getProductById(String id) async {
    // final response = await client.get(Uri.parse('$baseUrl$getProduct/$id'));

    // if (response.statusCode == 200) {
    //   final product = jsonDecode(response.body);
    //   return Product(
    //     id: product['id'],
    //     name: product['name'],
    //     image: product['image'],
    //     price: product['price'],
    //     discount: product['discount'],
    //     rating: product['rating'],
    //     description: product['description'],
    //     categoryId: product['categoryId'],
    //   );
    // } else {
    //   throw Exception(response.body);
    // }
    return allProducts.firstWhere((product) => product.id.toString() == id);
  }

  // Get Products by Category ID
  Future<List<Product>> getProductsByCategoryId(
      int categoryId, int page, int sort) async {
    // final response = await client.get(Uri.parse('$baseUrl$getProducts'));

    // if (response.statusCode == 200) {
    //   final products = List<Product>.from(
    //     jsonDecode(response.body).map(
    //       (x) => Product(
    //         id: x['id'],
    //         name: x['name'],
    //         image: x['image'],
    //         price: x['price'],
    //         discount: x['discount'],
    //         rating: x['rating'],
    //         description: x['description'],
    //         categoryId: x['categoryId'],
    //       ),
    //     ),
    //   );
    //   return products.where((product) => product.categoryId == categoryId).toList();
    // } else {
    //   throw Exception(response.body);
    // }

    await Future.delayed(const Duration(seconds: 1));

    List<Product> allProd = allProducts
        .where((product) => product.categoryId == categoryId)
        .toList();

    // Sort products according to name
    if (sort == 0) {
      allProd
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (sort == 1) {
      allProd
          .sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    }

    // Sort products according to discounted price
    else if (sort == 2) {
      allProd.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
    } else if (sort == 3) {
      allProd.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
    }

    // Paginate the products
    return allProd.skip((page - 1) * 20).take(20).toList();
  }
}
