import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductService {
  final SupabaseClient _supabase;

  ProductService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Product>> getLatestProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          profiles (
            id,
            nama,
            email,
            nim,
            kampus,
            fakultas,
            program_studi
          ),
          categories (
            id,
            name
          )
        ''')
        .eq('status', 'available')
        .order('created_at', ascending: false)
        .limit(10);

    return response.map<Product>((item) => Product.fromMap(item)).toList();
  }

  Future<List<Product>> getMabaProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
        *,
        profiles (
          id,
          nama,
          email,
          nim,
          kampus,
          fakultas,
          program_studi
        ),
        categories (
          id,
          name
        )
      ''')
        .eq('status', 'available')
        .order('created_at', ascending: false);

    final products = response
        .map<Product>((item) => Product.fromMap(item))
        .toList();

    const mabaKeywords = [
      'almamater',
      'ospek',
      'kemeja',
      'putih',
      'hitam',
      'pantofel',
      'sepatu',
      'tas',
      'buku',
      'alat tulis',
      'jas',
      'celana',
      'rok',
      'dasi',
    ];

    return products.where((product) {
      final searchableText = '${product.name} ${product.categoryName}'
          .toLowerCase();

      return mabaKeywords.any((keyword) => searchableText.contains(keyword));
    }).toList();
  }

  Future<Product> getProductById(String id) async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          profiles (
            id,
            nama,
            email,
            nim,
            kampus,
            fakultas,
            program_studi
          ),
          categories (
            id,
            name
          )
        ''')
        .eq('id', id)
        .single();

    return Product.fromMap(response);
  }
}
