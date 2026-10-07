import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final String baseUrl =
      'https://backend-api-production-237c.up.railway.app';

  // GET semua produk
  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data
          .map((item) => Product.fromJson(item))
          .toList();
    }

    throw Exception(
      'Gagal mengambil produk. Status: ${response.statusCode}',
    );
  }

  // POST - tambah produk
  Future<void> addProduct(
    String name,
    int price,
    int stock,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'stock': stock,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Gagal menambah produk. Status: ${response.statusCode}',
      );
    }
  }

  // PUT - edit produk
  Future<void> updateProduct(
    int id,
    String name,
    int price,
    int stock,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'stock': stock,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengedit produk. Status: ${response.statusCode}',
      );
    }
  }

  // DELETE - hapus produk
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Gagal menghapus produk. Status: ${response.statusCode}',
      );
    }
  }
}