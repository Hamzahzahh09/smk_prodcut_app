import 'package:flutter/material.dart';
import 'package:smk_product_app/models/cart.dart';
import 'package:smk_product_app/providers/product_provider.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, Cart> _items = {};

  List<Cart> get items => _items.values.toList();

  int get totalQty => _items.values.fold(0, (sum, item) => sum + item.quantity);

  int totalPrice(ProductProvider productProvider) {
    print("Calculating total price..."); //
    return _items.values.fold(0, (sum, cartItem) {
      //
      final product = productProvider.getById(cartItem.productId);
      print("gampanggggggggggggggggggggggggggggggggggggggggggggg");
      ///
      if (product == null) return sum; //
      return sum + (product.price * cartItem.quantity); //
    });
  }

  void addToCart(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId] = Cart(
        productId: productId,
        quantity: _items[productId]!.quantity + 1,
      );
    } else {
      _items[productId] = Cart(productId: productId, quantity: 1);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        _items.remove(productId);
      } else {
        _items[productId] = Cart(productId: productId, quantity: quantity);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}