import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smk_product_app/config/env.dart';
import 'package:smk_product_app/data/dummy_kurir.dart';
import 'package:smk_product_app/data/dummy_metode.dart';
import 'package:smk_product_app/models/kurir.dart';
import 'package:smk_product_app/models/metode.dart';
import 'package:http/http.dart' as http;

class CheckoutProvider extends ChangeNotifier {
  List<Metode> get dataMetode => dummyMetode;
  List<Kurir> get dataKurir => dummyKurirs;

  Future<bool> simpanPembayaran(
    String name,
    String address,
    String phone,
    int subtotal,
    int total,
    List<Map<String, dynamic>> details,
  ) async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: "token");
      final body = {
        "recipient_name": name,
        "recipient_address": address,
        "recipient_phone": phone,
        "subtotal": subtotal,
        "total_amount": total,
        "details": details,
      };

      final response = await http.post(
        Uri.parse('${Env.baseUrl}/transactions'), // ganti endpoint sesuai API
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}',
        },
        body: jsonEncode(body),
      );
      print(response.statusCode);
      print(response.body);
      print(jsonEncode(body));
      if (response.statusCode == 201) {
        print("Transaksi Success");
        return true;
      } else {
        print("Transaction failed");
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
