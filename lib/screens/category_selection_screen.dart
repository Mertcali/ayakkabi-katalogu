import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/data_provider.dart';
import '../models/supabase_models.dart';
import 'brand_selection_screen.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

/// Alt kategori seçim ekranı (örn: Erkek → Spor, Klasik, vb.)
class CategorySelectionScreen extends StatefulWidget {
  final String category; // Ana kategori slug (erkek, kadin, garson, vb.)

  const CategorySelectionScreen({super.key, required this.category});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<SubcategoryModel> _subcategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final subcategories = await dataProvider.getSubcategoryModelsByCategory(
      widget.category,
    );
    setState(() {
      _subcategories = subcategories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final categoryTitle = _getCategoryTitle(widget.category);

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
          'Kategori Seçin',
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
                                      text: categoryTitle,
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

                  // Subcategories Grid
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
                        final subcategory = _subcategories[index];
                        return _buildSubcategoryCard(
                          context,
                          themeProvider,
                          subcategory,
                        );
                      }, childCount: _subcategories.length),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
    );
  }

  Widget _buildSubcategoryCard(
    BuildContext context,
    ThemeProvider themeProvider,
    SubcategoryModel subcategory,
  ) {
    final subcategoryColor = _getSubcategoryColor(subcategory.slug);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BrandSelectionScreen(
                  category: widget.category,
                  subcategory: subcategory.slug,
                ),
          ),
        );
      },
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
                color: subcategoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getSubcategoryIcon(subcategory.slug),
                color: subcategoryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subcategory.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: themeProvider.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Keşfet',
              style: TextStyle(
                fontSize: 13,
                color: subcategoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubcategoryColor(String subcategoryName) {
    switch (subcategoryName) {
      case 'Spor':
        return const Color(0xFF6366F1);
      case 'Klasik':
        return const Color(0xFF10B981);
      case 'Günlük':
        return const Color(0xFFEC4899);
      case 'Bot':
        return const Color(0xFFF59E0B);
      case 'Sandalet':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getSubcategoryIcon(String subcategoryName) {
    switch (subcategoryName) {
      case 'Spor':
        return Icons.sports_soccer;
      case 'Klasik':
        return Icons.business_center;
      case 'Günlük':
        return Icons.wb_sunny;
      case 'Bot':
        return Icons.hiking;
      case 'Sandalet':
        return Icons.beach_access;
      default:
        return Icons.category;
    }
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'kadin':
        return Icons.female;
      case 'erkek':
        return Icons.male;
      case 'garson':
        return Icons.work_outline;
      case 'filet':
        return Icons.child_friendly;
      case 'patik':
        return Icons.child_care;
      case 'bebe':
        return Icons.baby_changing_station;
      default:
        return Icons.person;
    }
  }
}
