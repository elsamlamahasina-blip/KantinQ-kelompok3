import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../order/models/order_model.dart';
import '../../order/screens/payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'COD (Bayar Tunai di Kasir)';
  bool _isProcessing = false;

  Future<void> _processCheckout() async {
    final cart = AppState.instance.cartController;

    if (cart.items.isEmpty) return;

    final total = cart.totalAmount;

    // COD — Bayar Tunai di Kasir Stan
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan (COD)'),
        content: Text(
          'Pesanan Anda akan langsung diteruskan ke dapur stan untuk dipersiapkan.\n\n'
          'Anda akan membayar sebesar ${CurrencyFormatter.format(total)} secara tunai di kasir stan saat mengambil makanan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pesan Sekarang (COD)'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    await _finalizeOrderCreation();
  }

  Future<void> _finalizeOrderCreation() async {
    final cart = AppState.instance.cartController;
    final orderCtrl = AppState.instance.orderController;
    final canteenCtrl = AppState.instance.canteenController;
    final authCtrl = AppState.instance.authController;

    setState(() {
      _isProcessing = true;
    });

    try {
      final usedVoucherCode = cart.appliedVoucherCode;

      // 1. Deduct Stock for each menu item
      canteenCtrl.deductStockForOrder(cart.items);

      // 2. Create Order
      final createdOrder = await orderCtrl.createOrder(
        canteenId: cart.primaryCanteenId,
        canteenName: cart.primaryCanteenName,
        customerName: authCtrl.currentUser?.name ?? 'Rian Pratama',
        customerPhone: authCtrl.currentUser?.phone ?? '081234567890',
        items: cart.items,
        orderType: cart.orderType,
        tableNumber: cart.tableNumber,
        paymentMethod: _selectedPaymentMethod,
        subtotal: cart.subtotal,
        serviceFee: cart.serviceFee,
        discountAmount: cart.discountAmount,
        totalAmount: cart.totalAmount,
        notes: cart.customerNotes,
      );

      // 3. Increment voucher usage & clear cart
      AppState.instance.voucherController.markVoucherUsed(usedVoucherCode);
      cart.clearCart();

      if (!mounted) return;

      // 4. Navigate to Payment Success Screen (B-08)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(order: createdOrder),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memproses pesanan. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = AppState.instance.cartController;

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final total = cart.totalAmount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Konfirmasi Pembayaran'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COD Banner Information
                Container(
                  margin: const EdgeInsets.only(bottom: AppDimens.md),
                  padding: const EdgeInsets.all(AppDimens.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.payments_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sistem COD Aktif: Pesanan langsung diproses dapur stan. Anda bayar tunai saat mengambil makanan di kasir.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Details Card
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Informasi Pengambilan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: AppDimens.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                            ),
                            child: Text(
                              cart.orderType == OrderType.dineIn ? 'Dine-in' : 'Takeaway',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        cart.primaryCanteenName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      if (cart.orderType == OrderType.dineIn) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Lokasi: ${cart.tableNumber}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(height: AppDimens.sm),
                      Text(
                        'Total ${cart.totalQuantity} menu pesanan siap diproses.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.md),

                // Payment Method Header
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppDimens.xs),

                // Option 1: COD (Cash on Delivery / Bayar Tunai di Kasir)
                _PaymentMethodTile(
                  icon: Icons.payments_rounded,
                  title: 'COD — Bayar Tunai di Kasir Stan',
                  subtitle: 'Bayar tunai langsung saat mengambil makanan (Tanpa Top Up)',
                  isSelected: true,
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'COD (Bayar Tunai di Kasir)';
                    });
                  },
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Utama (COD)',
                      style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimens.md),

                // Final Summary Card
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
                        'Ringkasan Akhir',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      _SummaryRow(label: 'Subtotal Menu', value: CurrencyFormatter.format(cart.subtotal)),
                      const SizedBox(height: 6),
                      _SummaryRow(label: 'Biaya Layanan', value: CurrencyFormatter.format(cart.serviceFee)),
                      if (cart.discountAmount > 0) ...[
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: 'Voucher Promo',
                          value: '-${CurrencyFormatter.format(cart.discountAmount)}',
                          valueColor: AppColors.secondary,
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        label: 'Total Tagihan',
                        value: CurrencyFormatter.format(total),
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
                text: 'Bayar Sekarang • ${CurrencyFormatter.format(total)}',
                isLoading: _isProcessing,
                onPressed: _processCheckout,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: AppDimens.xs),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white))
                  : null,
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
