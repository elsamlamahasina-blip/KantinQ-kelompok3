import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/menu_image_view.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../order/models/order_model.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onExplorePressed;

  const CartScreen({super.key, this.onExplorePressed});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _voucherController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cart = AppState.instance.cartController;
    _tableController.text = cart.tableNumber;
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = AppState.instance.cartController;
    final voucherCtrl = AppState.instance.voucherController;

    return AnimatedBuilder(
      animation: Listenable.merge([cartController, voucherCtrl]),
      builder: (context, _) {
        if (cartController.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Keranjang Belanja'),
            ),
            body: EmptyStateView(
              icon: Icons.remove_shopping_cart_rounded,
              title: 'Keranjang Masih Kosong',
              message: 'Yuk, pilih makanan dan minuman favoritmu dari stan kantin sekarang!',
              buttonText: 'Cari Menu Lezat',
              onButtonPressed: () {
                if (widget.onExplorePressed != null) {
                  widget.onExplorePressed!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Keranjang Belanja'),
            actions: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Kosongkan Keranjang?'),
                      content: const Text('Seluruh item yang dipilih akan dihapus.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            cartController.clearCart();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Kosongkan', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Hapus Semua', style: TextStyle(color: AppColors.error, fontSize: 13)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Type Selection (Dine-in vs Takeaway)
                Container(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Opsi Pengambilan Pesanan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Row(
                        children: [
                          Expanded(
                            child: _OrderTypeOption(
                              title: 'Makan di Tempat',
                              subtitle: 'Dine-in di meja kantin',
                              icon: Icons.table_restaurant_rounded,
                              isSelected: cartController.orderType == OrderType.dineIn,
                              onTap: () => cartController.setOrderType(OrderType.dineIn),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: _OrderTypeOption(
                              title: 'Bawa Pulang',
                              subtitle: 'Takeaway dalam kotak',
                              icon: Icons.takeout_dining_rounded,
                              isSelected: cartController.orderType == OrderType.takeaway,
                              onTap: () => cartController.setOrderType(OrderType.takeaway),
                            ),
                          ),
                        ],
                      ),
                      if (cartController.orderType == OrderType.dineIn) ...[
                        const SizedBox(height: AppDimens.sm),
                        AppTextField(
                          controller: _tableController,
                          label: 'Nomor Meja',
                          hint: 'Contoh: Meja 12 / Selasar A',
                          prefixIcon: const Icon(Icons.pin_drop_rounded, size: 18, color: AppColors.primary),
                          onChanged: (val) => cartController.setTableNumber(val),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.md),

                // Canteen Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${cartController.primaryCanteenName} — Kantin Terpadu • Kantin Utama Lt. 1',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.sm),

                // Cart Items List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartController.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimens.sm),
                  itemBuilder: (context, index) {
                    final item = cartController.items[index];
                    return Container(
                      padding: const EdgeInsets.all(AppDimens.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            child: SizedBox(
                              width: 65,
                              height: 65,
                              child: MenuImageView(
                                imageUrl: item.menuItem.imageUrl,
                                imageBytes: item.menuItem.imageBytes,
                                width: 65,
                                height: 65,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menuItem.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (item.selectedSpicyLevel != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Level: ${item.selectedSpicyLevel}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                                  ),
                                ],
                                if (item.selectedToppings.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Topping: ${item.selectedToppings.map((t) => t.name).join(", ")}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                                if (item.specialNotes != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Catatan: "${item.specialNotes}"',
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        CurrencyFormatter.format(item.totalPrice),
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
                                    // Quantity Controls
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () => cartController.updateQuantity(item.id, item.quantity - 1),
                                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                            child: const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(Icons.remove_rounded, size: 16),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => cartController.updateQuantity(item.id, item.quantity + 1),
                                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                            child: const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimens.md),

                // Voucher Input Box
                Container(
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.confirmation_number_outlined, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Kupon & Voucher Diskon',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.xs),
                      if (cartController.appliedVoucherCode != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Voucher "${cartController.appliedVoucherCode}" diterapkan (-${CurrencyFormatter.format(cartController.discountAmount)})',
                                  style: const TextStyle(color: AppColors.secondaryDark, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.secondaryDark),
                                onPressed: () => cartController.removeVoucher(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Builder(
                          builder: (context) {
                            final availableVouchers = voucherCtrl.getAvailableVouchersForCart(
                              cartController.primaryCanteenId,
                            );
                            final sampleCode = availableVouchers.isNotEmpty ? availableVouchers.first.code : 'KODE';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        controller: _voucherController,
                                        hint: 'Gunakan voucher: $sampleCode',
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.sm),
                                    ElevatedButton(
                                      onPressed: () {
                                        final result = cartController.applyVoucherWithMessage(_voucherController.text);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result.message),
                                            backgroundColor: result.success ? AppColors.secondary : AppColors.error,
                                          ),
                                        );
                                        if (result.success) {
                                          _voucherController.clear();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
                                      ),
                                      child: const Text('Terapkan'),
                                    ),
                                  ],
                                ),
                                if (availableVouchers.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Voucher khusus stan ${cartController.currentCanteenName} (hanya berlaku di stan ini):',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 54,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: availableVouchers.length,
                                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                                      itemBuilder: (context, idx) {
                                        final v = availableVouchers[idx];
                                        final isEligible = cartController.subtotal >= v.minPurchase;
                                        return InkWell(
                                          onTap: () {
                                            final res = cartController.applyVoucherWithMessage(v.code);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(res.message),
                                                backgroundColor: res.success ? AppColors.secondary : AppColors.warning,
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isEligible ? AppColors.primaryContainer : AppColors.surfaceVariant,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isEligible
                                                    ? AppColors.primary.withValues(alpha: 0.45)
                                                    : AppColors.outline,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${v.code} • -${CurrencyFormatter.format(v.discountAmount)}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primaryDark,
                                                  ),
                                                ),
                                                Text(
                                                  v.minPurchase > 0
                                                      ? 'Min. ${CurrencyFormatter.format(v.minPurchase)}'
                                                      : 'Tanpa min. belanja',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.md),

                // Order Price Breakdown Card
                Container(
                  padding: const EdgeInsets.all(AppDimens.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Biaya Pesanan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      _SummaryRow(
                        label: 'Subtotal Makanan (${cartController.totalQuantity} item)',
                        value: CurrencyFormatter.format(cartController.subtotal),
                      ),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: 'Biaya Layanan Kantin',
                        value: CurrencyFormatter.format(cartController.serviceFee),
                      ),
                      if (cartController.discountAmount > 0) ...[
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: 'Potongan Diskon Promo',
                          value: '-${CurrencyFormatter.format(cartController.discountAmount)}',
                          valueColor: AppColors.secondary,
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        label: 'Total Pembayaran',
                        value: CurrencyFormatter.format(cartController.totalAmount),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.outline)),
              boxShadow: [AppColors.softShadow],
            ),
            child: SafeArea(
              top: false,
              child: AppButton(
                text: 'Lanjut ke Pembayaran • ${CurrencyFormatter.format(cartController.totalAmount)}',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.sm),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
