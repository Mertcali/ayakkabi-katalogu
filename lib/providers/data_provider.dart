import 'package:flutter/material.dart';
import '../models/shoe_model.dart';
import '../models/supabase_models.dart';
import '../services/supabase_service.dart';
import '../services/data_service.dart';

/// Veri sağlayıcı - Supabase veya yerel verilerden veri çeker
/// Supabase bağlantısı başarısız olursa yerel verilere düşer
class DataProvider extends ChangeNotifier {
  // State
  bool _isLoading = false;
  bool _useSupabase = true; // Supabase kullanımını açıp kapatabilirsiniz
  String? _error;

  // Cached data
  List<ShoeModel> _allShoes = [];
  List<ShoeModel> _newProducts = [];
  List<ShoeModel> _featuredProducts = [];
  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  List<BrandModel> _brands = [];
  List<CarouselSlideModel> _carouselSlides = [];
  List<ExploreSectionModel> _exploreSections = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get useSupabase => _useSupabase;
  String? get error => _error;
  List<ShoeModel> get allShoes => _allShoes;
  List<ShoeModel> get newProducts => _newProducts;
  List<ShoeModel> get featuredProducts => _featuredProducts;
  List<CategoryModel> get categories => _categories;
  List<SubcategoryModel> get subcategories => _subcategories;
  List<BrandModel> get brands => _brands;
  List<CarouselSlideModel> get carouselSlides => _carouselSlides;
  List<ExploreSectionModel> get exploreSections => _exploreSections;

  /// Supabase kullanımını değiştirir
  void setUseSupabase(bool value) {
    _useSupabase = value;
    notifyListeners();
  }

