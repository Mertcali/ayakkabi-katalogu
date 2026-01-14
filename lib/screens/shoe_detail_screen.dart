import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shoe_model.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

class ShoeDetailScreen extends StatefulWidget {
  final ShoeModel shoe;
  final List<ShoeModel> colorVariants;

  const ShoeDetailScreen({
    super.key,
    required this.shoe,
    this.colorVariants = const [],
  });

  @override
  State<ShoeDetailScreen> createState() => _ShoeDetailScreenState();
}

class _ShoeDetailScreenState extends State<ShoeDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  late ShoeModel _selectedVariant;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _selectedVariant = widget.shoe;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          _selectedVariant.name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Product Image Section
          SliverToBoxAdapter(child: _buildModernImageSection(themeProvider)),

          // Product Details
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildModernShoeDetails(themeProvider),
                const SizedBox(height: 32),
                _buildModernActionButtons(themeProvider),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernImageSection(ThemeProvider themeProvider) {
    // Birden fazla renk varsa renk varyantlarını göster, yoksa tek ürünün görsellerini
    final hasMultipleColors = widget.colorVariants.length > 1;
    final itemCount =
        hasMultipleColors
            ? widget.colorVariants.length
            : _selectedVariant.images.length;

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: Stack(
        children: [
          // PageView - Renk varyantları arasında veya aynı ürünün görselleri arasında geçiş
          PageView.builder(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            itemCount: itemCount,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
                if (hasMultipleColors) {
                  // Renk varyantları arasında geçiş
                  _selectedVariant = widget.colorVariants[index];
                }
              });
            },
            itemBuilder: (context, index) {
              final imagePath =
                  hasMultipleColors
                      ? widget.colorVariants[index].imagePath
                      : _selectedVariant.images[index];
              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 400,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            themeProvider.primaryColor.withValues(alpha: 0.15),
                            themeProvider.secondaryColor.withValues(
                              alpha: 0.15,
                            ),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 100,
                            color: themeProvider.primaryColor.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedVariant.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.primaryColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Görsel Yükleniyor...',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Gradient overlay
          IgnorePointer(
            child: Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),

          // Navigation dots - Renk/Fotoğraf sayısı
          if (itemCount > 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasMultipleColors
                          ? Icons.palette_outlined
                          : Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentImageIndex + 1}/$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(itemCount, (index) {
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentImageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color:
                                _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernShoeDetails(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ürün Adı (Görselin altında)
        Text(
          _selectedVariant.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: themeProvider.textColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Marka
        Text(
          _selectedVariant.brand,
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Renk Seçici (Eğer birden fazla renk varsa)
        if (widget.colorVariants.length > 1) ...[
          const SizedBox(height: 20),
          Text(
            'Renk Seçin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children:
                widget.colorVariants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final variant = entry.value;
                  final isSelected = variant.id == _selectedVariant.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVariant = variant;
                        _currentImageIndex = index;
                      });
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? themeProvider.primaryColor
                                      : themeProvider.borderColor,
                              width: isSelected ? 3 : 1.5,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: themeProvider.primaryColor
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: ClipOval(
                              child: Image.asset(
                                variant.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: themeProvider.surfaceVariantColor,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 20,
                                        color: themeProvider.textSecondaryColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          variant.color,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color:
                                isSelected
                                    ? themeProvider.primaryColor
                                    : themeProvider.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],

        const SizedBox(height: 24),

        // Açıklama Alanı
        Text(
          'Ürün Açıklaması',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.borderColor, width: 1),
          ),
          child: Text(
            _selectedVariant.description ??
                'Bu ürün için henüz açıklama eklenmemiştir.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: themeProvider.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ThemeProvider themeProvider, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: themeProvider.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: themeProvider.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButtons(ThemeProvider themeProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _addToCart(context),
        icon: const Icon(Icons.shopping_cart_outlined, size: 22),
        label: const Text(
          'Sepete Ekle',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addToCart(widget.shoe);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.shoe.name} - 1 Koli sepete eklendi!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Sepete Git',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }
}
