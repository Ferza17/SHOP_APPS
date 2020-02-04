import 'package:flutter/material.dart';
import '../providers/product.dart';

// Widget
import '../widgets/products_grid.dart';

class ProductsOverviewScreen extends StatelessWidget {
  final List<Product> loadedProduct = [
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Shop',
        ),
      ),
      body: ProductsGrid(),
    );
  }
}

