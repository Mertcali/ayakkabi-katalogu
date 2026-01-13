// DEPRECATED: Bu dosya artık kullanılmıyor
// Tüm Supabase işlemleri DataProvider üzerinden yapılıyor
// Bu dosya silinebilir veya referans amaçlı tutulabilir

/*
import '../models/shoe_model.dart';
import '../models/supabase_models.dart';
import 'supabase_service.dart';
import 'data_service.dart' as local_data;

/// DEPRECATED - Supabase ile entegre edilmiş veri servisi
/// Mevcut DataService arayüzünü koruyarak Supabase'den veri çeker
/// Eğer Supabase bağlantısı yoksa veya hata olursa yerel verilere düşer
@Deprecated('Use DataProvider instead')
class DataServiceV2 {
  // Cache için
  static List<ProductModel>? _cachedProducts;
  static List<CategoryModel>? _cachedCategories;
  static List<SubcategoryModel>? _cachedSubcategories;
  static List<BrandModel>? _cachedBrands;
  static List<CarouselSlideModel>? _cachedCarouselSlides;
  static List<ExploreSectionModel>? _cachedExploreSections;

  /// Cache'i temizler
  static void clearCache() {
    _cachedProducts = null;
    _cachedCategories = null;
    _cachedSubcategories = null;
    _cachedBrands = null;
    _cachedCarouselSlides = null;
    _cachedExploreSections = null;
  }

  // ==================== PRODUCTS ====================

  /// Tüm ürünleri ShoeModel formatında getirir (mevcut UI için)
  static Future<List<ShoeModel>> getAllShoes() async {
    try {
      final products = await SupabaseService.getProducts();
      _cachedProducts = products;
      return products.map((p) => ShoeModel.fromProduct(p)).toList();
    } catch (e) {
      print('Supabase hatası, yerel veri kullanılıyor: $e');
      // Hata durumunda eski DataService'den veri al
      return local_data.DataService.getAllShoes();
    }
  }

  /// Cinsiyet ve kategoriye göre ürünler
  static Future<List<ShoeModel>> getShoesByGenderAndCategory(
    String genderSlug,
    String categorySlug,
  ) async {
    try {
      // Önce gender ve category ID'lerini bul
      final gender = await SupabaseService.getGenderBySlug(genderSlug);
      final category = await SupabaseService.getCategoryBySlug(categorySlug);

      if (gender == null || category == null) {
        return [];
      }

      final products = await SupabaseService.getProducts(
        genderId: gender.id,
        categoryId: category.id,
      );
      return products.map((p) => ShoeModel.fromProduct(p)).toList();
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  /// Cinsiyet, kategori ve markaya göre ürünler
  static Future<List<ShoeModel>> getShoesByGenderCategoryAndBrand(
    String genderSlug,
    String categorySlug,
    String brandSlug,
  ) async {
    try {
      final gender = await SupabaseService.getGenderBySlug(genderSlug);
      final category = await SupabaseService.getCategoryBySlug(categorySlug);
      final brand = await SupabaseService.getBrandBySlug(brandSlug);

      if (gender == null || category == null || brand == null) {
        return [];
      }

      final products = await SupabaseService.getProducts(
        genderId: gender.id,
        categoryId: category.id,
        brandId: brand.id,
      );
      return products.map((p) => ShoeModel.fromProduct(p)).toList();
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  /// Yeni ürünleri getirir (carousel için)
  static Future<List<ShoeModel>> getNewProducts({int limit = 6}) async {
    try {
      final products = await SupabaseService.getNewProducts(limit: limit);
      return products.map((p) => ShoeModel.fromProduct(p)).toList();
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  /// ID ile ürün getirir
  static Future<ShoeModel?> getShoeById(String id) async {
    try {
      final product = await SupabaseService.getProductById(id);
      return product != null ? ShoeModel.fromProduct(product) : null;
    } catch (e) {
      print('Supabase hatası: $e');
      return null;
    }
  }

  /// Ürün arama
  static Future<List<ShoeModel>> searchShoes(String query) async {
    try {
      final products = await SupabaseService.searchProducts(query);
      return products.map((p) => ShoeModel.fromProduct(p)).toList();
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  // ==================== GENDERS ====================

  /// Tüm cinsiyetleri getirir
  static Future<List<GenderModel>> getGenders() async {
    try {
      if (_cachedGenders != null) return _cachedGenders!;
      _cachedGenders = await SupabaseService.getGenders();
      return _cachedGenders!;
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  // ==================== CATEGORIES ====================

  /// Tüm kategorileri getirir
  static Future<List<CategoryModel>> getCategories() async {
    try {
      if (_cachedCategories != null) return _cachedCategories!;
      _cachedCategories = await SupabaseService.getCategories();
      return _cachedCategories!;
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  /// Cinsiyete göre kategoriler
  static Future<List<CategoryModel>> getCategoriesByGender(
    String genderSlug,
  ) async {
    try {
      final gender = await SupabaseService.getGenderBySlug(genderSlug);
      if (gender == null) return [];
      return await SupabaseService.getCategoriesByGender(gender.id);
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  // ==================== BRANDS ====================

  /// Tüm markaları getirir
  static Future<List<BrandModel>> getBrands() async {
    try {
      if (_cachedBrands != null) return _cachedBrands!;
      _cachedBrands = await SupabaseService.getBrands();
      return _cachedBrands!;
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  /// Cinsiyet ve kategoriye göre markalar
  static Future<List<BrandModel>> getBrandsByGenderAndCategory(
    String genderSlug,
    String categorySlug,
  ) async {
    try {
      final gender = await SupabaseService.getGenderBySlug(genderSlug);
      final category = await SupabaseService.getCategoryBySlug(categorySlug);

      if (gender == null || category == null) return [];

      return await SupabaseService.getBrandsByGenderAndCategory(
        gender.id,
        category.id,
      );
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  // ==================== CAROUSEL ====================

  /// Carousel slide'larını getirir
  static Future<List<CarouselSlideModel>> getCarouselSlides() async {
    try {
      if (_cachedCarouselSlides != null) return _cachedCarouselSlides!;
      _cachedCarouselSlides = await SupabaseService.getCarouselSlides();
      return _cachedCarouselSlides!;
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  // ==================== EXPLORE SECTIONS ====================

  /// Keşfet bölümlerini getirir
  static Future<List<ExploreSectionModel>> getExploreSections() async {
    try {
      if (_cachedExploreSections != null) return _cachedExploreSections!;
      _cachedExploreSections = await SupabaseService.getExploreSections();
      return _cachedExploreSections!;
    } catch (e) {
      print('Supabase hatası: $e');
      return [];
    }
  }

  // ==================== COMPATIBILITY HELPERS ====================

  /// Eski format için cinsiyet listesi (string olarak)
  static Future<List<String>> getGenderSlugs() async {
    final genders = await getGenders();
    return genders.map((g) => g.slug).toList();
  }

  static Future<List<String>> getBrandNames() async {
    final brands = await getBrands();
    return brands.map((b) => b.name).toList();
  }
}
*/

// Dosya tamamen yoruma alındı - artık kullanılmıyor
