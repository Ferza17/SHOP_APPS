import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String userId;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
    this.userId
  });

  Future<void> toggleFavoriteStatus(String token,String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://shopappsflutter.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      await http.put(
        url,
        body: json.encode(
          isFavorite
        ),
      );
    } catch (e) {
      isFavorite = oldStatus;
      notifyListeners();
      print(e);
      throw e;
    }
  }
}
