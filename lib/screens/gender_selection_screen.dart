import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/data_provider.dart';
import 'brand_selection_screen.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

// DEPRECATED: Bu ekran artık kullanılmıyor
// Yerine CategorySelectionScreen kullanın
@Deprecated('Use CategorySelectionScreen instead')
class GenderSelectionScreen extends StatefulWidget {
  final String gender;

  const GenderSelectionScreen({super.key, required this.gender});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  List<String> _subcategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final subcategories = await dataProvider.getSubcategoriesByCategory(
      widget.gender,
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
    final genderTitle = _getGenderTitle(widget.gender);

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
          genderTitle,
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
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeProvider.primaryColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeProvider.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getGenderIcon(widget.gender),
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_subcategories.length} Alt Kategori',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: themeProvider.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bir alt kategori seçin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Subcategories Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final subcategory = _subcategories[index];
                        return _buildModernCategoryCard(
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

  Widget _buildModernCategoryCard(
    BuildContext context,
    ThemeProvider themeProvider,
    String subcategory,
  ) {
    final categoryColor = _getCategoryColor(subcategory);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BrandSelectionScreen(
                  category: widget.gender,
                  subcategory: subcategory,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(subcategory),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                subcategory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: themeProvider.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case 'Spor Ayakkabı':
        return const Color(0xFF6366F1);
      case 'Tekstil Ayakkabı':
        return const Color(0xFF10B981);
      case 'Çanta':
        return const Color(0xFFEC4899);
      case 'Terlik':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Spor Ayakkabı':
        return Icons.sports_soccer;
      case 'Tekstil Ayakkabı':
        return Icons.shopping_bag_outlined;
      case 'Çanta':
        return Icons.work_outline;
      case 'Terlik':
        return Icons.beach_access;
      default:
        return Icons.category;
    }
  }

  String _getGenderTitle(String gender) {
    switch (gender) {
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
      case 'cocuk':
        return 'Çocuk';
      default:
        return '';
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
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
      case 'cocuk':
        return Icons.child_care;
      default:
        return Icons.person;
    }
  }
}
