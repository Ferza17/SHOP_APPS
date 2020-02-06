import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Provider
import '../providers/products.dart';

// Widget
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: productData.items.length,
          itemBuilder: (_, i) => UserProductItem(
            productData.items[i].title,
            productData.items[i].imageUrl,
          ),
        ),
      ),
    );
  }
}
