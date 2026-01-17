import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/data_provider.dart';
import '../models/shoe_model.dart';
import '../models/supabase_models.dart';
import 'category_selection_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _newProductsController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _newProductsController = PageController(
      viewportFraction: 1.0,
      initialPage: 0,
    );

    // Uygulama başladığında verileri yükle (build tamamlandıktan sonra)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // Eğer zaten yükleme yapılıyorsa, yeni istek yapma
    if (dataProvider.isLoading) return;

    // Mevcut timer'ı iptal et
    _autoScrollTimer?.cancel();

    await dataProvider.loadAllData();

    // Carousel'i başa sar
    setState(() {
      _currentPage = 0;
    });

    if (_newProductsController.hasClients &&
        dataProvider.carouselSlides.isNotEmpty) {
      _newProductsController.jumpToPage(0);
    }

    // Auto-scroll'u yeniden başlat
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _newProductsController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    // Önce mevcut timer'ı iptal et
    _autoScrollTimer?.cancel();

    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // Carousel slides kontrolü
    if (dataProvider.carouselSlides.isEmpty) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (dataProvider.carouselSlides.isEmpty) {
        timer.cancel();
        return;
      }

      final nextPage = (_currentPage + 1) % dataProvider.carouselSlides.length;

      if (_newProductsController.hasClients) {
        _newProductsController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // Yeni ürünler listesi
    final List<ShoeModel> newProducts = dataProvider.newProducts;

    // Debug: Explore sections kontrolü
    debugPrint(
      '🏠 Home Screen: exploreSections.length = ${dataProvider.exploreSections.length}',
    );
    if (dataProvider.exploreSections.isNotEmpty) {
      debugPrint('🏠 İlk section: ${dataProvider.exploreSections.first.title}');
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child:
            dataProvider.isLoading
                ? Center(
                  child: CircularProgressIndicator(color: theme.primaryColor),
                )
                : RefreshIndicator(
                  onRefresh: _loadData,
                  color: theme.primaryColor,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableHeight = constraints.maxHeight;

                      // Oransal yükseklikler
                      final appBarHeight = availableHeight * 0.08;
                      final carouselHeight = availableHeight * 0.30;
                      final categoriesHeight = availableHeight * 0.28;
                      final exploreHeight = availableHeight * 0.26;

                      final topSpacing = availableHeight * 0.015;
                      final carouselBottomSpacing =
                          availableHeight * 0.03; // Carousel altı - %3 boşluk
                      final categoryBottomSpacing =
                          availableHeight * 0.002; // Kategoriler altı - minimal
                      final bottomSpacing = availableHeight * 0.01;

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: availableHeight,
                          ),
                          child: Column(
                            children: [
                              // AppBar
                              SizedBox(
                                height: appBarHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(
                                          appBarHeight * 0.15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.shopping_bag_rounded,
                                          color: Colors.white,
                                          size: appBarHeight * 0.35,
                                        ),
                                      ),
                                      SizedBox(width: appBarHeight * 0.15),
                                      Text(
                                        'Katalog',
                                        style: TextStyle(
                                          fontSize: appBarHeight * 0.38,
                                          fontWeight: FontWeight.w800,
                                          color: theme.textColor,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      _buildActionButton(
                                        theme,
                                        icon:
                                            theme.isWinterMode
                                                ? Icons.wb_sunny_rounded
                                                : Icons.nightlight_round,
                                        onTap: () => theme.toggleTheme(),
                                      ),
                                      const SizedBox(width: 8),
                                      Stack(
                                        children: [
                                          _buildActionButton(
                                            theme,
                                            icon: Icons.shopping_cart_outlined,
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            const CartScreen(),
                                                  ),
                                                ),
                                          ),
                                          if (cart.itemCount > 0)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: theme.primaryColor,
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
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: topSpacing),

                              // Carousel - Database'den
                              SizedBox(
                                height: carouselHeight,
                                child: _buildPromotionCarousel(
                                  context,
                                  theme,
                                  dataProvider.carouselSlides,
                                  carouselHeight,
                                ),
                              ),

                              SizedBox(height: carouselBottomSpacing),

                              // Kategoriler Grid - 2x3 Database'den
                              SizedBox(
                                height: categoriesHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1.3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                    itemCount:
                                        dataProvider.categories.length > 6
                                            ? 6
                                            : dataProvider.categories.length,
                                    itemBuilder: (context, index) {
                                      // Direkt database'den gelen sıralamayı kullan (display_order)
                                      final category =
                                          dataProvider.categories[index];

                                      // Icon mapping
                                      IconData icon;
                                      switch (category.slug) {
                                        case 'erkek':
                                          icon = Icons.male_rounded;
                                          break;
                                        case 'kadin':
                                          icon = Icons.female_rounded;
                                          break;
                                        case 'garson':
                                          icon = Icons.work_rounded;
                                          break;
                                        case 'filet':
                                          icon = Icons.child_friendly_rounded;
                                          break;
                                        case 'patik':
                                          icon = Icons.child_care_rounded;
                                          break;
                                        case 'bebe':
                                          icon = Icons.cruelty_free_rounded;
                                          break;
                                        default:
                                          icon = Icons.shopping_bag_rounded;
                                      }
                                      return _buildGenderCard(
                                        context,
                                        theme,
                                        category.name,
                                        category.slug,
                                        icon,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: categoryBottomSpacing),

                              // Keşfet Grid - 2x2 Database'den
                              SizedBox(
                                height: exploreHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 2.5,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                    itemCount:
                                        dataProvider.exploreSections.length > 4
                                            ? 4
                                            : dataProvider
                                                .exploreSections
                                                .length,
                                    itemBuilder: (context, index) {
                                      final section =
                                          dataProvider.exploreSections[index];

                                      // Icon ve renk mapping
                                      IconData icon;
                                      Color color;
                                      final titleLower =
                                          section.title.toLowerCase();

                                      if (titleLower.contains('kampanya')) {
                                        icon = Icons.local_offer_rounded;
                                        color = theme.primaryColor;
                                      } else if (titleLower.contains('yeni')) {
                                        icon = Icons.fiber_new_rounded;
                                        color = theme.secondaryColor;
                                      } else if (titleLower.contains('özel') ||
                                          titleLower.contains('numara')) {
                                        icon = Icons.star_rounded;
                                        color = const Color(0xFFF59E0B);
                                      } else if (titleLower.contains(
                                        'aksesuar',
                                      )) {
                                        icon = Icons.shopping_bag_outlined;
                                        color = const Color(0xFF8B5CF6);
                                      } else {
                                        icon = Icons.category_rounded;
                                        color = theme.primaryColor;
                                      }

                                      return _buildFeatureCard(
                                        context,
                                        theme,
                                        section.title,
                                        icon,
                                        color,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: bottomSpacing),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildActionButton(
    ThemeProvider theme, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.surfaceVariantColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor, width: 1),
        ),
        child: Icon(icon, color: theme.textColor, size: 20),
      ),
    );
  }

  Widget _buildGenderCard(
    BuildContext context,
    ThemeProvider theme,
    String title,
    String gender,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategorySelectionScreen(category: gender),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.borderColor, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCarousel(
    BuildContext context,
    ThemeProvider theme,
    List<CarouselSlideModel> slides,
    double carouselHeight,
  ) {
    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _newProductsController,
            physics: const ClampingScrollPhysics(),
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = slides[index];
              final isNetworkImage =
                  slide.imageUrl.startsWith('http://') ||
                  slide.imageUrl.startsWith('https://');

              return ClipRRect(
                borderRadius: BorderRadius.zero,
                child:
                    isNetworkImage
                        ? Image.network(
                          slide.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                              '❌ Carousel görsel yüklenemedi: ${slide.imageUrl}',
                            );
                            return Container(
                              color: theme.surfaceVariantColor,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      color: theme.textSecondaryColor,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Görsel yüklenemedi',
                                      style: TextStyle(
                                        color: theme.textSecondaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                        : Image.asset(
                          slide.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint(
                              '❌ Carousel görsel yüklenemedi: ${slide.imageUrl}',
                            );
                            return Container(
                              color: theme.surfaceVariantColor,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      color: theme.textSecondaryColor,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Görsel yüklenemedi',
                                      style: TextStyle(
                                        color: theme.textSecondaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Sayfa indikatörleri
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color:
                    _currentPage == index
                        ? theme.primaryColor
                        : theme.borderColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    ThemeProvider theme,
    String title,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title yakında aktif olacak!'),
            backgroundColor: theme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: theme.textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
