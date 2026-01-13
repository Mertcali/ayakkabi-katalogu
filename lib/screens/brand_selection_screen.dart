import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/data_provider.dart';
import 'models_screen.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

class BrandSelectionScreen extends StatefulWidget {
  final String category; // Ana kategori (erkek, kadin, vb.)
  final String subcategory; // Alt kategori (spor, klasik, vb.)
  final String? sizeGroup;

  const BrandSelectionScreen({
    super.key,
    required this.category,
    required this.subcategory,
    this.sizeGroup,
  });

  @override
  State<BrandSelectionScreen> createState() => _BrandSelectionScreenState();
}

class _BrandSelectionScreenState extends State<BrandSelectionScreen> {
  List<String> _brands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    print(
      '🔍 BrandSelectionScreen - Loading brands for category: ${widget.category}, subcategory: ${widget.subcategory}',
    );
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final brands = await dataProvider.getBrandsByCategoryAndSubcategory(
      widget.category,
      widget.subcategory,
    );
    print('✅ BrandSelectionScreen - Loaded ${brands.length} brands: $brands');
    setState(() {
      _brands = brands;
      _isLoading = false;
    });
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
          'Marka Seçin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: themeProvider.textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: themeProvider.textColor,
                    size: 18,
                  ),
                ),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
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
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: themeProvider.primaryColor,
                ),
              )
              : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Breadcrumb Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                                      style: TextStyle(
                                        color: themeProvider.primaryColor,
                                      ),
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
                                      style: TextStyle(
                                        color: themeProvider.primaryColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _getSubcategoryTitle(
                                        widget.subcategory,
                                      ),
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

                  // Brands Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final brand = _brands[index];
                        return _buildModernBrandCard(
                          context,
                          themeProvider,
                          brand,
                          _getBrandColors(brand),
                          () => _navigateToModels(context, brand),
                        );
                      }, childCount: _brands.length),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
    );
  }

  Widget _buildModernBrandCard(
    BuildContext context,
    ThemeProvider themeProvider,
    String brand,
    List<Color> colors,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeProvider.borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors[0].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getBrandIcon(brand), size: 32, color: colors[0]),
            ),
            const SizedBox(height: 12),
            Text(
              brand,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: themeProvider.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Modelleri gör →',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle() {
    final categoryTitle = _getCategoryTitle(widget.category);
    final subcategoryTitle = _getSubcategoryTitle(widget.subcategory);
    return '$categoryTitle → $subcategoryTitle';
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

  IconData _getBrandIcon(String brand) {
    switch (brand) {
      case 'Nike':
        return Icons.sports_soccer;
      case 'Converse':
        return Icons.sports_basketball;
      case 'Puma':
        return Icons.sports_handball;
      case 'Adidas':
        return Icons.sports_tennis;
      default:
        return Icons.branding_watermark;
    }
  }

  List<Color> _getBrandColors(String brand) {
    switch (brand) {
      case 'Nike':
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case 'Converse':
        return [const Color(0xFF06B6D4), const Color(0xFF0891B2)];
      case 'Puma':
        return [const Color(0xFFEC4899), const Color(0xFFBE185D)];
      case 'Adidas':
        return [const Color(0xFF10B981), const Color(0xFF047857)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  void _navigateToModels(BuildContext context, String brand) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ModelsScreen(
              category: widget.category,
              subcategory: widget.subcategory,
              sizeGroup: widget.sizeGroup,
              brand: brand,
            ),
      ),
    );
  }
}
