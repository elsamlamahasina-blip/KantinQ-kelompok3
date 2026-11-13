import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/state/app_state.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/order_model.dart';
import '../widgets/digital_receipt_sheet.dart';
import '../../cart/screens/cart_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  void _showReceipt(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DigitalReceiptSheet(order: order),
    );
  }

  void _showContactDialog(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.canteenName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Nomor WhatsApp / Telp: 0812-9876-5432', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2E7D32), size: 20),
                ),
                title: const Text('Kirim Pesan WhatsApp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Tanyakan status antrean atau catatan khusus', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Membuka WhatsApp ke stan "${order.canteenName}"...'),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                ),
                title: const Text('Panggilan Suara Langsung', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Hubungi pemilik stan lewat telepon', style: TextStyle(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menghubungi telepon stan "${order.canteenName}"...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _cancelOrder(BuildContext context, OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: Text(
          'Pesanan #${order.queueNumber} akan dibatalkan. '
          'Karena menggunakan metode pembayaran COD (Bayar di Kasir), pesanan dibatalkan dan tidak ada tagihan yang harus dibayar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final orderCtrl = AppState.instance.orderController;
      final canteenCtrl = AppState.instance.canteenController;

      // 1. Cancel order in controller
      orderCtrl.cancelOrder(order.id, reason: 'Dibatalkan oleh pembeli');

      // 2. Restore stock
      canteenCtrl.restoreStockForOrder(order.items);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan dan dana dikembalikan.'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderCtrl = AppState.instance.orderController;

    return AnimatedBuilder(
      animation: orderCtrl,
      builder: (context, _) {
        final order = orderCtrl.getOrderById(orderId) ?? orderCtrl.latestActiveOrder;

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pesanan')),
            body: const Center(child: Text('Pesanan tidak ditemukan')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Tiket Antrean & Pelacakan'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.headset_mic_outlined),
                tooltip: 'Hubungi Stan',
                onPressed: () => _showContactDialog(context, order),
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long_rounded),
                tooltip: 'Lihat Struk',
                onPressed: () => _showReceipt(context, order),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              children: [
                // Cancellation Banner if canceled
                if (order.isCanceled) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppDimens.md),
                    padding: const EdgeInsets.all(AppDimens.sm),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_rounded, color: AppColors.error, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pesanan Dibatalkan',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 13),
                              ),
                              Text(
                                order.cancellationReason ?? 'Pesanan telah dibatalkan.',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Digital Queue Ticket (without barcode)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: AppColors.outline),
                    boxShadow: const [AppColors.softShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Section of Ticket
                      Padding(
                        padding: const EdgeInsets.all(AppDimens.lg),
                        child: Column(
                          children: [
                            StatusBadge(status: order.status),
                            const SizedBox(height: AppDimens.sm),
                            const Text(
                              'NOMOR ANTREAN ANDA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.queueNumber,
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.canteenName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.orderTypeLabel} ${order.tableNumber != null ? "• ${order.tableNumber}" : ""}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppDimens.md),

                            // Estimated Time Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_rounded, color: AppColors.secondary, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Estimasi Siap: ${DateFormatter.formatTimeOnly(order.estimatedReadyTime)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.secondaryDark,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // COD Pickup Instructions Banner (Replaces barcode)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(AppDimens.radiusLg),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payments_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Sebutkan kode ${order.queueNumber} di kasir stan & bayar tunai (COD)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.md),

                // Live Stepper Status Card
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
                        'Proses Dapur Real-Time',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppDimens.md),
                      _QueueStepTile(
                        stepNumber: '1',
                        title: 'Pesanan Diterima',
                        description: 'Stan telah menerima rincian pesanan Anda',
                        isPassed: true,
                        isCurrent: order.status == OrderStatusType.waiting,
                      ),
                      _QueueStepTile(
                        stepNumber: '2',
                        title: 'Sedang Dimasak / Disiapkan',
                        description: 'Koki sedang meracik menu dengan higienis',
                        isPassed: order.status == OrderStatusType.cooking ||
                            order.status == OrderStatusType.ready ||
                            order.status == OrderStatusType.completed,
                        isCurrent: order.status == OrderStatusType.cooking,
                      ),
                      _QueueStepTile(
                        stepNumber: '3',
                        title: 'Siap Diambil di Stan',
                        description: 'Makanan telah siap di etalase nomor stan',
                        isPassed: order.status == OrderStatusType.ready ||
                            order.status == OrderStatusType.completed,
                        isCurrent: order.status == OrderStatusType.ready,
                      ),
                      _QueueStepTile(
                        stepNumber: '4',
                        title: 'Selesai & Dinikmati',
                        description: 'Pesanan telah diterima oleh Anda',
                        isPassed: order.status == OrderStatusType.completed,
                        isCurrent: order.status == OrderStatusType.completed,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimens.md),

                // Order Action Buttons
                if (order.status == OrderStatusType.ready) ...[
                  AppButton(
                    text: 'Konfirmasi Pesanan Diterima',
                    variant: AppButtonVariant.secondary,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    onPressed: () {
                      orderCtrl.confirmOrderReceived(order.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selamat menikmati hidangan KantinQ Anda!'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.sm),
                ],

                // Advance Kitchen Status simulation button (Interactive Queue Testing)
                if (order.isActive) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      orderCtrl.advanceOrderStatus(order.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Status antrean dapur diperbarui!'),
                          duration: Duration(milliseconds: 1200),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fast_forward_rounded, size: 16),
                    label: const Text('Simulasi Dapur (Maju ke Tahap Berikutnya)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                ],

                // Cancel Order button (FR-STS-06 / AF-04: Only when status is waiting)
                if (order.status == OrderStatusType.waiting) ...[
                  AppButton(
                    text: 'Batalkan Pesanan Ini',
                    variant: AppButtonVariant.danger,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => _cancelOrder(context, order),
                  ),
                  const SizedBox(height: AppDimens.sm),
                ] else if (order.status == OrderStatusType.cooking) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Makanan sedang dimasak. Hubungi stan jika ada perubahan mendesak.',
                            style: TextStyle(fontSize: 11, color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                ],

                if (order.status == OrderStatusType.completed) ...[
                  AppButton(
                    text: 'Pesan Lagi Menu Ini (Re-order)',
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    onPressed: () {
                      final cart = AppState.instance.cartController;
                      if (cart.isDifferentCanteen(order.canteenId)) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Ganti Stan Kantin?'),
                            content: Text(
                              'Keranjang Anda saat ini berisi menu dari stan "${cart.currentCanteenName}".\n\n'
                              'Apakah Anda ingin mengosongkan keranjang dan memesan ulang dari "${order.canteenName}"?',
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
                                  cart.clear();
                                  for (final item in order.items) {
                                    cart.addItem(
                                      menuItem: item.menuItem,
                                      quantity: item.quantity,
                                      selectedSpicyLevel: item.selectedSpicyLevel,
                                      selectedToppings: item.selectedToppings,
                                      specialNotes: item.specialNotes,
                                    );
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CartScreen()),
                                  );
                                },
                                child: const Text('Ganti Stan & Pesan'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      for (final item in order.items) {
                        cart.addItem(
                          menuItem: item.menuItem,
                          quantity: item.quantity,
                          selectedSpicyLevel: item.selectedSpicyLevel,
                          selectedToppings: item.selectedToppings,
                          specialNotes: item.specialNotes,
                        );
                      }
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Menu berhasil dimasukkan kembali ke keranjang!',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                  const SizedBox(height: AppDimens.sm),
                ],

                AppButton(
                  text: 'Lihat Struk Digital',
                  variant: AppButtonVariant.outline,
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  onPressed: () => _showReceipt(context, order),
                ),

                const SizedBox(height: AppDimens.sm),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali ke Beranda'),
                ),

                const SizedBox(height: AppDimens.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QueueStepTile extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;
  final bool isPassed;
  final bool isCurrent;
  final bool isLast;

  const _QueueStepTile({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.isPassed,
    required this.isCurrent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    Color nodeColor = AppColors.outlineVariant;
    if (isCurrent) nodeColor = AppColors.primary;
    if (isPassed && !isCurrent) nodeColor = AppColors.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isPassed && !isCurrent
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Text(
                        stepNumber,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isPassed ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
