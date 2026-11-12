import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/empty_state_view.dart';

import '../../canteen/models/menu_item_model.dart';
import '../../canteen/screens/canteen_detail_screen.dart';
import '../../canteen/widgets/menu_customization_sheet.dart';
import '../../cart/screens/cart_screen.dart';
import '../../cart/widgets/floating_cart_bar.dart';
import '../../order/screens/order_tracking_screen.dart';
import '../widgets/canteen_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/food_menu_card.dart';
import '../widgets/promo_banner_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCustomizationSheet(MenuItemModel menu) {
    final canteenCtrl = AppState.instance.canteenController;
    final canteen = canteenCtrl.getCanteenById(menu.canteenId);
    if (canteen != null && !canteen.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maaf, ${menu.canteenName} saat ini sedang tutup dan tidak menerima pesanan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cartController = AppState.instance.cartController;
    if (cartController.isDifferentCanteen(menu.canteenId)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ganti Stan Kantin?'),
          content: Text(
            'Keranjang Anda saat ini berisi menu dari "${cartController.currentCanteenName}".\n\n'
            'Satu pesanan hanya dapat dibuat untuk satu stan kantin. Apakah Anda ingin mengosongkan keranjang untuk memesan dari "${menu.canteenName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                cartController.clearCart();
                _showActualCustomizationSheet(menu);
              },
              child: const Text('Ganti Stan'),
            ),
          ],
        ),
      );
      return;
    }

    _showActualCustomizationSheet(menu);
  }

  void _showActualCustomizationSheet(MenuItemModel menu) {
    final cartController = AppState.instance.cartController;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuCustomizationSheet(
        menuItem: menu,
        onAddToCart: ({
          required int quantity,
          required String? selectedSpicyLevel,
          required List<MenuTopping> selectedToppings,
          required String? specialNotes,
        }) {
          cartController.addItem(
            menuItem: menu,
            quantity: quantity,
            selectedSpicyLevel: selectedSpicyLevel,
            selectedToppings: selectedToppings,
            specialNotes: specialNotes,
          );

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${menu.name} ditambahkan ke keranjang!',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.secondary,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCodPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canteenCtrl = AppState.instance.canteenController;
    final authCtrl = AppState.instance.authController;
    final orderCtrl = AppState.instance.orderController;
    final cartCtrl = AppState.instance.cartController;
    final voucherCtrl = AppState.instance.voucherController;

    return AnimatedBuilder(
      animation: Listenable.merge([canteenCtrl, authCtrl, orderCtrl, cartCtrl, voucherCtrl]),
      builder: (context, _) {
        final filteredMenus = canteenCtrl.filteredMenus;
        final user = authCtrl.currentUser;
        final activeOrder = orderCtrl.latestActiveOrder;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top App Bar / Greeting
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.md, AppDimens.md, AppDimens.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryContainer,
                                backgroundImage: user != null ? NetworkImage(user.avatarUrl) : null,
                                onBackgroundImageError: user != null ? (_, _) {} : null,
                                child: user == null
                                    ? const Icon(Icons.person_rounded, color: AppColors.primary)
                                    : null,
                              ),
                              const SizedBox(width: AppDimens.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo, ${user?.name.split(" ").first ?? "Kawan"} 👋',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.place_rounded, size: 12, color: AppColors.primary),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            user?.campusLocation ?? 'Kantin Utama Lt. 1',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Active Queue Quick Badge
                        if (activeOrder != null) ...[
                          const SizedBox(width: AppDimens.xs),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderTrackingScreen(orderId: activeOrder.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.soup_kitchen_rounded, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    activeOrder.queueNumber,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Shopping Cart Icon with Badge
                        const SizedBox(width: AppDimens.xs),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CartScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.outline),
                              boxShadow: const [AppColors.softShadow],
                            ),
                            child: Badge(
                              isLabelVisible: cartCtrl.totalQuantity > 0,
                              label: Text(
                                '${cartCtrl.totalQuantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              backgroundColor: AppColors.primary,
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.xs),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => canteenCtrl.setSearchQuery(val),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari dimsum mentai, dimsum goreng, soto, bakso...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  canteenCtrl.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                // Keterangan COD Biasa (Bayar Tunai di Kasir)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.xs, AppDimens.md, AppDimens.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimens.md),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF5722),
                            Color(0xFFFF7043),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        boxShadow: const [AppColors.softShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.payments_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Metode Pembayaran COD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Bayar di Kasir',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Pesan Sekarang, Bayar Tunai (COD)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Makanan langsung disiapkan dapur stan. Cukup sebutkan kode antrean dan bayar tunai di kasir saat mengambil.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildCodPill(Icons.money_off_rounded, 'Tanpa Saldo'),
                              _buildCodPill(Icons.timer_outlined, 'Bebas Antre'),
                              _buildCodPill(Icons.receipt_long_rounded, 'Struk Tiket'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Promo Banners
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimens.xs),
                    child: PromoBannerCarousel(),
                  ),
                ),

                // Categories Filter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppDimens.sm, bottom: AppDimens.sm),
                    child: CategorySelector(
                      categories: canteenCtrl.categories,
                      selectedCategory: canteenCtrl.selectedCategory,
                      onCategorySelected: (cat) => canteenCtrl.selectCategory(cat),
                    ),
                  ),
                ),

                // Tenant Spotlight Section Header (PRD 4.2 & ui.md 2.2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.md, AppDimens.md, AppDimens.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Flexible(
                                child: Text(
                                  'Stan Kantin Mitra',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${canteenCtrl.canteens.length} Stan',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.place_rounded, size: 12, color: AppColors.primary),
                              SizedBox(width: 3),
                              Text(
                                'Kantin Utama Lt. 1',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Horizontal Carousel of Partner Stalls (Tenant Spotlight)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 256,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 6),
                      scrollDirection: Axis.horizontal,
                      itemCount: canteenCtrl.canteens.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final canteen = canteenCtrl.canteens[index];
                        return CanteenCard(
                          width: 250,
                          canteen: canteen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CanteenDetailScreen(canteen: canteen),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Stall Filter Chips Selector
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppDimens.xs),
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                      scrollDirection: Axis.horizontal,
                      itemCount: canteenCtrl.canteens.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final canteen = isAll ? null : canteenCtrl.canteens[index - 1];
                        final isSelected = isAll
                            ? canteenCtrl.selectedCanteenId == null
                            : canteenCtrl.selectedCanteenId == canteen?.id;
                        final label = isAll ? 'Semua Stan' : (canteen?.name.split('—').first.trim() ?? '');

                        return InkWell(
                          onTap: () {
                            canteenCtrl.selectCanteen(isAll ? null : canteen?.id);
                          },
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outline,
                              ),
                              boxShadow: isSelected ? const [AppColors.softShadow] : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isAll) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: (canteen?.isOpen ?? false) ? AppColors.secondary : AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Popular / Filtered Menus Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppDimens.md, AppDimens.lg, AppDimens.md, AppDimens.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            canteenCtrl.searchQuery.isNotEmpty
                                ? 'Hasil Pencarian Menu'
                                : 'Menu Rekomendasi Terlaris',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppDimens.xs),
                        Text(
                          '${filteredMenus.length} Menu',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu Grid
                if (filteredMenus.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'Menu Tidak Ditemukan',
                      message: 'Coba gunakan kata kunci lain atau pilih kategori Semua.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 230,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final menu = filteredMenus[index];
                          return FoodMenuCard(
                            menuItem: menu,
                            onTap: () => _openCustomizationSheet(menu),
                            onAddPressed: () => _openCustomizationSheet(menu),
                          );
                        },
                        childCount: filteredMenus.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const FloatingCartBar(),
        );
      },
    );
  }
}
