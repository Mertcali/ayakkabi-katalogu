import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_models.dart';

/// Supabase veritabanı servisi
/// Tüm veritabanı işlemlerini bu sınıf üzerinden yaparız
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ==================== CATEGORIES (ANA KATEGORİLER) ====================

  /// Tüm ana kategorileri getirir (Erkek, Kadın, Garson, Filet, Patik, Bebe)
  static Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  /// Slug ile ana kategori getirir
  static Future<CategoryModel?> getCategoryBySlug(String slug) async {
    final response =
        await _client
            .from('categories')
            .select()
            .eq('slug', slug)
            .eq('is_active', true)
            .maybeSingle();

    return response != null ? CategoryModel.fromJson(response) : null;
  }

  // ==================== SUBCATEGORIES (ALT KATEGORİLER) ====================

  /// Tüm alt kategorileri getirir (Spor, Klasik, Günlük, vb.)
  static Future<List<SubcategoryModel>> getSubcategories() async {
    final response = await _client
        .from('subcategories')
        .select()
        .eq('is_active', true)
        .order('display_order');

    return (response as List)
        .map((json) => SubcategoryModel.fromJson(json))
        .toList();
  }

  /// Belirli bir ana kategoriye ait alt kategorileri getirir
  static Future<List<SubcategoryModel>> getSubcategoriesByCategory(
    String categoryId,
  ) async {
    final response = await _client
        .from('category_subcategories')
        .select('subcategories(*)')
        .eq('category_id', categoryId);

    return (response as List)
        .map((json) => SubcategoryModel.fromJson(json['subcategories']))
        .where((subcategory) => subcategory.isActive)
        .toList();
  }

  /// Slug ile alt kategori getirir
  static Future<SubcategoryModel?> getSubcategoryBySlug(String slug) async {
    final response =
        await _client
            .from('subcategories')
            .select()
            .eq('slug', slug)
            .eq('is_active', true)
            .maybeSingle();

    return response != null ? SubcategoryModel.fromJson(response) : null;
  }

  // ==================== BRANDS ====================

  /// Tüm aktif markaları getirir
  static Future<List<BrandModel>> getBrands() async {
    final response = await _client
        .from('brands')
        .select()
        .eq('is_active', true)
        .order('display_order');

    return (response as List).map((json) => BrandModel.fromJson(json)).toList();
  }

  /// Belirli bir kategori ve alt kategoride ürünü olan markaları getirir
  static Future<List<BrandModel>> getBrandsByCategoryAndSubcategory(
    String categoryId,
    String subcategoryId,
  ) async {
    print(
      '🔍 SupabaseService - Fetching brands for categoryId: $categoryId, subcategoryId: $subcategoryId',
    );
    // Bu kategori ve alt kategoride ürünü olan markaları bulalım
    final response = await _client
        .from('products')
        .select('brand_id, brands!inner(*)')
        .eq('category_id', categoryId)
        .eq('subcategory_id', subcategoryId)
        .eq('is_active', true)
        .eq('brands.is_active', true);

    print('📦 SupabaseService - Raw response: $response');

    // Tekrarsız markaları döndür
    final brandMap = <String, BrandModel>{};
    for (final item in response as List) {
      if (item['brands'] != null) {
        final brand = BrandModel.fromJson(item['brands']);
        brandMap[brand.id] = brand;
      }
    }

    print('✅ SupabaseService - Found ${brandMap.length} unique brands');
    return brandMap.values.toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  /// Slug ile marka getirir
  static Future<BrandModel?> getBrandBySlug(String slug) async {
    final response =
        await _client
            .from('brands')
            .select()
            .eq('slug', slug)
            .eq('is_active', true)
            .maybeSingle();

    return response != null ? BrandModel.fromJson(response) : null;
  }

  // ==================== COLORS ====================

  /// Tüm renkleri getirir
  static Future<List<ColorModel>> getColors() async {
    final response = await _client
        .from('colors')
        .select()
        .order('display_order');

    return (response as List).map((json) => ColorModel.fromJson(json)).toList();
  }

  // ==================== PRODUCTS ====================

  /// Tüm aktif ürünleri getirir (ilişkili verilerle birlikte)
  static Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? subcategoryId,
    String? brandId,
    bool? isNew,
    bool? isFeatured,
    int? limit,
  }) async {
    var query = _client
        .from('products')
        .select('''
      *,
      brands(*),
      categories(*),
      subcategories(*),
      colors(*),
      product_images(*)
    ''')
        .eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (subcategoryId != null) {
      query = query.eq('subcategory_id', subcategoryId);
    }
    if (brandId != null) {
      query = query.eq('brand_id', brandId);
    }
    if (isNew != null) {
      query = query.eq('is_new', isNew);
    }
    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }

    final orderedQuery = query.order('display_order');

    final response =
        limit != null ? await orderedQuery.limit(limit) : await orderedQuery;

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  /// ID ile ürün getirir
  static Future<ProductModel?> getProductById(String id) async {
    final response =
        await _client
            .from('products')
            .select('''
      *,
      brands(*),
      categories(*),
      subcategories(*),
      colors(*),
      product_images(*)
    ''')
            .eq('id', id)
            .maybeSingle();

    return response != null ? ProductModel.fromJson(response) : null;
  }

  /// Slug ile ürün getirir
  static Future<ProductModel?> getProductBySlug(String slug) async {
    final response =
        await _client
            .from('products')
            .select('''
      *,
      brands(*),
      categories(*),
      subcategories(*),
      colors(*),
      product_images(*)
    ''')
            .eq('slug', slug)
            .eq('is_active', true)
            .maybeSingle();

    return response != null ? ProductModel.fromJson(response) : null;
  }

  /// Yeni ürünleri getirir (carousel için)
  static Future<List<ProductModel>> getNewProducts({int limit = 6}) async {
    return getProducts(isNew: true, limit: limit);
  }

  /// Öne çıkan ürünleri getirir
  static Future<List<ProductModel>> getFeaturedProducts({
    int limit = 10,
  }) async {
    return getProducts(isFeatured: true, limit: limit);
  }

  /// Ürün arama
  static Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _client
        .from('products')
        .select('''
      *,
      brands(*),
      categories(*),
      subcategories(*),
      colors(*),
      product_images(*)
    ''')
        .or('name.ilike.%$query%,description.ilike.%$query%')
        .eq('is_active', true);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  // ==================== CAROUSEL ====================

  /// Aktif carousel slide'larını getirir
  static Future<List<CarouselSlideModel>> getCarouselSlides() async {
    final response = await _client
        .from('carousel_slides')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => CarouselSlideModel.fromJson(json))
        .toList();
  }

  // ==================== EXPLORE SECTIONS ====================

  /// Aktif keşfet bölümlerini getirir
  static Future<List<ExploreSectionModel>> getExploreSections() async {
    final response = await _client
        .from('explore_sections')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => ExploreSectionModel.fromJson(json))
        .toList();
  }

  // ==================== APP SETTINGS ====================

  /// Uygulama ayarını getirir
  static Future<String?> getAppSetting(String key) async {
    final response =
        await _client
            .from('app_settings')
            .select('value')
            .eq('key', key)
            .maybeSingle();

    return response?['value'] as String?;
  }

  /// Birden fazla uygulama ayarını getirir
  static Future<Map<String, String>> getAppSettings(List<String> keys) async {
    final response = await _client
        .from('app_settings')
        .select('key, value')
        .inFilter('key', keys);

    final settings = <String, String>{};
    for (final item in response as List) {
      settings[item['key'] as String] = item['value'] as String? ?? '';
    }
    return settings;
  }

  // ==================== STORAGE (Görseller) ====================

  /// Storage'dan görsel URL'i oluşturur
  static String getImageUrl(String path) {
    return _client.storage.from('product-images').getPublicUrl(path);
  }

  /// Görsel yükler (admin panel için)
  static Future<String?> uploadImage(String path, Uint8List bytes) async {
    try {
      await _client.storage.from('product-images').uploadBinary(path, bytes);
      return getImageUrl(path);
    } catch (e) {
      debugPrint('Görsel yükleme hatası: $e');
      return null;
    }
  }
}
