import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Providers
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  static const url = 'https://shopappsflutter.firebaseio.com/';
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final response = await http.get(url + 'orders.json');
    final List<OrderItem> loadedOrders = [];
    final extreactedData = json.decode(response.body) as Map<String, dynamic>;
    if(extreactedData == null) {
      return;
    }
    extreactedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final response = await http.post(
      url + 'orders.json',
      body: json.encode(
        ({
          "amount": total,
          "dateTime": timeStamp.toIso8601String(),
          "products": cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }),
      ),
    );
    _orders.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['_id'],
          amount: total,
          dateTime: timeStamp,
          products: cartProducts),
    );
    notifyListeners();
  }
}
