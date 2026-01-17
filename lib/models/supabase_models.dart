/// Supabase veritabanı modelleri
/// Bu modeller veritabanı tablolarıyla eşleşir

/// ANA KATEGORİLER (Erkek, Kadın, Garson, Filet, Patik, Bebe)
class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? iconName;
  final int displayOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.iconName,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      iconName: json['icon_name']?.toString(),
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}

/// ALT KATEGORİLER (Spor, Klasik, Günlük, vb.)
class SubcategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? iconName;
  final int displayOrder;
  final bool isActive;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.iconName,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      iconName: json['icon_name']?.toString(),
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}

class BrandModel {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? description;
  final int displayOrder;
  final bool isActive;

  BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.description,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      slug:
          json['slug']?.toString() ??
          json['name'].toString().toLowerCase().replaceAll(' ', '-'),
      logoUrl: json['logo_url']?.toString(),
      description: json['description']?.toString(),
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'logo_url': logoUrl,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}

class ColorModel {
  final String id;
  final String name;
  final String? hexCode;
  final int displayOrder;

  ColorModel({
    required this.id,
    required this.name,
    this.hexCode,
    this.displayOrder = 0,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      hexCode: json['hex_code']?.toString(),
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hex_code': hexCode,
      'display_order': displayOrder,
    };
  }
}

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? brandId;
  final String? categoryId;
  final String? subcategoryId;
  final String? colorId;
  final String? sizeRange;
  final String? imagePath; // Direkt products tablosundaki image_path
  final String? description;
  final bool isNew;
  final bool isFeatured;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // İlişkili veriler (join ile gelir)
  final BrandModel? brand;
  final CategoryModel? category;
  final SubcategoryModel? subcategory;
  final ColorModel? color;
  final List<ProductImageModel> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.brandId,
    this.categoryId,
    this.subcategoryId,
    this.colorId,
    this.sizeRange,
    this.imagePath,
    this.description,
    this.isNew = false,
    this.isFeatured = false,
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.category,
    this.subcategory,
    this.color,
    this.images = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      brandId: json['brand_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      subcategoryId: json['subcategory_id']?.toString(),
      colorId: json['color_id']?.toString(),
      sizeRange: json['size_range']?.toString(),
      imagePath: json['image_path']?.toString(),
      description: json['description']?.toString(),
      isNew: json['is_new'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      brand:
          json['brands'] != null
              ? BrandModel.fromJson(json['brands'] as Map<String, dynamic>)
              : null,
      category:
          json['categories'] != null
              ? CategoryModel.fromJson(
                json['categories'] as Map<String, dynamic>,
              )
              : null,
      subcategory:
          json['subcategories'] != null
              ? SubcategoryModel.fromJson(
                json['subcategories'] as Map<String, dynamic>,
              )
              : null,
      color:
          json['colors'] != null
              ? ColorModel.fromJson(json['colors'] as Map<String, dynamic>)
              : null,
      images:
          (json['product_images'] as List<dynamic>?)
              ?.map(
                (e) => ProductImageModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Ana görsel URL'i
  String get primaryImageUrl {
    // Önce direkt image_path'i kontrol et
    if (imagePath != null && imagePath!.isNotEmpty) {
      return imagePath!;
    }
    // Yoksa product_images'den al
    final primary = images.where((img) => img.isPrimary).firstOrNull;
    return primary?.imageUrl ?? images.firstOrNull?.imageUrl ?? '';
  }

  /// Tüm görsel URL'leri
  List<String> get imageUrls {
    // Önce product_images tablosundan çek
    if (images.isNotEmpty) {
      return images.map((img) => img.imageUrl).toList();
    }
    // Yoksa direkt image_path'i kullan (geriye dönük uyumluluk)
    if (imagePath != null && imagePath!.isNotEmpty) {
      return [imagePath!];
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'brand_id': brandId,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'color_id': colorId,
      'size_range': sizeRange,
      'description': description,
      'is_new': isNew,
      'is_featured': isFeatured,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }
}

class ProductImageModel {
  final String id;
  final String productId;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;

  ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    this.isPrimary = false,
    this.displayOrder = 0,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'].toString(),
      productId: json['product_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'display_order': displayOrder,
    };
  }
}

class CarouselSlideModel {
  final String id;
  final String? title;
  final String? subtitle;
  final String imageUrl;
  final String? linkType;
  final String? linkValue;
  final int displayOrder;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  CarouselSlideModel({
    required this.id,
    this.title,
    this.subtitle,
    required this.imageUrl,
    this.linkType,
    this.linkValue,
    this.displayOrder = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  factory CarouselSlideModel.fromJson(Map<String, dynamic> json) {
    return CarouselSlideModel(
      id: json['id'].toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      imageUrl: json['image_url']?.toString() ?? '',
      linkType: json['link_type']?.toString(),
      linkValue: json['link_value']?.toString(),
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startDate:
          json['start_date'] != null
              ? DateTime.parse(json['start_date'] as String)
              : null,
      endDate:
          json['end_date'] != null
              ? DateTime.parse(json['end_date'] as String)
              : null,
    );
  }

  /// Şu an aktif mi kontrol eder (tarih aralığı dahil)
  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'link_type': linkType,
      'link_value': linkValue,
      'display_order': displayOrder,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

class ExploreSectionModel {
  final String id;
  final String title;
  final String? iconName;
  final String? sectionType;
  final String? linkValue;
  final String? imageUrl;
  final int displayOrder;
  final bool isActive;

  ExploreSectionModel({
    required this.id,
    required this.title,
    this.iconName,
    this.sectionType,
    this.linkValue,
    this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory ExploreSectionModel.fromJson(Map<String, dynamic> json) {
    return ExploreSectionModel(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      iconName: json['icon_name']?.toString(),
      sectionType: json['section_type']?.toString(),
      linkValue: json['link_value']?.toString(),
      imageUrl: json['image_url']?.toString(),
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_name': iconName,
      'section_type': sectionType,
      'link_value': linkValue,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}
