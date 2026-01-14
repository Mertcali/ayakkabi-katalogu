import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/data_provider.dart';
import '../models/shoe_model.dart';
import 'shoe_detail_screen.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

class ModelsScreen extends StatefulWidget {
  final String category; // Ana kategori (erkek, kadin, vb.)
  final String subcategory; // Alt kategori (spor, klasik, vb.)
  final String? sizeGroup;
  final String brand;

  const ModelsScreen({
    super.key,
    required this.category,
    required this.subcategory,
    this.sizeGroup,
    required this.brand,
  });

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  List<ShoeModel> _shoes = [];
  Map<String, List<ShoeModel>> _groupedShoes = {}; // İsme göre gruplanmış
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShoes();
  }

  Future<void> _loadShoes() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    try {
      final shoes = await dataProvider.getShoesByCategorySubcategoryAndBrand(
        widget.category,
        widget.subcategory,
        widget.brand,
      );

      debugPrint('✅ Ürünler yüklendi: ${shoes.length} adet');

      // Ürünleri isme göre grupla (renksiz isme göre)
      final grouped = <String, List<ShoeModel>>{};
      for (final shoe in shoes) {
        // Renk ismini çıkar (örn: "Nike Airmax Beyaz" -> "Nike Airmax")
        String baseName = shoe.name;
        // Renk isimlerini temizle
        final colorKeywords = [
          'Beyaz',
          'Siyah',
          'Kırmızı',
          'Mavi',
          'Yeşil',
          'Sarı',
          'Turuncu',
          'Mor',
          'Pembe',
          'Gri',
          'Kahverengi',
        ];
        for (final color in colorKeywords) {
          baseName =
              baseName
                  .replaceAll(' $color', '')
                  .replaceAll('$color ', '')
                  .replaceAll(' - Kadın', '')
                  .replaceAll(' - Erkek', '')
                  .trim();
        }

        if (!grouped.containsKey(baseName)) {
          grouped[baseName] = [];
        }
        grouped[baseName]!.add(shoe);
      }

      debugPrint('📦 Gruplandı: ${grouped.length} benzersiz ürün');

      if (mounted) {
        setState(() {
          _shoes = shoes;
          _groupedShoes = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Ürünler yüklenirken hata: $e');
      if (mounted) {
        setState(() {
          _shoes = [];
          _groupedShoes = {};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeProvider.surfaceVariantColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: themeProvider.textColor,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ürün Seçin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: themeProvider.textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: themeProvider.textColor,
                        size: 22,
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: -4,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF0080), Color(0xFFFF8C00)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sepetim',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeProvider.surfaceVariantColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.home_outlined,
                color: themeProvider.textColor,
                size: 18,
              ),
            ),
            onPressed:
                () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                ),
            tooltip: 'Ana Sayfaya Dön',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(themeProvider),
    );
  }

  Widget _buildBody(ThemeProvider themeProvider) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: themeProvider.primaryColor),
      );
    }

    if (_groupedShoes.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: themeProvider.surfaceVariantColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: themeProvider.borderColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 64,
                color: themeProvider.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Ürün Bulunamadı',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu kategoride henüz ürün bulunmamaktadır.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: themeProvider.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Breadcrumb Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.surfaceVariantColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: themeProvider.borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.navigation_rounded,
                    color: themeProvider.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: 'Ana Sayfa'),
                          TextSpan(
                            text: ' › ',
                            style: TextStyle(color: themeProvider.primaryColor),
                          ),
                          TextSpan(
                            text: _getCategoryTitle(widget.category),
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' › ',
                            style: TextStyle(color: themeProvider.primaryColor),
                          ),
                          TextSpan(
                            text: _getSubcategoryTitle(widget.subcategory),
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' › ',
                            style: TextStyle(color: themeProvider.primaryColor),
                          ),
                          TextSpan(
                            text: widget.brand,
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Products Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7, // Daha büyük görsel için daha uzun kartlar
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final productName = _groupedShoes.keys.toList()[index];
              final variants = _groupedShoes[productName]!;
              final mainShoe = variants.first; // İlk varyantı göster
              return _buildModernShoeCard(context, mainShoe, variants);
            }, childCount: _groupedShoes.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildModernShoeCard(
    BuildContext context,
    ShoeModel shoe,
    List<ShoeModel> colorVariants,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(context, shoe, colorVariants),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        shoe.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  themeProvider.primaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  themeProvider.secondaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 48,
                                color: themeProvider.primaryColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (colorVariants.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.palette_outlined,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${colorVariants.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Ürün Adı (küçük, tek satır)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  shoe.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'beyaz':
        return Colors.white;
      case 'siyah':
        return Colors.black;
      case 'kırmızı':
        return Colors.red;
      case 'mavi':
        return Colors.blue;
      case 'yeşil':
        return Colors.green;
      case 'sarı':
        return Colors.yellow;
      case 'turuncu':
        return Colors.orange;
      case 'mor':
        return Colors.purple;
      case 'pembe':
        return Colors.pink;
      case 'gri':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _navigateToDetail(
    BuildContext context,
    ShoeModel shoe,
    List<ShoeModel> colorVariants,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ShoeDetailScreen(shoe: shoe, colorVariants: colorVariants),
      ),
    );
  }

  String _getScreenTitle() {
    final categoryTitle = _getCategoryTitle(widget.category);
    final subcategoryTitle = _getSubcategoryTitle(widget.subcategory);
    if (widget.sizeGroup != null) {
      return '$categoryTitle - $subcategoryTitle - ${widget.sizeGroup}';
    }
    return '$categoryTitle - $subcategoryTitle';
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'kadin':
        return 'Kadın';
      case 'erkek':
        return 'Erkek';
      case 'garson':
        return 'Garson';
      case 'filet':
        return 'Filet';
      case 'patik':
        return 'Patik';
      case 'bebe':
        return 'Bebe';
      case 'outdoor':
        return 'Outdoor';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }

  String _getSubcategoryTitle(String subcategory) {
    switch (subcategory) {
      case 'spor':
        return 'Spor';
      case 'klasik':
        return 'Klasik';
      case 'gunluk':
        return 'Günlük';
      case 'bot':
        return 'Bot';
      case 'sandalet':
        return 'Sandalet';
      default:
        return subcategory[0].toUpperCase() + subcategory.substring(1);
    }
  }
}

class Range {
  final int start;
  final int end;

  const Range(this.start, this.end);
}