  /// Tüm verileri yükler
  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useSupabase) {
        await _loadFromSupabase();
      } else {
        _loadFromLocal();
      }
    } catch (e, stack) {
      _error = e.toString();
      debugPrint('❌ Supabase hatası: $e');
      _loadFromLocal();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Supabase'den veri yükler
  Future<void> _loadFromSupabase() async {
    final results = await Future.wait([
      SupabaseService.getProducts(),
      SupabaseService.getProducts(isNew: true, limit: 6),
      SupabaseService.getProducts(isFeatured: true, limit: 10),
      SupabaseService.getCategories(),
      SupabaseService.getSubcategories(),
      SupabaseService.getBrands(),
      SupabaseService.getCarouselSlides(),
      SupabaseService.getExploreSections(),
    ]);

    final allProducts = results[0] as List<ProductModel>;
    final newProductsList = results[1] as List<ProductModel>;
    final featuredProductsList = results[2] as List<ProductModel>;

    _allShoes = allProducts.map((p) => ShoeModel.fromProduct(p)).toList();
    _newProducts =
        newProductsList.map((p) => ShoeModel.fromProduct(p)).toList();
    _featuredProducts =
        featuredProductsList.map((p) => ShoeModel.fromProduct(p)).toList();
    _categories = results[3] as List<CategoryModel>;
    _subcategories = results[4] as List<SubcategoryModel>;
    _brands = results[5] as List<BrandModel>;
    _carouselSlides = results[6] as List<CarouselSlideModel>;
    _exploreSections = results[7] as List<ExploreSectionModel>;

    if (_allShoes.isEmpty) {
      _loadFromLocal();
    }
  }

  /// Yerel verilerden yükler (fallback)
  void _loadFromLocal() {
    _allShoes = DataService.getAllShoes();
    _newProducts = _allShoes.take(6).toList();
    _featuredProducts = _allShoes.take(10).toList();

    // Yerel kategori verileri (ana kategoriler)
    _categories = [
      CategoryModel(id: '1', name: 'Erkek', slug: 'erkek', displayOrder: 1),
      CategoryModel(id: '2', name: 'Kadın', slug: 'kadin', displayOrder: 2),
      CategoryModel(id: '3', name: 'Garson', slug: 'garson', displayOrder: 3),
      CategoryModel(id: '4', name: 'Filet', slug: 'filet', displayOrder: 4),
      CategoryModel(id: '5', name: 'Patik', slug: 'patik', displayOrder: 5),
      CategoryModel(id: '6', name: 'Bebe', slug: 'bebe', displayOrder: 6),
    ];

    // Yerel alt kategori verileri
    _subcategories = [
      SubcategoryModel(id: '1', name: 'Spor', slug: 'spor', displayOrder: 1),
      SubcategoryModel(
        id: '2',
        name: 'Klasik',
        slug: 'klasik',
        displayOrder: 2,
      ),
      SubcategoryModel(
        id: '3',
        name: 'Günlük',
        slug: 'gunluk',
        displayOrder: 3,
      ),
    ];

    // Yerel marka verileri
    _brands =
        DataService.getBrands()
            .asMap()
            .entries
            .map(
              (e) => BrandModel(
                id: e.key.toString(),
                name: e.value,
                slug: e.value.toLowerCase().replaceAll(' ', '-'),
                displayOrder: e.key,
              ),
            )
            .toList();

    // Boş carousel ve explore (yerel veri yok)
    _carouselSlides = [];
    _exploreSections = [];
  }

  /// Belirli bir kategori ve alt kategoriye ait ürünleri getirir
  Future<List<ShoeModel>> getShoesByCategoryAndSubcategory(
    String categorySlug,
    String subcategorySlug,
  ) async {
    if (_useSupabase) {
      try {
        final category = await SupabaseService.getCategoryBySlug(categorySlug);
        final subcategory = await SupabaseService.getSubcategoryBySlug(
          subcategorySlug,
        );

        if (category == null || subcategory == null) {
          return DataService.getShoesByGenderAndCategory(
            categorySlug,
            subcategorySlug,
          );
        }

        final products = await SupabaseService.getProducts(
          categoryId: category.id,
          subcategoryId: subcategory.id,
        );

        if (products.isEmpty) {
          return DataService.getShoesByGenderAndCategory(
            categorySlug,
            subcategorySlug,
          );
        }

        return products.map((p) => ShoeModel.fromProduct(p)).toList();
      } catch (e) {
        debugPrint('Supabase hatası: $e');
        return DataService.getShoesByGenderAndCategory(
          categorySlug,
          subcategorySlug,
        );
      }
    }
    return DataService.getShoesByGenderAndCategory(
      categorySlug,
      subcategorySlug,
    );
  }

  /// Belirli bir kategori, alt kategori ve markaya ait ürünleri getirir
  Future<List<ShoeModel>> getShoesByCategorySubcategoryAndBrand(
    String categorySlug,
    String subcategorySlug,
    String brandName,
  ) async {
    if (_useSupabase) {
      try {
        final category = await SupabaseService.getCategoryBySlug(categorySlug);
        final subcategory = await SupabaseService.getSubcategoryBySlug(
          subcategorySlug,
        );
        final brandSlug = brandName.toLowerCase().replaceAll(' ', '-');
        final brand = await SupabaseService.getBrandBySlug(brandSlug);

        if (category == null || subcategory == null || brand == null) {
          return DataService.getShoesByGenderCategoryAndBrand(
            categorySlug,
            subcategorySlug,
            brandName,
          );
        }

        final products = await SupabaseService.getProducts(
          categoryId: category.id,
          subcategoryId: subcategory.id,
          brandId: brand.id,
        );

        if (products.isEmpty) {
          return DataService.getShoesByGenderCategoryAndBrand(
            categorySlug,
            subcategorySlug,
            brandName,
          );
        }

        return products.map((p) => ShoeModel.fromProduct(p)).toList();
      } catch (e) {
        debugPrint('Supabase hatası: $e');
        return DataService.getShoesByGenderCategoryAndBrand(
          categorySlug,
          subcategorySlug,
          brandName,
        );
      }
    }
    return DataService.getShoesByGenderCategoryAndBrand(
      categorySlug,
      subcategorySlug,
      brandName,
    );
  }

  /// Belirli bir kategori ve alt kategoriye ait markaları getirir
  Future<List<String>> getBrandsByCategoryAndSubcategory(
    String categorySlug,
    String subcategorySlug,
  ) async {
    if (_useSupabase) {
      try {
        print(
          '🔍 DataProvider - Getting brands for categorySlug: $categorySlug, subcategorySlug: $subcategorySlug',
        );
        final category = await SupabaseService.getCategoryBySlug(categorySlug);
        final subcategory = await SupabaseService.getSubcategoryBySlug(
          subcategorySlug,
        );

        print(
          '📋 DataProvider - Found category: ${category?.name} (id: ${category?.id}), subcategory: ${subcategory?.name} (id: ${subcategory?.id})',
        );

        if (category == null || subcategory == null) {
          print(
            '⚠️ DataProvider - Category or subcategory not found, using local data',
          );
          return DataService.getBrandsByGenderAndCategory(
            categorySlug,
            subcategorySlug,
          );
        }

        final brands = await SupabaseService.getBrandsByCategoryAndSubcategory(
          category.id,
          subcategory.id,
        );

        if (brands.isEmpty) {
          print(
            '⚠️ DataProvider - No brands found in Supabase, using local data',
          );
          return DataService.getBrandsByGenderAndCategory(
            categorySlug,
            subcategorySlug,
          );
        }

        print('✅ DataProvider - Returning ${brands.length} brands');
        return brands.map((b) => b.name).toList();
      } catch (e) {
        debugPrint('Supabase hatası: $e');
        return DataService.getBrandsByGenderAndCategory(
          categorySlug,
          subcategorySlug,
        );
      }
    }
    return DataService.getBrandsByGenderAndCategory(
      categorySlug,
      subcategorySlug,
    );
  }

  /// Belirli bir kategoriye ait alt kategorileri getirir
  Future<List<String>> getSubcategoriesByCategory(String categorySlug) async {
    if (_useSupabase) {
      try {
        final category = await SupabaseService.getCategoryBySlug(categorySlug);

        if (category == null) {
          final localSubcategories = DataService.getCategoriesByGender(
            categorySlug,
          );
          return localSubcategories.map((c) => c.name).toList();
        }

        final subcategories = await SupabaseService.getSubcategoriesByCategory(
          category.id,
        );

        if (subcategories.isEmpty) {
          final localSubcategories = DataService.getCategoriesByGender(
            categorySlug,
          );
          return localSubcategories.map((c) => c.name).toList();
        }

        // Slug döndür, name değil
        return subcategories.map((c) => c.slug).toList();
      } catch (e) {
        debugPrint('Supabase hatası: $e');
        final localSubcategories = DataService.getCategoriesByGender(
          categorySlug,
        );
        return localSubcategories.map((c) => c.name).toList();
      }
    }
    final localSubcategories = DataService.getCategoriesByGender(categorySlug);
    return localSubcategories.map((c) => c.name).toList();
  }

  /// Belirli bir kategoriye ait alt kategori modellerini getirir
  Future<List<SubcategoryModel>> getSubcategoryModelsByCategory(
    String categorySlug,
  ) async {
    if (_useSupabase) {
      try {
        final category = await SupabaseService.getCategoryBySlug(categorySlug);

        if (category == null) {
          return [];
        }

        final subcategories = await SupabaseService.getSubcategoriesByCategory(
          category.id,
        );

        return subcategories;
      } catch (e) {
        debugPrint('Supabase hatası: $e');
        return [];
      }
    }
    return [];
  }

  /// Ürün arama
  Future<List<ShoeModel>> searchShoes(String query) async {
    if (_useSupabase) {
      try {
        final products = await SupabaseService.searchProducts(query);
        return products.map((p) => ShoeModel.fromProduct(p)).toList();
      } catch (e) {
        debugPrint('Supabase arama hatası: $e');
      }
    }
    // Yerel arama
    return _allShoes
        .where(
          (shoe) =>
              shoe.name.toLowerCase().contains(query.toLowerCase()) ||
              shoe.brand.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Cache'i temizle ve yeniden yükle
  Future<void> refresh() async {
    _allShoes = [];
    _newProducts = [];
    _featuredProducts = [];
    _categories = [];
    _subcategories = [];
    _brands = [];
    _carouselSlides = [];
    _exploreSections = [];
    await loadAllData();
  }
}
