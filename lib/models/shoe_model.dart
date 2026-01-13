import 'supabase_models.dart';

class ShoeModel {
  final String id;
  final String name;
  final String brand;
  final String color;
  final String sizeRange;
  final String imagePath; // Ana görsel (geriye dönük uyumluluk için)
  final List<String> images; // Ürünün tüm görselleri
  final String category;
  final String gender;

  ShoeModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.color,
    required this.sizeRange,
    required this.imagePath,
    List<String>? images, // Opsiyonel, verilmezse imagePath kullanılır
    required this.category,
    required this.gender,
  }) : images = images ?? [imagePath];

  /// Veritabanındaki kısa path'i tam asset path'e çevirir
  /// Örnek: "kadin/spor/nike_airforce1_36-40/beyaz.jpg" -> "assets/images/kadin/spor/nike_airforce1_36-40/beyaz.jpg"
  static String _toAssetPath(String dbPath) {
    if (dbPath.isEmpty) return 'assets/images/placeholder.jpg';
    // http ile başlıyorsa URL olarak döndür (Storage URL)
    if (dbPath.startsWith('http')) return dbPath;
    // Zaten tam path ise olduğu gibi döndür
    if (dbPath.startsWith('assets/images/')) return dbPath;
    // "assets/" ile başlıyorsa düzelt (çift assets sorununu önle)
    if (dbPath.startsWith('assets/')) {
      return dbPath.replaceFirst('assets/', 'assets/images/');
    }
    // Aksi halde assets/images/ prefix'i ekle
    return 'assets/images/$dbPath';
  }

  /// Supabase ProductModel'den ShoeModel'e dönüştürür
  /// Mevcut UI kodlarıyla uyumluluk için
  factory ShoeModel.fromProduct(ProductModel product) {
    final primaryImage = _toAssetPath(product.primaryImageUrl);
    final allImages =
        product.imageUrls
            .map((url) => _toAssetPath(url))
            .where((path) => path.isNotEmpty)
            .toList();

    return ShoeModel(
      id: product.id,
      name: product.name,
      brand: product.brand?.name ?? '',
      color: product.color?.name ?? '',
      sizeRange: product.sizeRange ?? '',
      imagePath: primaryImage,
      images: allImages.isNotEmpty ? allImages : [primaryImage],
      category: product.subcategory?.slug ?? '',
      gender: product.category?.slug ?? '',
    );
  }
}

class OldCategoryModel {
  final String id;
  final String name;
  final String gender;
  final bool isActive;

  OldCategoryModel({
    required this.id,
    required this.name,
    required this.gender,
    this.isActive = true,
  });
}

class SizeGroup {
  final String id;
  final String name;
  final List<String> sizes;
  final String gender;
  final String category;

  SizeGroup({
    required this.id,
    required this.name,
    required this.sizes,
    required this.gender,
    required this.category,
  });
}
