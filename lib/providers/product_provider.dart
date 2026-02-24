import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smk_product_app/config/env.dart';
import 'package:smk_product_app/models/product.dart';
import 'package:http/http.dart' as http;

class ProductProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // Sumber data utama (Dummy data untuk ilustrasi)
  List<Product> allProducts = [];
  // final _uuid = Uuid();

  String _query = '';
  String get query => _query;
  // String newId() => _uuid.v4();

   Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
   }

  List<Product> get products {
    if (_query.isEmpty) {
      return allProducts;
    } else {
      return allProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(_query.toLowerCase()) ||
                (product.description != null &&
                    product.description!.toLowerCase().contains(
                      _query.toLowerCase(),
                    )),
          )
          .toList();
    }
  }

  Future<void> getProducts() async {
    try {
      final response = await http.get(Uri.parse('${Env.baseUrl}/products'));
      if (response.statusCode == 200) {
        final List<Product> loadedProducts = productFromJson(
          response.body,
        ).toList();
        allProducts = loadedProducts;
        notifyListeners();
      } else {
        print('Error');
      }
    } catch (e) {
      print('Error');
    }
  }
  // Get, Add, Update, Delete

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Product? getById(String id) {
    for (final product in products) {
      if (product.id.toString() == id) {
        return product;
      }
    }
    return null;
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/products');
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode(product.toJson()),
      );

      debugPrint('POST URL: $url');
      debugPrint('POST RES: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        await getProducts();
      } else {
        debugPrint('Gagal ditambahkan');
      }
    } catch (e) {
      debugPrint('Error add: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final url = Uri.parse('${Env.baseUrl}/products/${product.id}');
      final response = await http.put(
        url,
        headers: await _authHeaders(),
        body: jsonEncode(product.toJson()),
      );

      debugPrint('PUT URL: $url');
      debugPrint('PUT RES: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        await getProducts();
      } else {
        debugPrint('Gagal diupdate');
      }
    } catch (e) {
      debugPrint('Error update: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
  try {
    final url = Uri.parse('${Env.baseUrl}/products/$id');

    final response = await http.delete(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({'id': id}),
    );

    debugPrint('DEL URL: $url');
    debugPrint('DEL RES: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      allProducts.removeWhere((p) => p.id.toString() == id);
      notifyListeners();
    } else {
      debugPrint('Gagal dihapus');
    }
  } catch (e) {
    debugPrint('Error delete: $e');
  }
}
}
