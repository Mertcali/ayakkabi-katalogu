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
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            children: [
                              // AppBar
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  16,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Katalog',
                                      style: TextStyle(
                                        fontSize: 24,
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
                                                      (_) => const CartScreen(),
                                                ),
                                              ),
                                        ),
                                        if (cart.itemCount > 0)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
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

                              // Carousel - Database'den
                              _buildPromotionCarousel(
                                context,
                                theme,
                                dataProvider.carouselSlides,
                              ),

                              const SizedBox(height: 24),

                              // Kategoriler Grid - 2x3 Database'den
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.0,
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

                              const SizedBox(height: 24),

                              // Keşfet Grid - 2x2 Database'den
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1.8,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount:
                                      dataProvider.exploreSections.length > 4
                                          ? 4
                                          : dataProvider.exploreSections.length,
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

                              const SizedBox(height: 20),
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
              ),
              textAlign: TextAlign.center,
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
  ) {
    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
