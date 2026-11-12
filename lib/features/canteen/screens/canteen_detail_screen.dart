import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/menu_image_view.dart';
import '../../cart/screens/cart_screen.dart';
import '../../cart/widgets/floating_cart_bar.dart';
import '../models/canteen_model.dart';
import '../models/menu_item_model.dart';
import '../widgets/menu_customization_sheet.dart';

class CanteenDetailScreen extends StatefulWidget {
  final CanteenModel canteen;

  const CanteenDetailScreen({
    super.key,
    required this.canteen,
  });

  @override
  State<CanteenDetailScreen> createState() => _CanteenDetailScreenState();
}

class _CanteenDetailScreenState extends State<CanteenDetailScreen> {
  late String _selectedCategory;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.canteen.categories.first;
  }

  void _openCustomizationSheet(MenuItemModel menu) {
    final canteenCtrl = AppState.instance.canteenController;
    final currentCanteen = canteenCtrl.getCanteenById(widget.canteen.id) ?? widget.canteen;
    if (!currentCanteen.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maaf, stan ini sedang tutup dan tidak menerima pesanan baru.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cartController = AppState.instance.cartController;
    if (cartController.isDifferentCanteen(widget.canteen.id)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ganti Stan Kantin?'),
          content: Text(
            'Keranjang Anda saat ini berisi menu dari "${cartController.currentCanteenName}".\n\n'
            'Satu pesanan hanya dapat dibuat untuk satu stan kantin. Apakah Anda ingin mengosongkan keranjang untuk memesan dari "${currentCanteen.name}"?',
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

  @override
  Widget build(BuildContext context) {
    final canteenCtrl = AppState.instance.canteenController;
    final voucherCtrl = AppState.instance.voucherController;

    return AnimatedBuilder(
      animation: Listenable.merge([canteenCtrl, voucherCtrl]),
      builder: (context, _) {
        final currentCanteen = canteenCtrl.getCanteenById(widget.canteen.id) ?? widget.canteen;
        final liveMenus = canteenCtrl.getMenusForCanteen(widget.canteen.id);
        final filteredMenus = liveMenus.where((menu) {
          if (_selectedCategory == 'Semua') return true;
          return menu.category == _selectedCategory;
        }).toList();
        final canteenVouchers = voucherCtrl.getActiveVouchersForCanteen(currentCanteen.id);

        final cartController = AppState.instance.cartController;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible AppBar with Banner Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: _isBookmarked ? AppColors.accent : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isBookmarked
                            ? '${currentCanteen.name} disimpan ke favorit!'
                            : '${currentCanteen.name} dihapus dari favorit.',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Badge(
                    isLabelVisible: cartController.totalQuantity > 0,
                    label: Text(
                      '${cartController.totalQuantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    currentCanteen.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primary,
                      child: const Icon(Icons.storefront_rounded, size: 64, color: Colors.white),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Canteen Info Header
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppDimens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentCanteen.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 13, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '${currentCanteen.activeQueueCount} Antrean',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          currentCanteen.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(
                        '${currentCanteen.rating} (${currentCanteen.reviewCount}+)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Buka: ${currentCanteen.openHours}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Text(
                    currentCanteen.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (canteenVouchers.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.md),
                    const Row(
                      children: [
                        Icon(Icons.local_offer_rounded, size: 15, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Promo Voucher Stan Ini',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: canteenVouchers.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final v = canteenVouchers[index];
                          return InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: v.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kode promo "${v.code}" disalin! Terapkan di Keranjang.',
                                  ),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            child: Container(
                              width: 225,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${v.code} • Hemat ${CurrencyFormatter.format(v.discountAmount)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          v.minPurchase > 0
                                              ? 'Min. belanja ${CurrencyFormatter.format(v.minPurchase)} • Sisa ${v.remainingQuota}'
                                              : 'Tanpa min. belanja • Sisa ${v.remainingQuota}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (!currentCanteen.isOpen) ...[
                    const SizedBox(height: AppDimens.sm),
                    Container(
                      padding: const EdgeInsets.all(AppDimens.sm),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.storefront_outlined, color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Stan ini sedang TUTUP dan belum menerima pesanan baru. Anda tetap dapat melihat menu, namun pemesanan sementara dinonaktifkan.',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Categories Filter Tabs
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: AppDimens.sm),
              padding: const EdgeInsets.symmetric(vertical: AppDimens.xs),
              color: AppColors.surface,
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                  itemCount: currentCanteen.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = currentCanteen.categories[index];
                    final isSelected = cat == _selectedCategory;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Menu List
          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final menu = filteredMenus[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppDimens.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(color: AppColors.outline),
                      boxShadow: const [AppColors.softShadow],
                    ),
                    child: InkWell(
                      onTap: () => _openCustomizationSheet(menu),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: MenuImageView(
                                  imageUrl: menu.imageUrl,
                                  imageBytes: menu.imageBytes,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    menu.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          CurrencyFormatter.format(menu.price),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _openCustomizationSheet(menu),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            '+ Tambah',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                    ),
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

      // Bottom Sticky Floating Cart Bar
      bottomNavigationBar: const FloatingCartBar(),
    );
      },
    );
  }
}
