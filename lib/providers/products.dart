// Packages
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Models
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  static const url = 'https://shopappsflutter.firebaseio.com/';
  List<Product> _items = [];

  //var _showFavoritesOnly = false;
  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    var filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      final response = await http.get(url + 'products.json?auth=$authToken&$filterString');
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final favUrl =
          'https://shopappsflutter.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProduct = [];
      extractedData.forEach((productId, productData) {
        loadedProduct.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: favoriteData == null ? false : favoriteData[productId] ?? false,
          ),
        );
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoritesItem {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        url + 'products.json?auth=$authToken',
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
          'creatorId': userId
        }),
      );
      final newProdut = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      );
      _items.add(newProdut);
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      try {
        await http.patch(
          url + 'products/' + id.toString() + '.json?auth=$authToken',
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }),
        );
        _items[prodIndex] = product;
        notifyListeners();
      } catch (e) {
        print(e);
      }
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http
        .delete(url + 'products/' + id.toString() + '.json?auth=$authToken');
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
